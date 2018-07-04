=================
ip folder content
=================

This folder contains the contains all the low and high level hardware blocks implemented
in the FPGA.

==================
7_segment_displays
==================

Implements the hardware block in charge of showing the frame rate in a 7-segment display.

====================
avalon_image_writter
====================

Contains all the files of the avalon_image_writer harware block. Contains the following elements:

* **avalon_image_writer_simultaion** include the all the avalon_image_writer simulation required files.
* **avalon_image_writer.vhd** implements the avalon_image_writer hardware block.
* **avalon_image_writer_hw.tcl** creates the qsys component from the avalon_image_writer.vhd file.

=================
camera_controller
=================

Contains all the files involved in the raw image acquisition and its transformation to a RGB image. Contains the following elements:

* **config_controller** contains the Camera Config. hardware block an its components.
* **frame_sync** contains the frame_sync.vhd hardware block and its simulation required files.
* **raw2rgb** contains the raw2rgb.vhd hardware block and its simulation required files.
* **avalon_camera.v** implements de Avalon Camera hardware block.
* **avalon_camera_hw.tcl** creates the qsys component from the avalon_camera.v file.
* **camera_capture.v** implements de Camera Capture hardware block.
* **camera_core.qip** instantiates the raw2rgb,the frame_sync and morphological_fifo (common folder) hardware blocks.

======
common
======

Contains a set of hardware blocks instantiated by other low level hardware blocks

* **bin2bcd** folder that contains the blocks in charge of show the frame rate in decimal (instead hexadecimal) in the 7-segment displays.
* **double_port_ram** folder that contains the blocks in charge of the implentation of the double port ram required to use the 10kbit RAM resources as a FIFO memory. It also include the simulation required files.
* **morphological_fifo** folder that contains the blocks in charge the morphological_fifo implementation (.vhd) and its simulation.
* **shift_reg_ram** folder that contains the blocks in charge of the implentation of a shift register memory based on a double port ram. It also include the simulation required files.
* **array_package.vhd** defines special array types, used in the project.
* **common.qip** instantiates all the hardware blocks contained in the common folder.

================
image_processing
================

Contains all the hardware blocks contained in the image_processing blocks the
following elements:

* **Morphological:** folder that contains the blocks responsible for erosion and dilatation. Includes each block implementation (.vhd), each block required files for the individual simulation and the file that instantiates both blocks (morphological.qip).
* **avalon_image_procesing.vhd** implements the avalon_image_procesing hardware block.
* **avalon_image_procesing_hw.tcl** creates the qsys component from the avalon_image_procesing.vhd file.
* **hsv2bin.vhd** implements the HSV to binary hardware conversion block.
* **image_processing.qip** instantiates all the hardware blocks contained in the image processing block.
* **image_processing.vhd** implements the Image processing hardware blocks.
* **rgbgray.vhd** implements the RGB to Gray hardware conversion block.
* **rgb2hsv.v** implements the RGB to HSV hardware conversion block.

================
sdram_controller
================

Implements a sdram dual port and dual clock memory, which the VGA needs for its operation

==============
vga_controller
==============

Contains the VGA controller block

==============
uvispace_top.v
==============

Verilog top level file that implements all the Uvispace hardware blocks.
