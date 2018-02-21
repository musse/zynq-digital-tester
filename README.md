# zynq-digital-tester

A Zynq-7000 based low-cost platform for testing integrated circuits.

## Overview

The solution is contained within a Zynq-7000 system on chip, which contains both an ARM processor and programmable logic.

The ARM processor runs an embedded Linux,  booted from a SD card eventually containing the testing software and input files. These files describe the test information in a format specified in the documentation. They contain both the inputs to be provided to the device and the expected outputs. 

The testing software is in charge of parsing the input file, sending the test vectors to the DUT interface peripheral (which will apply them to the circuit) and comparing the received responses to the expected results. It controls and communicates with the DUT interface component by mapping its device file in its virtual space address.

The test vectors received by the DUT interface component through the AXI bus are stored in a memory block. This peripheral then retrieves each of these vectors, applies them to the DUT and saves the response in the same memory, which will subsequently be read by the testing software.

The circuit is interfaced with the testing system through a daughterboard which is connected to the FPGA's Mezzanine Connectors ([FMC](https://en.wikipedia.org/wiki/FPGA_Mezzanine_Card)). This board was developed for the Zynq-7000's ZC706 demonstration kit; however, since the aforementioned interface is standardized, it may be reutilised in another system containing the same connectors.

For more details, please refer to the project's documentation in the `doc` folder.

## Features

- Easy description of the DUT's pinout, of the vectors to be applied to it and of the expected responses through a JSON input - file provided to the testing software;
- Supports integrated circuits with up to 32 pins, each of which may be configured as input or output;
- Supports burst transfers between the testing software and the DUT interface block of up to 256 test vectors/results;
- The device's pins may be described as signals, each of which has a name and receives a value separately in the input file for clearer representation;
- Input file supports multi-bit signals for easy handling of numerical values (or for a more compact representation);
- For each test vector, an expected value may or may not be provided for each output signal, hence allowing don't-care terms and preparation vectors;
- Robust parser which detects and indicates possible inconsistencies and problems in the provided input files;
- Triggering of an external signal in the beginning of each test sequence to facilitate its visualization with an oscilloscope;
- Well-documented and reproducible project, which may be easily extended and adapted to any other board containing a Zynq-7000 system on chip.

## Source tree

The project files are organized as follows:

- `doc/`: project documentation
- `hardware/`
  - `ip/`: IP repository containing the DUT interface peripheral
  - `sim/`: simulation related files
  - `src/`: FPGA-related source files
    - `constrs/`: constraints file
    - `bd/`: board design files
  - `create-project.tcl`: TCL script to recreate Vivado project
- `sd/`: generated and compiled sw solution, ready to be booted and executed
- `sofware/`
  - `tico/`: testing software source files
    - `examples/`: examples of JSON input files
    - `test/`: test scripts and files for the software
  - `linux/`: embedded Linux related files
    - `linux-burst/`: PetaLinux project

## How to use

If you need to recreate the Vivado project, open Vivado, place yourself in the `hardware/` folder and type this command in the Tcl console:
```
run source create-project.tcl
```
The project will be created in `hardware/digital-tester`. The IP may need to be recreated through the Vivado wizard so that the BFM simulation is possible.

If you need to recompile the software you must have the proper ARM compiler (`arm-xilinx-linux-gnueabi-gcc`) installed and sourced (it usually comes with the Xilinx's tools). Once this is set up all you have to do is run `make`. 
In order to execute the software inside the embedded Linux environment the commands is:
```
./tico [-s -t] input-file.json
```
Where -s enables silent mode and -t enable time measurement. See the documentation for more details.

## Authors

- [@musse](https://github.com/msusse)
- [@mschuh](https://github.com/mschuh)
- [@jpmeireles](https://github.com/jpmeireles)

Don't hesitate to contact us if you need further information, if you would like to report bugs or just enjoy a good coffee :coffee:.
