===========================
de0-nano-soc folder content
===========================

This folder contains the contains all the files required to implement the
uvispace-camera-fpga/ip hardware blocks in the DE0-Nano-SoC board.

Contains the following files:

* **qsys_ip_paths.ipx** let Platform Designer System find the path of the ip folder
* **soc_system.qpf** Quartus project file
* **soc_system.qsf** settings file, defines: the FPGA, Quartus version, pines assignment, files that take part in the projects, etc.
* **soc_system.qsys** Defines the connections implented in Platform Designer System.
* **soc_system_assignment_defaults.qdf** Necessary to the compilation, contains HPS directives.
* **uvispce_top_de0_nano_soc.v** inserts Uvispace top level, shared by all the boards, and connects it to the DE0-Nano-SoC pines.
