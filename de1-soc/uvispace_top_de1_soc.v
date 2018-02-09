/*
This is the top level design for the DE1-SoC boards of UviSpace project.

In instantiates uvispace_top component that contains all code common to 
different board. Later, since the DE1-SoC has VGA, it implements the
components needed to visualize the different images (rgb, raw binary,
binary after erosion and binary after erosion and dilation)through
VGA:
- Sdram_Control: This module is used for connecting to the external DRAM
memory and use it as a buffer between the camera input and the VGA
output, as both are run with different clock rates (camera runs at 96MHz
while VGA part at 25.125MHz). For this purpose,
FIFO memories allowing simultaneous read and write operations are used
The camera goes writing at one side and tyhe VGA goes reading and printing
in the screen from the other.There are 2 fifos of 16bits each so up
to 32-bit pixels can be saved here. However the second fifo doesnt work for
unknown reason so only the 1st is used. This is no problem for gray and 
binary images that are 8-bit each but it is a problem for RGA cause
3 components x 8-bit = 24-bit. To visualize RGB a trick was used saving
only 5 of the 8 bits of each RGB componentcause 3 x 5 = 15 and fit in the
16-bit of the 1st fifo.
- vga_controller: Module for sending control bits to the VGA peripheral.
The module has a set of parameters that defines the output resolution,
being by default 640x480.
- SEG7_LUT_8: This componet is used for showing the frame rate on the
hexadecimal 8-segments peripherals.
*/

`define ENABLE_HPS

//============================================================================
//Top level entity for DE1-SoC board
//============================================================================
module uvispace_top_de1_soc(
  //DE1-SoC pins:
  ///////// ADC /////////
  inout              ADC_CS_N,
  output             ADC_DIN,
  input              ADC_DOUT,
  output             ADC_SCLK,
  ///////// AUD /////////
  input              AUD_ADCDAT,
  inout              AUD_ADCLRCK,
  inout              AUD_BCLK,
  output             AUD_DACDAT,
  inout              AUD_DACLRCK,
  output             AUD_XCK,
  ///////// CLOCK2 /////////
  input              CLOCK2_50,
  ///////// CLOCK3 /////////
  input              CLOCK3_50,
  ///////// CLOCK4 /////////
  input              CLOCK4_50,
  ///////// CLOCK /////////
  input              CLOCK_50,
  ///////// DRAM /////////
  output      [12:0] DRAM_ADDR,   //Address Bus
  output      [1:0]  DRAM_BA,     //Bank address
  output             DRAM_CAS_N,  //Column address strobe
  output             DRAM_CKE,    //Clock enable
  output             DRAM_CLK,    //Clock
  output             DRAM_CS_N,   //Chip select
  inout       [15:0] DRAM_DQ,     //Data Bus
  output             DRAM_LDQM,   //Low-byte data mask
  output             DRAM_RAS_N,  //Row adress strobe
  output             DRAM_UDQM,   //High-byte data mask
  output             DRAM_WE_N,   //Write enable
  ///////// FAN /////////
  output             FAN_CTRL,
  ///////// FPGA /////////
  output             FPGA_I2C_SCLK,
  inout              FPGA_I2C_SDAT,
  ///////// GPIO /////////
  inout       [35:0] GPIO_0,
  inout       [35:0] GPIO_1,
  ///////// HEX /////////
  output      [6:0]  HEX0,
  output      [6:0]  HEX1,
  output      [6:0]  HEX2,
  output      [6:0]  HEX3,
  output      [6:0]  HEX4,
  output      [6:0]  HEX5,
  ///////// HPS /////////
  `ifdef ENABLE_HPS
    inout              HPS_CONV_USB_N,
    output      [14:0] HPS_DDR3_ADDR,
    output      [2:0]  HPS_DDR3_BA,
    output             HPS_DDR3_CAS_N,
    output             HPS_DDR3_CKE,
    output             HPS_DDR3_CK_N,
    output             HPS_DDR3_CK_P,
    output             HPS_DDR3_CS_N,
    output      [3:0]  HPS_DDR3_DM,
    inout       [31:0] HPS_DDR3_DQ,
    inout       [3:0]  HPS_DDR3_DQS_N,
    inout       [3:0]  HPS_DDR3_DQS_P,
    output             HPS_DDR3_ODT,
    output             HPS_DDR3_RAS_N,
    output             HPS_DDR3_RESET_N,
    input              HPS_DDR3_RZQ,
    output             HPS_DDR3_WE_N,
    output             HPS_ENET_GTX_CLK,
    inout              HPS_ENET_INT_N,
    output             HPS_ENET_MDC,
    inout              HPS_ENET_MDIO,
    input              HPS_ENET_RX_CLK,
    input       [3:0]  HPS_ENET_RX_DATA,
    input              HPS_ENET_RX_DV,
    output      [3:0]  HPS_ENET_TX_DATA,
    output             HPS_ENET_TX_EN,
    inout              HPS_GSENSOR_INT,
    inout              HPS_I2C1_SCLK,
    inout              HPS_I2C1_SDAT,
    inout              HPS_I2C_CONTROL,
    inout              HPS_KEY,
    inout              HPS_LED,
    inout              HPS_LTC_GPIO,
    output             HPS_SD_CLK,
    inout              HPS_SD_CMD,
    inout       [3:0]  HPS_SD_DATA,
    input              HPS_UART_RX,
    output             HPS_UART_TX,
    input              HPS_USB_CLKOUT,
    inout       [7:0]  HPS_USB_DATA,
    input              HPS_USB_DIR,
    input              HPS_USB_NXT,
    output             HPS_USB_STP,
  `endif /*ENABLE_HPS*/
  ///////// IRDA /////////
  input              IRDA_RXD,
  output             IRDA_TXD,
  ///////// KEY /////////
  input       [3:0]  KEY,
  ///////// LEDR /////////
  output      [9:0]  LEDR,
  ///////// PS2 /////////
  inout              PS2_CLK,
  inout              PS2_CLK2,
  inout              PS2_DAT,
  inout              PS2_DAT2,
  ///////// SW /////////
  input       [9:0]  SW,
  ///////// TD /////////
  input              TD_CLK27,
  input       [7:0]  TD_DATA,
  input              TD_HS,
  output             TD_RESET_N,
  input              TD_VS,
  ///////// VGA /////////
  output      [7:0]  VGA_B,
  output             VGA_BLANK_N,
  output             VGA_CLK,
  output      [7:0]  VGA_G,
  output             VGA_HS,
  output      [7:0]  VGA_R,
  output             VGA_SYNC_N,
  output             VGA_VS
  );

//============================================================================
//  REG/WIRE declarations
//============================================================================
  wire          sync_rgb_dval;
  wire  [11:0]  sync_rgb_red;
  wire  [11:0]  sync_rgb_green;
  wire  [11:0]  sync_rgb_blue;
  wire  [7:0]   gray;
  wire          gray_valid;
  wire          bin_valid;
  wire  [7:0]   binarized_8bit;
  wire          erosion_valid;
  wire  [7:0]   eroded_8bit;
  wire          dilation_valid;
  wire  [7:0]   dilated_8bit;
  wire          video_stream_reset_n;
  wire          hps2fpga_reset_n;
  wire          clk_25;
  wire          ccd_pixel_clk;
  wire  [31:0]  rate;

//============================================================================
//  Structural coding
//============================================================================

uvispace_top u0 (

  ///////// CLOCK /////////
  .CLOCK_50(CLOCK_50),
  ///////// HPS /////////
  .HPS_CONV_USB_N             (HPS_CONV_USB_N),
  .HPS_DDR3_ADDR              (HPS_DDR3_ADDR),
  .HPS_DDR3_BA                (HPS_DDR3_BA),
  .HPS_DDR3_CAS_N             (HPS_DDR3_CAS_N),
  .HPS_DDR3_CKE               (HPS_DDR3_CKE),
  .HPS_DDR3_CK_N              (HPS_DDR3_CK_N),
  .HPS_DDR3_CK_P              (HPS_DDR3_CK_P),
  .HPS_DDR3_CS_N              (HPS_DDR3_CS_N),
  .HPS_DDR3_DM                (HPS_DDR3_DM),
  .HPS_DDR3_DQ                (HPS_DDR3_DQ),
  .HPS_DDR3_DQS_N             (HPS_DDR3_DQS_N),
  .HPS_DDR3_DQS_P             (HPS_DDR3_DQS_P),
  .HPS_DDR3_ODT               (HPS_DDR3_ODT),
  .HPS_DDR3_RAS_N             (HPS_DDR3_RAS_N),
  .HPS_DDR3_RESET_N           (HPS_DDR3_RESET_N),
  .HPS_DDR3_RZQ               (HPS_DDR3_RZQ),
  .HPS_DDR3_WE_N              (HPS_DDR3_WE_N),
  .HPS_ENET_GTX_CLK           (HPS_ENET_GTX_CLK),
  .HPS_ENET_INT_N             (HPS_ENET_INT_N),
  .HPS_ENET_MDC               (HPS_ENET_MDC),
  .HPS_ENET_MDIO              (HPS_ENET_MDIO),
  .HPS_ENET_RX_CLK            (HPS_ENET_RX_CLK),
  .HPS_ENET_RX_DATA           (HPS_ENET_RX_DATA),
  .HPS_ENET_RX_DV             (HPS_ENET_RX_DV),
  .HPS_ENET_TX_DATA           (HPS_ENET_TX_DATA),
  .HPS_ENET_TX_EN             (HPS_ENET_TX_EN),
  .HPS_GSENSOR_INT            (HPS_GSENSOR_INT),
  .HPS_I2C1_SCLK              (HPS_I2C1_SCLK),
  .HPS_I2C1_SDAT              (HPS_I2C1_SDAT),
  .HPS_I2C_CONTROL            (HPS_I2C_CONTROL),
  .HPS_KEY                    (HPS_KEY),
  .HPS_LED                    (HPS_LED),
  .HPS_LTC_GPIO               (HPS_LTC_GPIO),
  .HPS_SD_CLK                 (HPS_SD_CLK),
  .HPS_SD_CMD                 (HPS_SD_CMD),
  .HPS_SD_DATA                (HPS_SD_DATA),
  .HPS_UART_RX                (HPS_UART_RX),
  .HPS_UART_TX                (HPS_UART_TX),
  .HPS_USB_CLKOUT             (HPS_USB_CLKOUT),
  .HPS_USB_DATA               (HPS_USB_DATA),
  .HPS_USB_DIR                (HPS_USB_DIR),
  .HPS_USB_NXT                (HPS_USB_NXT),
  .HPS_USB_STP                (HPS_USB_STP),

  ///////// CAMERA CONNECTOR ////////
  .CAM_CONNECTOR              (GPIO_1),

  //----SIGNALS TO GENRATE VGA OUTPUT (ONLY IN DE1-SOC)----/

  //RGB image from the synchronyzer
  .export_sync_rgb_red         ( sync_rgb_red ),
  .export_sync_rgb_green       ( sync_rgb_green ),
  .export_sync_rgb_blue        ( sync_rgb_blue ),
  .export_sync_rgb_dval        ( sync_rgb_dval ),
  //Gray image
  .export_gray                 ( gray ),
  .export_gray_valid           ( gray_valid ),
  //Binarized image from the HSV to Binary converter
  .export_binarized_8bit       ( binarized_8bit ),
  .export_bin_valid            ( bin_valid ),
  //Eroded binary image
  .export_eroded_8bit          ( eroded_8bit ),
  .export_erosion_valid        ( erosion_valid ),
  //Eroded and dilated binary image
  .export_dilated_8bit         ( dilated_8bit ),
  .export_dilation_valid       ( dilation_valid ),
  //clock and resets for the VGA
  .export_ccd_pixel_clk        ( ccd_pixel_clk ),
  .export_clk_25               ( clk_25 ),
  .export_hps2fpga_reset_n     ( hps2fpga_reset_n ),
  .export_video_stream_reset_n ( video_stream_reset_n ),

  //////FRAME RATE IN BINARY, TO 7 SEGMENT DISPLAYS////
  .export_rate                 ( rate ),
  /////PULSE_LED////
  .pulse_led                   ( LEDR[0] ),
  /////RESET_STREAM_N/////
  .reset_stream_key            ( KEY[0] ),
  ////EN_CAM_CAPTURE/////
  .camera_capture_en           ( !SW[9] )
  );




//=======================================================
//  Structural coding
//=======================================================

  //-------------------------VGA------------------------//
// On each camera cycle (defined by the pixel clock), the 3 components (RGB)
  // of a pixel are written to 2 FIFOs on the SDRAM memory. As the VGA controller
  // can take only 1 byte per component, only the 8 most significative bits of
  // each 'raw' component are sent to the 2 FIFOs created in the SDRAM.
  // In case that only one FIFO memory is used, only the 5 most significative
  // bits of each component are sent to the SDRAM.
  always @(posedge ccd_pixel_clk) begin
    if (!hps2fpga_reset_n & video_stream_reset_n) begin
      // if reset, do nothing.
    end
    else begin
      if (SW[5]) begin
        fifo1_writedata <= {8'h00, dilated_8bit[7:0]};
        fifo_write_enable <= dilation_valid;
		  rgb_in_vga <= 1'b0;
      end
    else if (SW[4])
    begin
	     fifo1_writedata <= {8'h00, eroded_8bit[7:0]};
        fifo_write_enable <= erosion_valid;
		  rgb_in_vga <= 1'b0;
    end
    else if (SW[3])
    begin
       fifo1_writedata <= {8'h00, binarized_8bit[7:0]};
       fifo_write_enable <= bin_valid;
		 rgb_in_vga <= 1'b0;
    end
    else begin
		 fifo1_writedata <= {1'b0, sync_rgb_red[11:7], sync_rgb_green[11:7],
                            sync_rgb_blue[11:7]};
       fifo_write_enable <= sync_rgb_dval;
		 rgb_in_vga <= 1'b1;
    end
    end
  end

// Dual clock SDRAM controller, based on DE1-SOC demonstration
Sdram_Control u1(
  // HOST Side
  .REF_CLK(CLOCK_50),
  .RESET_N(1'b1),
  // FIFO Write Side 1
  .WR1_DATA(fifo1_writedata),         //data bus size: 16 bits
  .WR1(fifo_write_enable),
  .WR1_ADDR(0),
  .WR1_MAX_ADDR(640*480),             //address bus size: 25 bits
  .WR1_LENGTH(9'h80),                 //Max allowed size: 8 bits
  .WR1_LOAD(!(hps2fpga_reset_n & video_stream_reset_n)),
  .WR1_CLK(~ccd_pixel_clk),
  // FIFO Write Side 2 (Unused. Needed if 8 bits per pixel are used)
  .WR2_DATA(fifo1_writedata),         //data bus size: 16 bits
  .WR2(fifo_write_enable),
  .WR2_ADDR(22'h100000),
  .WR2_MAX_ADDR(22'h100000+640*480),  //address bus size: 25 bits
  .WR2_LENGTH(9'h80),                 //Max allowed size: 8 bits
  .WR2_LOAD(!(hps2fpga_reset_n & video_stream_reset_n)),
  .WR2_CLK(~ccd_pixel_clk),
  // FIFO Read Side 1
  .RD1_DATA(fifo1_readdata),          //data bus size: 16 bits
  .RD1(vga_enable),                   //Read enable
  .RD1_ADDR(0),
  .RD1_MAX_ADDR(640*480),             //address bus size: 25 bits
  .RD1_LENGTH(9'h80),                 //Max allowed size: 8 bits
  .RD1_LOAD(!(hps2fpga_reset_n & video_stream_reset_n)),
  .RD1_CLK(~clk_25),
  // FIFO Read Side 2 (Unused. Needed if 8 bits per pixel are used)
  .RD2_DATA(fifo2_readdata),          //data bus size: 16 bits
  .RD2(vga_enable),                   //Read enable
  .RD2_ADDR(22'h100000),
  .RD2_MAX_ADDR(22'h100000+640*480),  //address bus size: 25 bits
  .RD2_LENGTH(9'h80),                 //Max allowed size: 8 bits
  .RD2_LOAD(!(hps2fpga_reset_n & video_stream_reset_n)),
  .RD2_CLK(~clk_25),
  // SDRAM Side
  .SA(DRAM_ADDR),
  .BA(DRAM_BA),
  .CS_N(DRAM_CS_N),
  .CKE(DRAM_CKE),
  .RAS_N(DRAM_RAS_N),
  .CAS_N(DRAM_CAS_N),
  .WE_N(DRAM_WE_N),
  .DQ(DRAM_DQ),
  .DQM({DRAM_UDQM,DRAM_LDQM}),
  .SDR_CLK(DRAM_CLK)
  );
  reg    fifo_write_enable;
  //SDRAM FIFOs data
  reg     [15:0] fifo1_writedata;
  reg     [15:0] fifo2_writedata;
  wire    [15:0] fifo1_readdata;
  wire    [15:0] fifo2_readdata;

// VGA controller component.
vga_controller vga_component(
  .pixel_clk  ( clk_25 ),
  .reset_n    ( hps2fpga_reset_n & video_stream_reset_n ),
  .h_sync     ( VGA_HS ),
  .v_sync     ( VGA_VS ),
  .disp_ena   ( vga_enable ),
  .column     (),
  .row        (),
  .n_blank    ( VGA_BLANK_N ),
  .n_sync     ( VGA_SYNC_N ),
  .data_req   ( vga_request )
  );
  //VGA signals
  wire    vga_enable;
  reg 	 rgb_in_vga;

  // Send the data on the FIFO memory to the VGA outputs.
  assign VGA_R = (!vga_enable) ? 0 :
                 (!rgb_in_vga) ? fifo1_readdata[7:0] :
                 (SW[0])       ? {fifo1_readdata[14:10], 3'd0} :
                 0;
  assign VGA_G = (!vga_enable) ? 0 :
                 (!rgb_in_vga) ? fifo1_readdata[7:0] :
                 (SW[1])       ? {fifo1_readdata[9:5], 3'd0} :
                 0;
  assign VGA_B = (!vga_enable) ? 0 :
                 (!rgb_in_vga) ? fifo1_readdata[7:0] :
                 (SW[2])       ? {fifo1_readdata[4:0], 3'd0} :
                 0;
  // Set the VGA clock to 25 MHz.
  assign  VGA_CLK = clk_25;


//------------------7 segments Displays----------------//
/*
Instantiation of the 7-segment displays moduleto showframe rate
*/
SEG7_LUT_8 u5(
  .oSEG0        (HEX0),
  .oSEG1        (HEX1),
  .oSEG2        (HEX2),
  .oSEG3        (HEX3),
  .oSEG4        (HEX4),
  .oSEG5        (HEX5),
  .oSEG6        (),
  .oSEG7        (),
  .iDIG         (rate)
  );

endmodule
