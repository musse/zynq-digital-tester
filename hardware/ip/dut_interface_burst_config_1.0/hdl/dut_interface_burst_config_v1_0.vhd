library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dut_interface_burst_config_v1_0 is
	generic (
		-- Users to add parameters here
        DUT_BUS_WIDTH	: integer	:= 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_ID_WIDTH	: integer	:= 1;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 10;
		C_S00_AXI_AWUSER_WIDTH	: integer	:= 1;
		C_S00_AXI_ARUSER_WIDTH	: integer	:= 1;
		C_S00_AXI_WUSER_WIDTH	: integer	:= 1;
		C_S00_AXI_RUSER_WIDTH	: integer	:= 1;
		C_S00_AXI_BUSER_WIDTH	: integer	:= 1;

		-- Parameters of Axi Slave Bus Interface S01_AXI
		C_S01_AXI_DATA_WIDTH	: integer	:= 32;
		C_S01_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
        dut_bus : inout std_logic_vector(DUT_BUS_WIDTH-1 downto 0);
        test_started : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awid	: in std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awlen	: in std_logic_vector(7 downto 0);
		s00_axi_awsize	: in std_logic_vector(2 downto 0);
		s00_axi_awburst	: in std_logic_vector(1 downto 0);
		s00_axi_awlock	: in std_logic;
		s00_axi_awcache	: in std_logic_vector(3 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awqos	: in std_logic_vector(3 downto 0);
		s00_axi_awregion	: in std_logic_vector(3 downto 0);
		s00_axi_awuser	: in std_logic_vector(C_S00_AXI_AWUSER_WIDTH-1 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wlast	: in std_logic;
		s00_axi_wuser	: in std_logic_vector(C_S00_AXI_WUSER_WIDTH-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bid	: out std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_buser	: out std_logic_vector(C_S00_AXI_BUSER_WIDTH-1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_arid	: in std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arlen	: in std_logic_vector(7 downto 0);
		s00_axi_arsize	: in std_logic_vector(2 downto 0);
		s00_axi_arburst	: in std_logic_vector(1 downto 0);
		s00_axi_arlock	: in std_logic;
		s00_axi_arcache	: in std_logic_vector(3 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arqos	: in std_logic_vector(3 downto 0);
		s00_axi_arregion	: in std_logic_vector(3 downto 0);
		s00_axi_aruser	: in std_logic_vector(C_S00_AXI_ARUSER_WIDTH-1 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rid	: out std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rlast	: out std_logic;
		s00_axi_ruser	: out std_logic_vector(C_S00_AXI_RUSER_WIDTH-1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S01_AXI
		s01_axi_aclk	: in std_logic;
		s01_axi_aresetn	: in std_logic;
		s01_axi_awaddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_awprot	: in std_logic_vector(2 downto 0);
		s01_axi_awvalid	: in std_logic;
		s01_axi_awready	: out std_logic;
		s01_axi_wdata	: in std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_wstrb	: in std_logic_vector((C_S01_AXI_DATA_WIDTH/8)-1 downto 0);
		s01_axi_wvalid	: in std_logic;
		s01_axi_wready	: out std_logic;
		s01_axi_bresp	: out std_logic_vector(1 downto 0);
		s01_axi_bvalid	: out std_logic;
		s01_axi_bready	: in std_logic;
		s01_axi_araddr	: in std_logic_vector(C_S01_AXI_ADDR_WIDTH-1 downto 0);
		s01_axi_arprot	: in std_logic_vector(2 downto 0);
		s01_axi_arvalid	: in std_logic;
		s01_axi_arready	: out std_logic;
		s01_axi_rdata	: out std_logic_vector(C_S01_AXI_DATA_WIDTH-1 downto 0);
		s01_axi_rresp	: out std_logic_vector(1 downto 0);
		s01_axi_rvalid	: out std_logic;
		s01_axi_rready	: in std_logic
	);
	
	-- Users to add signals here
	signal ram_out  : std_logic_vector (C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal ram_in   : std_logic_vector (C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal ram_addr : std_logic_vector (C_S00_AXI_ADDR_WIDTH-1 downto 0);
    signal go_read  : std_logic;
    signal go_write : std_logic;
    -- User signals ends
    
end dut_interface_burst_config_v1_0;

architecture arch_imp of dut_interface_burst_config_v1_0 is

	-- component declaration
	component dut_interface_burst_config_v1_0_S00_AXI is
		generic (
		C_S_AXI_ID_WIDTH	: integer	:= 1;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 10;
		C_S_AXI_AWUSER_WIDTH	: integer	:= 1;
		C_S_AXI_ARUSER_WIDTH	: integer	:= 1;
		C_S_AXI_WUSER_WIDTH	: integer	:= 1;
		C_S_AXI_RUSER_WIDTH	: integer	:= 1;
		C_S_AXI_BUSER_WIDTH	: integer	:= 1
		);
		port (
		S_RAM_OUT : out std_logic_vector(C_S_AXI_DATA_WIDTH-1	downto 0);
        S_RAM_IN  : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_RAM_ADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_GO_READ : in std_logic;
        S_GO_WRITE    : in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWLEN	: in std_logic_vector(7 downto 0);
		S_AXI_AWSIZE	: in std_logic_vector(2 downto 0);
		S_AXI_AWBURST	: in std_logic_vector(1 downto 0);
		S_AXI_AWLOCK	: in std_logic;
		S_AXI_AWCACHE	: in std_logic_vector(3 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWQOS	: in std_logic_vector(3 downto 0);
		S_AXI_AWREGION	: in std_logic_vector(3 downto 0);
		S_AXI_AWUSER	: in std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WLAST	: in std_logic;
		S_AXI_WUSER	: in std_logic_vector(C_S_AXI_WUSER_WIDTH-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BUSER	: out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARLEN	: in std_logic_vector(7 downto 0);
		S_AXI_ARSIZE	: in std_logic_vector(2 downto 0);
		S_AXI_ARBURST	: in std_logic_vector(1 downto 0);
		S_AXI_ARLOCK	: in std_logic;
		S_AXI_ARCACHE	: in std_logic_vector(3 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARQOS	: in std_logic_vector(3 downto 0);
		S_AXI_ARREGION	: in std_logic_vector(3 downto 0);
		S_AXI_ARUSER	: in std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RLAST	: out std_logic;
		S_AXI_RUSER	: out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component dut_interface_burst_config_v1_0_S00_AXI;

	component dut_interface_burst_config_v1_0_S01_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_RAM_OUT : in std_logic_vector(C_S_AXI_DATA_WIDTH-1	downto 0);
        S_RAM_IN  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_RAM_ADDR  : out std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        S_GO_READ : out std_logic;
        S_GO_WRITE    : out std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		dut_bus : inout std_logic_vector(DUT_BUS_WIDTH-1 downto 0);
        test_started : out std_logic
		);
	end component dut_interface_burst_config_v1_0_S01_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
dut_interface_burst_config_v1_0_S00_AXI_inst : dut_interface_burst_config_v1_0_S00_AXI
	generic map (
		C_S_AXI_ID_WIDTH	=> C_S00_AXI_ID_WIDTH,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		C_S_AXI_AWUSER_WIDTH	=> C_S00_AXI_AWUSER_WIDTH,
		C_S_AXI_ARUSER_WIDTH	=> C_S00_AXI_ARUSER_WIDTH,
		C_S_AXI_WUSER_WIDTH	=> C_S00_AXI_WUSER_WIDTH,
		C_S_AXI_RUSER_WIDTH	=> C_S00_AXI_RUSER_WIDTH,
		C_S_AXI_BUSER_WIDTH	=> C_S00_AXI_BUSER_WIDTH
	)
	port map (
        S_RAM_OUT => ram_out,
        S_RAM_IN  => ram_in,
        S_RAM_ADDR  => ram_addr,
        S_GO_READ => go_read,
        S_GO_WRITE => go_write,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWID	=> s00_axi_awid,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWLEN	=> s00_axi_awlen,
		S_AXI_AWSIZE	=> s00_axi_awsize,
		S_AXI_AWBURST	=> s00_axi_awburst,
		S_AXI_AWLOCK	=> s00_axi_awlock,
		S_AXI_AWCACHE	=> s00_axi_awcache,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWQOS	=> s00_axi_awqos,
		S_AXI_AWREGION	=> s00_axi_awregion,
		S_AXI_AWUSER	=> s00_axi_awuser,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WLAST	=> s00_axi_wlast,
		S_AXI_WUSER	=> s00_axi_wuser,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BID	=> s00_axi_bid,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BUSER	=> s00_axi_buser,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARID	=> s00_axi_arid,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARLEN	=> s00_axi_arlen,
		S_AXI_ARSIZE	=> s00_axi_arsize,
		S_AXI_ARBURST	=> s00_axi_arburst,
		S_AXI_ARLOCK	=> s00_axi_arlock,
		S_AXI_ARCACHE	=> s00_axi_arcache,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARQOS	=> s00_axi_arqos,
		S_AXI_ARREGION	=> s00_axi_arregion,
		S_AXI_ARUSER	=> s00_axi_aruser,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RID	=> s00_axi_rid,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RLAST	=> s00_axi_rlast,
		S_AXI_RUSER	=> s00_axi_ruser,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

-- Instantiation of Axi Bus Interface S01_AXI
dut_interface_burst_config_v1_0_S01_AXI_inst : dut_interface_burst_config_v1_0_S01_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S01_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S01_AXI_ADDR_WIDTH
	)
	port map (
        S_RAM_OUT => ram_out,
        S_RAM_IN  => ram_in,
        S_RAM_ADDR  => ram_addr,
        S_GO_READ => go_read,
        S_GO_WRITE => go_write,
		S_AXI_ACLK	=> s01_axi_aclk,
		S_AXI_ARESETN	=> s01_axi_aresetn,
		S_AXI_AWADDR	=> s01_axi_awaddr,
		S_AXI_AWPROT	=> s01_axi_awprot,
		S_AXI_AWVALID	=> s01_axi_awvalid,
		S_AXI_AWREADY	=> s01_axi_awready,
		S_AXI_WDATA	=> s01_axi_wdata,
		S_AXI_WSTRB	=> s01_axi_wstrb,
		S_AXI_WVALID	=> s01_axi_wvalid,
		S_AXI_WREADY	=> s01_axi_wready,
		S_AXI_BRESP	=> s01_axi_bresp,
		S_AXI_BVALID	=> s01_axi_bvalid,
		S_AXI_BREADY	=> s01_axi_bready,
		S_AXI_ARADDR	=> s01_axi_araddr,
		S_AXI_ARPROT	=> s01_axi_arprot,
		S_AXI_ARVALID	=> s01_axi_arvalid,
		S_AXI_ARREADY	=> s01_axi_arready,
		S_AXI_RDATA	=> s01_axi_rdata,
		S_AXI_RRESP	=> s01_axi_rresp,
		S_AXI_RVALID	=> s01_axi_rvalid,
		S_AXI_RREADY	=> s01_axi_rready,
		dut_bus => dut_bus,
        test_started => test_started
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
