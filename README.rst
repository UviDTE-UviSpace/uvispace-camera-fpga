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
* After generation ends, go to Quartus and press the *Start Analysis & Synthesis** button
* When synthesis ends, go to **Tools > Tcl scripts...** and run the scripts hps_sdram_p0_parameters.tcl and hps_sdram_p0_pin_assignments.tcl. Wait for confirmation pop-up window.
* Perform again the **Analysis & Synthesis** of the project
* Run the **Fitter (Place & Route)** utility
* Run the **Assembler (Generate programming files)** utility

**NOTE:** The last 3 steps could be run altogether pressing the “Start Compilation” button