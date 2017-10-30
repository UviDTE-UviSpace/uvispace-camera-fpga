================================
uvispace-camera-fpga/simulations
================================

This folder contains Quartus II projects that simulate some of the components developed for Uvispace fpga camera.

Folders content
===============
The components that have simulation are:

* avalon_image_writer: this component takes the raw pixels from the camera, packs them into a word. When the word is full it writes the pixels into a avalon memory-mapped master port. It is used in Uvispace to write images from FPGA into processors memory.

Inside each simulation folder there is:

* <component_name>.qpf: Quartus project file, containing files involved in the project, some configurations of Quartus , etc.
* <component_name>.qsf: Quartus settings file, target device, describes the simulation (using Nativelink flow), etc.
* <component_name>.vhd: VHDL file describing the component behaviour.
* simulation/modelsim<component_name>.vht: file describing the simulation to be done to the component.

How to run the simulations
==========================
* Install Quartus (We used v16.0 Update 2) and Model Sim Intel-FPGA edition.
* Open Quartus . **Open project -> <component_name>.qpf**
* Run Processing -> Start -> Analysis&Synthesis.
* Run simulation doing: Tools -> Run Simulation Tool -> RTL Simulation. Modelsim should open and the Wave with the simulation should automatically appear.


