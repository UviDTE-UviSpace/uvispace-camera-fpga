========================
DE1-SoC FPGA Design
========================

This folder contains the source files needed for compiling the FPGA project and obtaining binaries that can be uploaded to the board.

========================
Compilation instructions
========================

* Open Quartus (v16.0 Update 2). **Open project > soc_system.qpf**
* Open Qsys and **load soc_system.qsys**
* On Qsys, Select **Generate > Generate HDL...** De-select “Create block symbol file” option and specify desired HDL language (VHDL in my case). Press “Generate” button
* After generation ends, go to Quartus and press the **Start Analysis & Synthesis** button
* When synthesis ends, go to **Tools > Tcl scripts...** and run the scripts hps_sdram_p0_parameters.tcl and hps_sdram_p0_pin_assignments.tcl. Wait for confirmation pop-up window.
* Perform again the **Analysis & Synthesis** of the project
* Run the **Fitter (Place & Route)** utility
* Run the **Assembler (Generate programming files)** utility

**NOTE:** The last 3 steps could be run altogether pressing the “Start Compilation” button

====================================
Generate hardware address map header
====================================

For generating the header, firstly  the DS-5 *embedded_command_shell* must be executed. Then, the following instruction can be run from the project root directory, and it will generate a header file describing the HPS address map. It can be used by an HPS C/C++ program to get base addresses of the FPGA 
peripherals.

.. code-block:: bash

    $ sopc-create-header-files --single hps_0.h --module hps_0

After running it, a header named *hps_0.h* will be generated on the current directory.
