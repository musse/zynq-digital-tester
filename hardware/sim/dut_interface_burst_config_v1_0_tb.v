
`timescale 1 ps / 1 ps

`include "dut_interface_burst_config_v1_0_tb_include.vh"

// lite_response Type Defines
`define RESPONSE_OKAY 2'b00
`define RESPONSE_EXOKAY 2'b01
`define RESP_BUS_WIDTH 2
`define BURST_TYPE_INCR  2'b01
`define BURST_TYPE_WRAP  2'b10

// AMBA AXI4 Lite Range Constants
`define S01_AXI_MAX_BURST_LENGTH 1
`define S01_AXI_DATA_BUS_WIDTH 32
`define S01_AXI_ADDRESS_BUS_WIDTH 32
`define S01_AXI_MAX_DATA_SIZE (`S01_AXI_DATA_BUS_WIDTH*`S01_AXI_MAX_BURST_LENGTH)/8

// Burst Size Defines
`define BURST_SIZE_4_BYTES   3'b010

// Lock Type Defines
`define LOCK_TYPE_NORMAL    1'b0

// AMBA S00_AXI AXI4 Range Constants
`define S00_AXI_MAX_BURST_LENGTH 8'b1111_1111
`define S00_AXI_MAX_DATA_SIZE (`S00_AXI_DATA_BUS_WIDTH*(`S00_AXI_MAX_BURST_LENGTH+1))/8
`define S00_AXI_DATA_BUS_WIDTH 32
`define S00_AXI_ADDRESS_BUS_WIDTH 32
`define S00_AXI_RUSER_BUS_WIDTH 1
`define S00_AXI_WUSER_BUS_WIDTH 1

`define DUT_BUS_WIDTH 32



module dut_interface_burst_config_v1_0_tb;
	reg tb_ACLK;
	reg tb_ARESETn;
	wire [`DUT_BUS_WIDTH-1:0] tb_dut_bus;

	// Create an instance of the example tb
            `BD_WRAPPER dut (.ACLK(tb_ACLK),
                        .ARESETN(tb_ARESETn),
                        .dut_bus(tb_dut_bus)
                        );

	// Local Variables

	// AMBA S01_AXI AXI4 Lite Local Reg
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] S01_AXI_rd_data_lite;
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] S01_AXI_test_data_lite [3:0];
	reg [`RESP_BUS_WIDTH-1:0] S01_AXI_lite_response;
	reg [`S01_AXI_ADDRESS_BUS_WIDTH-1:0] S01_AXI_mtestAddress;
	reg [3-1:0]   S01_AXI_mtestProtection_lite;
	integer S01_AXI_mtestvectorlite; // Master side testvector
	integer S01_AXI_mtestdatasizelite;
	

	// AMBA S00_AXI AXI4 Local Reg
	reg [(`S00_AXI_DATA_BUS_WIDTH*256)-1:0] S00_AXI_rd_data;
	reg [(`S00_AXI_DATA_BUS_WIDTH*(`S00_AXI_MAX_BURST_LENGTH+1)/16)-1:0] S00_AXI_test_data [2:0];
	reg [(`RESP_BUS_WIDTH*(`S00_AXI_MAX_BURST_LENGTH+1))-1:0] S00_AXI_vresponse;
	reg [`S00_AXI_ADDRESS_BUS_WIDTH-1:0] S00_AXI_mtestAddress;
	reg [(`S00_AXI_RUSER_BUS_WIDTH*(`S00_AXI_MAX_BURST_LENGTH+1))-1:0] S00_AXI_v_ruser;
	reg [(`S00_AXI_WUSER_BUS_WIDTH*(`S00_AXI_MAX_BURST_LENGTH+1))-1:0] S00_AXI_v_wuser;
	reg [`RESP_BUS_WIDTH-1:0] S00_AXI_response;
	integer  S00_AXI_mtestID; // Master side testID
	integer  S00_AXI_mtestBurstLength;
	integer  S00_AXI_mtestvector; // Master side testvector
	integer  S00_AXI_mtestdatasize;
	integer  S00_AXI_mtestCacheType = 0;
	integer  S00_AXI_mtestProtectionType = 0;
	integer  S00_AXI_mtestRegion = 0;
	integer  S00_AXI_mtestQOS = 0;
	integer  S00_AXI_mtestAWUSER = 0;
	integer  S00_AXI_mtestARUSER = 0;
	integer  S00_AXI_mtestBUSER = 0;
	
	//DUT registers and integers
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] STATUS_REG_OFFSET;
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] FINISHED_REG_OFFSET;
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] DUT_CTRL_OFFSET;
	reg [`S01_AXI_DATA_BUS_WIDTH-1:0] BURST_SIZE;
	integer i;
	integer circuit_values;
    integer output_values[255:0];
    reg [(`S00_AXI_DATA_BUS_WIDTH*256)-1:0] vector_values;
    reg [(`S00_AXI_DATA_BUS_WIDTH*256)-1:0] output_values_comp;
	
	//Signal and registers required to control the dut_bus
	wire [`DUT_BUS_WIDTH-1:0] input_bus;
    reg [`DUT_BUS_WIDTH-1:0] output_bus;
    reg output_bus_valid;
    assign input_bus = tb_dut_bus;
    assign tb_dut_bus = (output_bus_valid==1'b1) ? output_bus : 32'hZZZZZZZZ;    


	// Simple Reset Generator and test
	initial begin
		tb_ARESETn = 1'b0;
	  #500;
		// Release the reset on the posedge of the clk.
		@(posedge tb_ACLK);
	  tb_ARESETn = 1'b1;
		@(posedge tb_ACLK);
	end

	// Simple Clock Generator
	initial tb_ACLK = 1'b0;
	always #10 tb_ACLK = !tb_ACLK;
	
	//fill the output values with random numbers
	initial begin
	   for (i = 0; i < 256; i = i + 1) begin
	       output_values[i] = i*2;
	       output_values_comp = output_values_comp | (i*2 << (32*i));
	   end
	end
	
    initial output_bus_valid = 1;
    initial output_bus = output_values[0];

	//------------------------------------------------------------------------
	// TEST LEVEL API: CHECK_RESPONSE_OKAY
	//------------------------------------------------------------------------
	// Description:
	// CHECK_RESPONSE_OKAY(lite_response)
	// This task checks if the return lite_response is equal to OKAY
	//------------------------------------------------------------------------
	task automatic CHECK_RESPONSE_OKAY;
		input [`RESP_BUS_WIDTH-1:0] response;
		begin
		  if (response !== `RESPONSE_OKAY) begin
			  $display("TESTBENCH ERROR! lite_response is not OKAY",
				         "\n expected = 0x%h",`RESPONSE_OKAY,
				         "\n actual   = 0x%h",response);
		    $stop;
		  end
		end
	endtask

	//------------------------------------------------------------------------
	// TEST LEVEL API: COMPARE_DATA
	//------------------------------------------------------------------------
	// Description:
	// COMPARE_DATA(expected,actual)
	// This task checks if the actual data is equal to the expected data.
	// X is used as don't care but it is not permitted for the full vector
	// to be don't care.
	//------------------------------------------------------------------------
	task automatic COMPARE_DATA;
		input expected;
		input actual;
		begin
			if (expected === 'hx || actual === 'hx) begin
				$display("TESTBENCH ERROR! COMPARE_DATA cannot be performed with an expected or actual vector that is all 'x'!");
		    $stop;
		  end

			if (actual != expected) begin
				$display("TESTBENCH ERROR! Data expected is not equal to actual.",
				         "\n expected = 0x%h",expected,
				         "\n actual   = 0x%h",actual);
		    $stop;
		  end
		end
	endtask

	task automatic TESTER_AXI_BURST_CONFIG_TB;
		begin
			$display("---------------------------------------------------------");
			$display("dut_interface_burst_config test begin");
			$display("---------------------------------------------------------");
						
			
			S00_AXI_mtestID = 1;
			S00_AXI_mtestvector = 0;
			S00_AXI_mtestBurstLength = 255;
			S00_AXI_mtestAddress = `S00_AXI_SLAVE_ADDRESS;
			S00_AXI_mtestCacheType = 0;
			S00_AXI_mtestProtectionType = 0;
			S00_AXI_mtestdatasize = 1024;
			S00_AXI_mtestRegion = 0;
			S00_AXI_mtestQOS = 0;
			S00_AXI_mtestAWUSER = 0;
			S00_AXI_mtestARUSER = 0;
			
			//burst write of all the test vectors
			dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.WRITE_BURST_CONCURRENT(S00_AXI_mtestID,
			                        S00_AXI_mtestAddress,
			                        S00_AXI_mtestBurstLength,
			                        `BURST_SIZE_4_BYTES,
			                        `BURST_TYPE_INCR,
			                        `LOCK_TYPE_NORMAL,
			                        S00_AXI_mtestCacheType,
			                        S00_AXI_mtestProtectionType,
			                        vector_values,
			                        S00_AXI_mtestdatasize,
			                        S00_AXI_mtestRegion,
			                        S00_AXI_mtestQOS,
			                        S00_AXI_mtestAWUSER,
			                        S00_AXI_v_wuser,
			                        S00_AXI_response,
			                        S00_AXI_mtestBUSER);
			$display("EXAMPLE TEST 1 : DATA = 0x%h, response = 0x%h",vector_values,S00_AXI_response);
			CHECK_RESPONSE_OKAY(S00_AXI_response);
			S00_AXI_mtestID = S00_AXI_mtestID+1;
			
			// Check that the data received by the master is the same as the test 
			// vector supplied by the slave.
			COMPARE_DATA(vector_values,S00_AXI_rd_data);
			          
            S01_AXI_mtestvectorlite = 0;
            S01_AXI_mtestAddress = `S01_AXI_SLAVE_ADDRESS;
            S01_AXI_mtestProtection_lite = 0;
            S01_AXI_mtestdatasizelite = `S01_AXI_MAX_DATA_SIZE;
            
            STATUS_REG_OFFSET = `S01_AXI_SLAVE_ADDRESS;
            FINISHED_REG_OFFSET = (`S01_AXI_SLAVE_ADDRESS+(1*(32'h00000004)));
            DUT_CTRL_OFFSET = (`S01_AXI_SLAVE_ADDRESS+(2*(32'h00000004)));
            BURST_SIZE = (`S01_AXI_SLAVE_ADDRESS+(3*(32'h00000004)));
            
            output_bus_valid = 0;
                        
			//writes the appropriate pinout to the configuration register
            dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( 
                    DUT_CTRL_OFFSET,
                    S01_AXI_mtestProtection_lite,
                    32'hC000BC,
                    S01_AXI_mtestdatasizelite,
                    S01_AXI_lite_response);
            
            //writes the number of vectors sent in burst mode        
            dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( 
                    BURST_SIZE,
                    S01_AXI_mtestProtection_lite,
                    S00_AXI_mtestBurstLength+1, //burst_size of FULL AXI interface
                    S01_AXI_mtestdatasizelite,
                    S01_AXI_lite_response);
                    
            #200
			
			//send the 'go' signal so the FSM can start
            dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( 
                STATUS_REG_OFFSET,
                S01_AXI_mtestProtection_lite,
                32'h00000001,
                S01_AXI_mtestdatasizelite,
                S01_AXI_lite_response);
            
            for (circuit_values = 0; circuit_values < 256; circuit_values = circuit_values + 1)
                begin
					
					//fill out its expected output for the input sent each 5 cycles (FSM duration)
                    output_bus_valid = 1;
                    output_bus = output_values[circuit_values];
                    
                    #100;
            
                end
            
            //read the 'has_finished' signal to check if the FSM has already finished its work
             dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.READ_BURST(
                   FINISHED_REG_OFFSET,
                   S01_AXI_mtestProtection_lite,
                   S01_AXI_rd_data_lite,
                   S01_AXI_lite_response);
               
               //do this until 'has_finished' equals '1'
               while ((S01_AXI_rd_data_lite & 32'h00000001) == 0) begin
                   dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.READ_BURST(
                       FINISHED_REG_OFFSET,
                       S01_AXI_mtestProtection_lite,
                       S01_AXI_rd_data_lite,
                       S01_AXI_lite_response);
               end
               
               output_bus_valid = 0;
               
               /* reads the output of the circuit from the memory
					and compare with the output_values */
               dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.READ_BURST(S00_AXI_mtestID,
                                      S00_AXI_mtestAddress,
                                      S00_AXI_mtestBurstLength,
                                      `BURST_SIZE_4_BYTES,
                                      `BURST_TYPE_INCR,
                                      `LOCK_TYPE_NORMAL,
                                      S00_AXI_mtestCacheType,
                                      S00_AXI_mtestProtectionType,
                                      S00_AXI_mtestRegion,
                                      S00_AXI_mtestQOS,
                                      S00_AXI_mtestARUSER,
                                      S00_AXI_rd_data,
                                      S00_AXI_vresponse,
                                      S00_AXI_v_ruser);
               $display("EXAMPLE TEST 1 : DATA = 0x%h, vresponse = 0x%h",S00_AXI_rd_data,S00_AXI_vresponse);
               CHECK_RESPONSE_OKAY(S00_AXI_vresponse);
               COMPARE_DATA(output_values_comp,S00_AXI_rd_data);
             
             //writes '0' to the 'go' signal to finish all the rounds  
			dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT( 
                                             STATUS_REG_OFFSET,
                                             S01_AXI_mtestProtection_lite,
                                             32'h00000000,
                                             S01_AXI_mtestdatasizelite,
                                             S01_AXI_lite_response);
			 S00_AXI_mtestID = S00_AXI_mtestID+1;
                                             
		end
	endtask 
	

	// Create the test vectors
	initial begin
		// When performing debug enable all levels of INFO messages.
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);  

		dut.`BD_INST_NAME.master_1.cdn_axi4_lite_master_bfm_inst.set_channel_level_info(1);
		dut.`BD_INST_NAME.master_0.cdn_axi4_master_bfm_inst.set_channel_level_info(1);
		
		//vector_values = {32'h40002, 32'h40000, 32'h10003, 32'h10001, 32'h10002, 32'h10000, 32'h3, 32'h1, 32'h2, 32'h0};
		vector_values = 8192'h00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF00abcdef111111112222222233333333444444445555555566666666777777778888888899999999AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEEFFFFFFFF;
	end

	// Drive the BFM
	initial begin
		// Wait for end of reset
		wait(tb_ARESETn === 0) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     
		wait(tb_ARESETn === 1) @(posedge tb_ACLK);     

		TESTER_AXI_BURST_CONFIG_TB();

	end

endmodule
