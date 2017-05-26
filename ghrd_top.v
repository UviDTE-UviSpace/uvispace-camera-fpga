/*
This is the top level design for the DE1-SoC boards of UviSpace project.

The ghrd_top() module; hps processor instantiation and connection; and
the connection of the module's input/output signals to the corresponding
pins were obtained from the Terasic DE1-SoC Golden Hardware Reference
Design (GHRD) project. For more information about this basic project and
the board, you can visit their website (http://www.terasic.com/).

Some of the remaining modules are based on demonstrations provided by 
Terasic for the DE1-Soc and the DM5 Camera.

The purpose of the design is to provide an FPGA circuit for configuring
and acquiring images from a camera attached to the GPIO1 port. Hence,
the following modules are used:

- soc_system_u0: This module provides an interface with the Qsys design.
The main component is the interface with the HPS processor and its main
peripherals. Moreover, there are the following Qsys components: led_pio,
dipsw_pio (for the switches), button_pio, clk_0, and pll_vga_clks.
- CCD_Capture: This module serves as an interface with the attached
camera. It reads pixels values and control inputs. Besides, it allows to
decide when to start and stop acquiring images. The clock input is fed
by the pixel clock.
- RAW2RGB: It formats the raw data obtained from the camera peripheral
to RGB values. Each pixel contains 3 components (Red, Green and Blue),
defined by 12 bits each one.
- rgb2hue: Gets the Hue component of the pixels from an RGB input. The
Hue is a very useful value for evaluating the colour properties of an
image, and thus for getting a red triangle in the image.
- Sdram_Control: This module is used for connecting to the external DRAM
memory and use it as a buffer between the camera input and the VGA
output, as both are run with different clock rates. For this purpose,
FIFO memories allowing simultaneous read and write operations are used.
- vga_controller: Module for sending control bits to the VGA peripheral.
The module has a set of parameters that defines the output resolution,
being by default 640x480.
- SEG7_LUT_8: This componet is used for showing the fram rate on the
hexadecimal 8-segments peripherals.
- camera_config: This module sends the default configuration to the
camera using the I2C standard.

NOTE: The desired design should have 2 FIFOs, in order to send 8 bits
per component to the VGA controller. However, there is a synchronization
error, and the values obtained in the second FIFO have an offset
relative to the first one i.e. The component sent by the second FIFO
corresponds to the one that was sent by the first one several iterations
ago, resulting on an horizontal shift. For this reason, the size per
pixel was reduced to 15 bits (1 zero and 5 bits per colour).
*/

`define ENABLE_HPS

//Top level entity. Contains the inputs and outputs wired to external pins.
module ghrd_top(
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
    inout       [3:0]  HPS_FLASH_DATA,
    output             HPS_FLASH_DCLK,
    output             HPS_FLASH_NCSO,
    inout              HPS_GSENSOR_INT,
    inout              HPS_I2C1_SCLK,
    inout              HPS_I2C1_SDAT,
    inout              HPS_I2C2_SCLK,
    inout              HPS_I2C2_SDAT,
    inout              HPS_I2C_CONTROL,
    inout              HPS_KEY,
    inout              HPS_LED,
    inout              HPS_LTC_GPIO,
    output             HPS_SD_CLK,
    inout              HPS_SD_CMD,
    inout       [3:0]  HPS_SD_DATA,
    output             HPS_SPIM_CLK,
    input              HPS_SPIM_MISO,
    output             HPS_SPIM_MOSI,
    inout              HPS_SPIM_SS,
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

//=======================================================
//  REG/WIRE declarations
//=======================================================

//HPS signals
wire    hps2fpga_reset_n;
wire 	  camera_soft_reset_n;
wire 	  video_stream_reset_n;
wire    clk_25;
wire    clk_193;
wire    clk_120;
wire    clk_24;
//VGA signals
wire    vga_enable;
integer vga_row;
integer vga_col;
//CCD peripheral signal
wire	  [11:0] CCD_DATA;
//CCD_Capture signals
wire    [11:0] ccd_data_captured;		//output data from CCD_Capture
wire				ccd_dval;            //valid output data
wire    [15:0] X_Cont;
wire	  [15:0] Y_Cont;
reg     [11:0] ccd_data_raw;		    //input raw data to CCD_Capture
reg            ccd_fval_raw;		    //frame valid
reg            ccd_lval_raw;		    //line valid
wire           ccd_pixel_clk;
wire           ccd_reset;
wire    [31:0] Frame_Cont;
//RAW2RGB signals
wire    [11:0] raw_rgb_red;
wire    [11:0] raw_rgb_green;
wire    [11:0] raw_rgb_blue;
wire           raw_rgb_dval;        //valid output data
//SDRAM FIFOs data
reg     [15:0] fifo1_writedata;
reg     [15:0] fifo2_writedata;
wire    [15:0] fifo1_readdata;
wire    [15:0] fifo2_readdata;

//=======================================================
//  Structural coding
//=======================================================
soc_system u0 (      
  //Input clocks
  .clk_50_clk                            ( CLOCK_50 ),
  .ccd_pixel_clock_bridge_clk				     ( ccd_pixel_clk ),
  //Output clocks
  .pll_vga_clks_25_clk                   ( clk_25 ),
  .pll_vga_clks_191_clk                  ( clk_193 ),
  .pll_camera_clks_24_clk                ( clk_24 ), 
	//HPS reset output 
  .h2f_reset_reset_n                     ( hps2fpga_reset_n ),
  // Avalon camera capture_image signals
  .avalon_camera_export_start_capture    ( start_capture ),
  .avalon_camera_export_capture_width    ( capture_width ), 
  .avalon_camera_export_capture_height   ( capture_height ),   
  .avalon_camera_export_buff0            ( capture_buff0 ), 
  .avalon_camera_export_buff1            ( capture_buff1 ), 
  .avalon_camera_export_buff0full        ( capture_buff0full ),
  .avalon_camera_export_buff1full        ( capture_buff1full ), 
  .avalon_camera_export_capture_standby  ( capture_standby ), 
	// Avalon camera camera_config signals  
  .avalon_camera_export_width            ( in_width ),
  .avalon_camera_export_height           ( in_height ),
  .avalon_camera_export_startrow         ( start_row ),
  .avalon_camera_export_startcol         ( start_column ),
  .avalon_camera_export_colmode          ( in_column_mode ),
  .avalon_camera_export_exposure         ( in_exposure ),
  .avalon_camera_export_rowsize          ( in_row_size ),
  .avalon_camera_export_colsize          ( in_column_size ),
  .avalon_camera_export_rowmode          ( in_row_mode ),
  .avalon_camera_export_soft_reset_n     ( camera_soft_reset_n ),
  // Bus for the image_capture component to write images in HPS-OCR
  .avalon_write_bridge_0_avalon_slave_address     ( image_capture_address ),  
  .avalon_write_bridge_0_avalon_slave_write       ( image_capture_write ),     
  .avalon_write_bridge_0_avalon_slave_byteenable  ( image_capture_byteenable ), 
  .avalon_write_bridge_0_avalon_slave_writedata   ( image_capture_write_data ), 
  .avalon_write_bridge_0_avalon_slave_waitrequest ( image_capture_waitrequest), 
  .avalon_write_bridge_0_avalon_slave_burstcount  ( image_capture_burstcount ),  
  //HPS ddr3
  .memory_mem_a                          ( HPS_DDR3_ADDR ),
  .memory_mem_ba                         ( HPS_DDR3_BA ),
  .memory_mem_ck                         ( HPS_DDR3_CK_P ),
  .memory_mem_ck_n                       ( HPS_DDR3_CK_N ),
  .memory_mem_cke                        ( HPS_DDR3_CKE ),
  .memory_mem_cs_n                       ( HPS_DDR3_CS_N ),
  .memory_mem_ras_n                      ( HPS_DDR3_RAS_N ),
  .memory_mem_cas_n                      ( HPS_DDR3_CAS_N ),
  .memory_mem_we_n                       ( HPS_DDR3_WE_N ),
  .memory_mem_reset_n                    ( HPS_DDR3_RESET_N) ,
  .memory_mem_dq                         ( HPS_DDR3_DQ ),
  .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N ),
  .memory_mem_dqs                        ( HPS_DDR3_DQS_P ),     
  .memory_mem_odt                        ( HPS_DDR3_ODT ),
  .memory_mem_dm                         ( HPS_DDR3_DM ),
  .memory_oct_rzqin                      ( HPS_DDR3_RZQ ),
  //HPS ethernet		   
  .hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK ),
  .hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),
  .hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),
  .hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),
  .hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),
  .hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),
  .hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),
  .hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC ),
  .hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV ),
  .hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN ),
  .hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK ),
  .hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),
  .hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),
  .hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),
  //HPS QSPI  
  .hps_0_hps_io_hps_io_qspi_inst_IO0     ( HPS_FLASH_DATA[0] ),
  .hps_0_hps_io_hps_io_qspi_inst_IO1     ( HPS_FLASH_DATA[1] ),
  .hps_0_hps_io_hps_io_qspi_inst_IO2     ( HPS_FLASH_DATA[2] ),
  .hps_0_hps_io_hps_io_qspi_inst_IO3     ( HPS_FLASH_DATA[3] ),
  .hps_0_hps_io_hps_io_qspi_inst_SS0     ( HPS_FLASH_NCSO ),
  .hps_0_hps_io_hps_io_qspi_inst_CLK     ( HPS_FLASH_DCLK ),
  //HPS SD card
  .hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD ),
  .hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0] ),
  .hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1] ),
  .hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK ),
  .hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2] ),
  .hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3] ),
  //HPS USB     
  .hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0] ),
  .hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1] ),
  .hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2] ),
  .hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3] ),
  .hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4] ), 
  .hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5] ),
  .hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6] ),
  .hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7] ),
  .hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT ),
  .hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP ),
  .hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR ),
  .hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT ),
  //HPS SPI
  .hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK ),
  .hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),
  .hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),
  .hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS ),
  //HPS UART
  .hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX ),
  .hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX ),
  //HPS I2C1
  .hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT ),
  .hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK ),
  //HPS I2C2
  .hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT ),
  .hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK ),
  //HPS GPIO
  .hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N ),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N ),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO ),
  //.hps_0_hps_io_hps_io_gpio_inst_GPIO41  ( HPS_GPIO[1]),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO48  ( HPS_I2C_CONTROL ),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED ),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY ),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT ),
  //FPGA soft GPIO 
  .led_pio_external_connection_export    (  ),
  .dipsw_pio_external_connection_export  ( SW ),
  .button_pio_external_connection_export ( KEY )
  );

camera_capture u3( 
  .out_data     (ccd_data_captured),    // component output data
  .out_valid    (ccd_dval),             // data valid signal
  .out_count_x  (X_Cont_raw),
  .out_count_y  (Y_Cont_raw),
  .oFrame_Cont  (Frame_Cont),           // Frames counter
  .in_data      (ccd_data_raw),         // 12-bit data
  .in_frame_valid (ccd_fval_raw),       // Frame valid signal
  .in_line_valid  (ccd_lval_raw),       // Line valid signal
  .in_start     (SW[9]),
  .clock        (ccd_pixel_clk),
  // Negative logic reset
  .reset_n      (hps2fpga_reset_n & video_stream_reset_n),
  .in_width     (in_width[11:0]),
  .in_height    (in_height[11:0])
  );
  wire    [15:0] in_width;
  wire    [15:0] in_height;
  wire    [11:0] X_Cont_raw;
  wire    [11:0] Y_Cont_raw;
  // assign in_width = 11'd1280;
  // assign in_height = 11'd960;
  assign X_Cont = {4'd0, X_Cont_raw};
  assign Y_Cont = {4'd0, Y_Cont_raw};

  // CCD_Capture external pinout conections.
  assign  CCD_DATA[0]  =  GPIO_1[13]; //Pixel data Bit 0
  assign  CCD_DATA[1]  =  GPIO_1[12]; //Pixel data Bit 1
  assign  CCD_DATA[2]  =  GPIO_1[11]; //Pixel data Bit 2
  assign  CCD_DATA[3]  =  GPIO_1[10]; //Pixel data Bit 3
  assign  CCD_DATA[4]  =  GPIO_1[9];  //Pixel data Bit 4
  assign  CCD_DATA[5]  =  GPIO_1[8];  //Pixel data Bit 5
  assign  CCD_DATA[6]  =  GPIO_1[7];  //Pixel data Bit 6
  assign  CCD_DATA[7]  =  GPIO_1[6];  //Pixel data Bit 7
  assign  CCD_DATA[8]  =  GPIO_1[5];  //Pixel data Bit 8
  assign  CCD_DATA[9]  =  GPIO_1[4];  //Pixel data Bit 9
  assign  CCD_DATA[10] =  GPIO_1[3];  //Pixel data Bit 10
  assign  CCD_DATA[11] =  GPIO_1[1];  //Pixel data Bit 11
  assign  GPIO_1[16]   =  clk_24;    //External input clock
  assign  CCD_FVAL     =  GPIO_1[22]; //frame valid
  assign  CCD_LVAL     =  GPIO_1[21]; //line valid
  assign  ccd_pixel_clk=  GPIO_1[0];  //Pixel clock
  assign  GPIO_1[19]   =  1'b1;       //trigger
  assign  GPIO_1[17]   =  hps2fpga_reset_n & video_stream_reset_n;
  
  assign  GPIO_0[0]   =  hps2fpga_reset_n & video_stream_reset_n;
  assign  GPIO_0[1]   =  ccd_pixel_clk;

  // Refreshes the data on the CCD camera on every pixel clock pulse.
  always@(posedge ccd_pixel_clk)
    begin
    ccd_data_raw  <=  CCD_DATA;
    ccd_lval_raw  <=  CCD_LVAL;
    ccd_fval_raw  <=  CCD_FVAL;
  end


/* This component converts 'raw' data obtained in the CCD to RGB data.

The output width  and height are half of the input ones, as, each pixel consists
in 4 components(RGBG): The number of rows and columns are reduced to the half.
One from every 2 rows are stored on a buffer for getting the components of the
corresponding pixel afterwards.
*/
raw2rgb u4(	
  .iCLK         (ccd_pixel_clk),
  // Negative logic reset
  .iRST         (hps2fpga_reset_n & video_stream_reset_n),
  .iDATA        (ccd_data_captured),  // Component input data
  .iDVAL        (ccd_dval),           // Data valid signal
  .oRed         (raw_rgb_red),        // Output red component
  .oGreen       (raw_rgb_green),      // Output green component
  .oBlue        (raw_rgb_blue),       // Output blue component
  .oDVAL        (raw_rgb_dval),       // Pixel value available
  .iX_Cont      (X_Cont),
  .iY_Cont      (Y_Cont)
  );
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
      if (SW[3]) begin
        fifo1_writedata <= {1'b0, raw_rgb_red[11:7], raw_rgb_green[11:7], 
                            raw_rgb_blue[11:7]};
        fifo_write_enable <= raw_rgb_dval;
      end
      else begin
        fifo1_writedata <= {8'h00, hue_hue[7:0]};
        fifo_write_enable <= out_hue_valid;
      end
    end
  end

rgb2hue hue(
  .clock(ccd_pixel_clk),
  .reset_n(hps2fpga_reset_n & video_stream_reset_n),
  // Data input
  .in_red(raw_rgb_red[11:4]),
  .in_green(raw_rgb_green[11:4]),
  .in_blue(raw_rgb_blue[11:4]),
  .in_valid(raw_rgb_dval),
  .in_visual(1'b1),
  .in_done(1'b1),
  // Data output
  .out_red(hue_red),
  .out_green(hue_green),
  .out_blue(hue_blue),
  .out_hue(hue_hue),
  .out_valid(out_hue_valid),
  .out_visual(),
  .out_done()
  );
  wire  [7:0] hue_hue;
  wire  [7:0] hue_red;
  wire  [7:0] hue_green;
  wire  [7:0] hue_blue;
  wire        out_hue_valid;

  
// image_capture: save RGB and Hue into HPS memory
image_capture imgcap1 (
	// Clock and reset
	.clk ( ccd_pixel_clk ),
	.reset_n (hps2fpga_reset_n & video_stream_reset_n),
	// Signals from the video stream
	.R( hue_red ),
	.G( hue_green ),
	.B( hue_blue ),
	.Gray( hue_hue ),
	.frame_valid( ccd_fval_raw ),
	.data_valid( out_hue_valid ),
	// Signals to control this component.
	.start_capture( start_capture ),
	.image_width( capture_width ),
	.image_height( capture_height ),
	.buff0( capture_buff0 ),
	.buff1( capture_buff1 ),
	.buff0full( capture_buff0full ),
	.buff1full( capture_buff1full ),
	.standby ( capture_standby ),
	// Avalon MM Master port to save data into a memory.
	.address ( image_capture_address ),
	.write ( image_capture_write ),
	.byteenable ( image_capture_byteenable ),
	.writedata ( image_capture_write_data ),
	.waitrequest ( image_capture_waitrequest ),
	.burstcount  ( image_capture_burstcount  )
	);
	// image_capture control signals
	wire  start_capture; // Start a new image capture
	wire  [15:0] capture_width; //with of the image (in dots or RGB pixels)
	wire  [15:0] capture_height; //height of the image (in dots or RGB pixels)
	wire 	[31:0] capture_buff0; // Address of the buffer to save odd line
	wire 	[31:0] capture_buff1; // Address of the buffer to save even line
	wire  capture_buff0full; // buff0 is full 
	wire  capture_buff1full; // buff1 is full 
	wire  capture_standby; // buff1 is full 
	// Avalon signals to write the pixels into memory
	wire  [31:0]image_capture_address; 
	wire  image_capture_write;
	wire  [7:0]image_capture_byteenable; 
	wire  [63:0]image_capture_write_data;
	wire  image_capture_waitrequest;
	wire  [6:0] image_capture_burstcount;
	
  
// SDRAM memory based on DE1-SOC demonstration
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

  // Send the data on the FIFO memory to the VGA outputs.
  assign VGA_R = (!vga_enable) ? 0 :
                 (!SW[3])      ? fifo1_readdata[7:0] :
                 (SW[0])       ? {fifo1_readdata[14:10], 3'd0} :
                 0;
  assign VGA_G = (!vga_enable) ? 0 :
                 (!SW[3])      ? fifo1_readdata[7:0] :
                 (SW[1])       ? {fifo1_readdata[9:5], 3'd0} :
                 0;
  assign VGA_B = (!vga_enable) ? 0 :
                 (!SW[3])      ? fifo1_readdata[7:0] :
                 (SW[2])       ? {fifo1_readdata[4:0], 3'd0} :
                 0;
  // Set the VGA clock to 25 MHz.
  assign  VGA_CLK = clk_25;


/*
Instantiation of the 7-segment displays module.

Depending on the status of the 8th switch (SW[8]), it will display the
exposure value (if SW[8] = 1) or the frame rate (if SW[8] = 0).

For getting the frame rate, a 1 second temporizer is created, and the
number of frames between pulses is displayed. Moreover, a seconds pulse
is wired to the first led of the board (LEDR[0])
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
  .iDIG         (display)
  );
  wire  [31:0] display;
  reg   [31:0] count;
  reg   [31:0] rate;
  reg   [31:0] _Frame_Cont;
  reg          seconds_pulse;
  reg          pulse;
  assign LEDR[0] = pulse;
  assign display = (SW[8]) ? {16'h0, in_exposure} : rate;
  // Calculate the frame rate.
  // Seconds counter. The output will be 1 during one pulse after 1 second.
  always @(posedge CLOCK_50) begin
    if (count < 50000000) begin
      count = count + 1;
      // seconds_pulse = 0;
    end
    else begin
      count = 0;
      // seconds_pulse = 1;
      pulse = ~pulse;
      rate = Frame_Cont - _Frame_Cont;
      _Frame_Cont = Frame_Cont;
    end
  end


// Component for writing configuration to the camera peripheral.
camera_config #(
  .CLK_FREQ(25000000),  // 25 MHz
  .I2C_FREQ(20000)      // 20 kHz
  ) camera_conf(
  // Host Side
  .clock(ccd_pixel_clk),
  .reset_n(hps2fpga_reset_n & video_stream_reset_n),
  // Configuration registers
  .exposure(in_exposure),
  .start_row(in_start_row),
  .start_column(in_start_column),
  .row_size(in_row_size),
  .column_size(in_column_size),
  .row_mode(in_row_mode),
  .column_mode(in_column_mode),
  // Ready signal
  .out_ready(ready),
  // I2C Side
  .I2C_SCLK(GPIO_1[24]),
  .I2C_SDAT(GPIO_1[23])
  );
  // Camera config (I2C)
  wire          ready;
  wire  [15:0]  in_exposure;
  wire  [15:0]  start_row;
  wire  [15:0]  start_column;
  wire  [15:0]  in_row_size;
  wire  [15:0]  in_column_size;
  wire  [15:0]  in_row_mode;
  wire  [15:0]  in_column_mode;

  // assign in_exposure = 16'h07C0;
  // assign start_row = 16'h0000;
  // assign start_column = 16'h0000;
  // assign in_row_size = 16'h077F;
  // assign in_column_size = 16'h09FF;
  // assign in_row_mode = 16'h0011;
  // assign in_column_mode = 16'h0011;
  
// Reset logic
assign video_stream_reset_n = (camera_soft_reset_n & KEY[0]);

endmodule
