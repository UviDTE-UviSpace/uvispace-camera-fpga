============================
Uvispace camera FPGA project
============================

This folder contains the source files needed for compiling the FPGA project of the Uvispace camera.
Compile using Qsys and Quartus to obtain binaries that can be uploaded to the
boards.

Current board supported: **DE1-SoC** and **DE0-nano-SoC**.

Current cameras supported: **Terasic TRDB-D5M**.

===================
Repository contents
===================
* de0-nano-soc: Quartus and Qsys project for DE0-nano-SoC board.
* de1-soc: Quartus and Qsys project for DE1-SoC board.
* ip: ip cores common to all boards.
* 5mpix-camera-calculator: excel sheet summarizing the rules in the user manual of the TRDB-D5M camera.

========================
Compilation instructions
========================

* Open Quartus (v16.0 Update 2). **Open project > de0-nano-soc/soc_system.qpf** or **Open project > de1-soc/soc_system.qpf** depending on the board you compile for.
* Open Qsys and **load soc_system.qsys**
* In Qsys, Select **Generate > Generate HDL...** De-select “Create block symbol file” option and specify desired HDL language (VHDL in my case). Press “Generate” button
* After generation ends, go to Quartus and press the **Start Analysis & Synthesis** button
* When synthesis ends, go to **Tools > Tcl scripts...** and run the scripts hps_sdram_p0_parameters.tcl and hps_sdram_p0_pin_assignments.tcl. Wait for confirmation pop-up window.
* Perform again the **Analysis & Synthesis** of the project
* Run the **Fitter (Place & Route)** utility
* Run the **Assembler (Generate programming files)** utility

**NOTE:** The last 3 steps could be run altogether pressing the “Start Compilation” button

====================================
Generate hardware address map header
====================================

For generating the header file with address map of the Qsys components, open SoC *embedded_command_shell* instaled when installing quartus. Then, the following instruction can be run from the project root directory, and it will generate a header file describing the HPS address map. It can be used by an HPS C/C++ program to get base addresses of the FPGA peripherals.

.. code-block:: bash

    $ sopc-create-header-files --single hps_0.h --module hps_0

After running it, a header named *hps_0.h* will be generated on the current directory.
