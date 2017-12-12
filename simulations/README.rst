================================
uvispace-camera-fpga/simulations
================================

This folder contains Quartus II projects that simulate some of the components developed for Uvispace fpga camera.

Folders content
===============
The components that have simulation are:

* avalon_image_writer: this component takes the raw pixels from the camera, packs them into a word. When the word is full it writes the pixels into a avalon memory-mapped master port. It is used in Uvispace to write images from FPGA into processors memory.
* dilation_bin: applies the morphological operation of dilation to a binary image.
* erosion_bin: applies the morphological operation of erosion to a binary image.
* frame_sync: used after raw2rgb component to skip some frames after reset and wait VGA to start up so images images in VGA start synchronized. Otherwise they would appear shiffted sometimes.
* morphological_fifo: memory that saves the pixels needed to perform a morphological operation. Its output is the moving window needed in these kind of operations. It is used by dilation_bin and erosion_bin.

Inside each simulation folder there is:

* <component_name>.qpf: Quartus project file, containing files involved in the project, some configurations of Quartus , etc.
* <component_name>.qsf: Quartus settings file, target device, describes the simulation (using Nativelink flow), etc.
* <component_name>.vhd: VHDL file describing the component behaviour.
* simulation/modelsim<component_name>.vht: test bench file describing the simulation to be done to the component.

How to run the simulations
==========================
* Install Quartus (We used v16.0 Update 2) and Model Sim Intel-FPGA edition.
* Open Quartus . **Open project -> <component_name>.qpf**
* Run Processing -> Start -> Analysis&Synthesis.
* Run simulation doing: Tools -> Run Simulation Tool -> RTL Simulation. Since the project files are configured for Nativelink work flow with test bench file prepared, Modelsim should open and the Wave with the simulation should automatically appear.
