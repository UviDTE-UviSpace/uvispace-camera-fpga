// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================

`define ENABLE_HPS

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


  ///////// HEX0 /////////
  output      [6:0]  HEX0,

  ///////// HEX1 /////////
  output      [6:0]  HEX1,

  ///////// HEX2 /////////
  output      [6:0]  HEX2,

  ///////// HEX3 /////////
  output      [6:0]  HEX3,

  ///////// HEX4 /////////
  output      [6:0]  HEX4,

  ///////// HEX5 /////////
  output      [6:0]  HEX5,
  `ifdef ENABLE_HPS
  ///////// HPS /////////
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
wire    hps_fpga_reset_n;
wire    clk_25;
wire    clk_193;
wire    clk_120;

//VGA signals
wire    vga_enable;
integer vga_row;
integer vga_col;

//CCD peripheral signal
wire	  [11:0] CCD_DATA;
reg     [1:0]  rClk;

//CCD_Capture signals
wire    [11:0] ccd_data_captured;		//output data from CCD_Capture
wire				   ccd_dval;            //valid output data
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
wire    [15:0] fifo1_data;
wire    [15:0] fifo2_data;

//=======================================================
//  Structural coding
//=======================================================
soc_system u0 (      
  .clk_clk                               ( CLOCK_50 ),
  .reset_reset_n                         ( 1'b1 ),
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
  .led_pio_external_connection_export    ( LEDR ),
  .dipsw_pio_external_connection_export  ( SW ),
  .button_pio_external_connection_export ( KEY ),
  //HPS reset output 
  .hps_0_h2f_reset_reset_n               (hps_fpga_reset_n ),
  //HPS PLL clock outputs
  .pll_sdram_clk_100_clk                 ( clk_100 ),
  .pll_vga_clks_25_clk                   ( clk_25 ),
  .pll_vga_clks_191_clk                  ( clk_193 )
  );

// VGA controller component and a test image generator
assign 	VGA_CLK = clk_25;

vga_controller vga_component(
  .pixel_clk  ( clk_25 ),
  .reset_n    ( hps_fpga_reset_n ),
  .h_sync     ( VGA_HS ),
  .v_sync     ( VGA_VS ),
  .disp_ena   ( vga_enable ),
  .column     (),
  .row        (),
  .n_blank    ( VGA_BLANK_N ),
  .n_sync     ( VGA_SYNC_N )
	);

// The output values are set to corresponding data only when vga_enable is True
assign VGA_R = vga_enable ? fifo2_data[9:2] : 0;
assign VGA_G = vga_enable ? {fifo1_data[14:11], fifo2_data[14:11]} : 0;
assign VGA_B = vga_enable ? fifo1_data[9:2] : 0;

// hw_image_generator diplay_component(
//   .disp_ena   ( vga_enable ),                    
//   .row        ( vga_row ),  	
//   .column     ( vga_col ),                      
//   .red        ( VGA_R ),  	
//   .green      ( VGA_G ),                    
//   .blue       ( VGA_B ),  		
// 	);

// CCD_Capture component circuit
assign	CCD_DATA[0]  =	GPIO_1[13]; //Pixel data Bit 0
assign	CCD_DATA[1]	 =	GPIO_1[12]; //Pixel data Bit 1
assign	CCD_DATA[2]	 =	GPIO_1[11]; //Pixel data Bit 2
assign	CCD_DATA[3]	 =	GPIO_1[10]; //Pixel data Bit 3
assign	CCD_DATA[4]	 =	GPIO_1[9];  //Pixel data Bit 4
assign	CCD_DATA[5]	 =	GPIO_1[8];  //Pixel data Bit 5
assign	CCD_DATA[6]	 =	GPIO_1[7];  //Pixel data Bit 6
assign	CCD_DATA[7]	 =	GPIO_1[6];  //Pixel data Bit 7
assign	CCD_DATA[8]	 =	GPIO_1[5];  //Pixel data Bit 8
assign	CCD_DATA[9]	 =	GPIO_1[4];  //Pixel data Bit 9
assign	CCD_DATA[10] =	GPIO_1[3];  //Pixel data Bit 10
assign	CCD_DATA[11] =	GPIO_1[1];  //Pixel data Bit 11
assign	GPIO_1[16]   =	rClk[0];    //External input clock
assign	CCD_FVAL     =	GPIO_1[22]; //frame valid
assign	CCD_LVAL     =	GPIO_1[21]; //line valid
assign	ccd_pixel_clk=	GPIO_1[0];  //Pixel clock
assign	GPIO_1[19]   =	1'b1;       //trigger
assign	GPIO_1[17]   =	hps_fpga_reset_n;

always@(posedge CLOCK_50)	rClk	<=	rClk+1;

always@(posedge ccd_pixel_clk)
  begin
  ccd_data_raw	<=	CCD_DATA;
  ccd_lval_raw	<=	CCD_LVAL;
  ccd_fval_raw	<=	CCD_FVAL;
end

CCD_Capture u3(	
  .oDATA        (ccd_data_captured),  // component output data
  .oDVAL        (ccd_dval),           // data valid signal
  .oX_Cont      (X_Cont),
  .oY_Cont      (Y_Cont),
  .oFrame_Cont  (Frame_Cont),         // Frames counter
  .iDATA        (ccd_data_raw),
  .iFVAL        (ccd_fval_raw),       //Frame valid signal
  .iLVAL        (ccd_lval_raw),       //Line valid signal
  .iSTART       (!KEY[3]),
  .iEND         (!KEY[2]),
  .iCLK         (ccd_pixel_clk),
  .iRST         (hps_fpga_reset_n)    //negative logic reset
  );

RAW2RGB u4(	
  .iCLK         (ccd_pixel_clk),
  .iRST         (hps_fpga_reset_n),   //negative logic reset
  .iDATA        (ccd_data_captured),  //component input data
  .iDVAL        (ccd_dval),           // data valid signal
  .oRed         (raw_rgb_red),        //output red component
  .oGreen       (raw_rgb_green),      //output green component
  .oBlue        (raw_rgb_blue),       //output blue component
  .oDVAL        (raw_rgb_dval),
  .iX_Cont      (X_Cont),
  .iY_Cont      (Y_Cont)
  );

Sdram_Control_4Port u7  (
  //  HOST Side           
  .REF_CLK      (CLOCK_50),
  .RESET_N      (1'b1),
  .CLK          (clk_100), 

  //  FIFO Write Side 1
  // .WR1_DATA     ({1'b0, raw_rgb_green[11:7], raw_rgb_blue[11:2]}),
  .WR1_DATA     (16'hFFFF),
  .WR1          (raw_rgb_dval),
  .WR1_ADDR     (0),
  .WR1_MAX_ADDR (640*480),
  .WR1_LENGTH   (9'h100),
  .WR1_LOAD     (!hps_fpga_reset_n),
  .WR1_CLK      (~ccd_pixel_clk),

  //  FIFO Write Side 2
  // .WR2_DATA     ({1'b0, raw_rgb_green[6:2], raw_rgb_red[11:2]}),
  .WR2_DATA     (16'hFFFF),  
  .WR2          (raw_rgb_dval),
  .WR2_ADDR     (22'h100000),
  .WR2_MAX_ADDR (22'h100000+640*480),
  .WR2_LENGTH   (9'h100),
  .WR2_LOAD     (!hps_fpga_reset_n),
  .WR2_CLK      (~ccd_pixel_clk),


  //  FIFO Read Side 1
  .RD1_DATA     (fifo1_data),
  .RD1          (disp_ena),
  .RD1_ADDR     (0),
  .RD1_MAX_ADDR (640*480),
  .RD1_LENGTH   (9'h100),
  .RD1_LOAD     (!hps_fpga_reset_n),
  .RD1_CLK      (~clk_25),

  //  FIFO Read Side 2
  .RD2_DATA     (fifo2_data),
  .RD2          (disp_ena),
  .RD2_ADDR     (22'h100000),
  .RD2_MAX_ADDR (22'h100000+640*480),
  .RD2_LENGTH   (9'h100),
  .RD2_LOAD     (!hps_fpga_reset_n),
  .RD2_CLK      (~clk_25),

  //  SDRAM Side
   .SA           (DRAM_ADDR[11:0]),
   .BA           (DRAM_BA),
   .CS_N         (DRAM_CS_N),
   .CKE          (DRAM_CKE),
   .RAS_N        (DRAM_RAS_N),
   .CAS_N        (DRAM_CAS_N),
   .WE_N         (DRAM_WE_N),
   .DQ           (DRAM_DQ),
   .DQM          ({DRAM_UDQM,DRAM_LDQM})
   );

assign DRAM_ADDR[12] = 1'b0;

SEG7_LUT_8 u5(	
  .oSEG0        (HEX0),
  .oSEG1        (HEX1),
  .oSEG2        (HEX2),
  .oSEG3        (HEX3),
  .oSEG4        (HEX4),
  .oSEG5        (HEX5),
  .oSEG6        (),
  .oSEG7        (),
  .iDIG         (Frame_Cont[31:0])
  );

I2C_CCD_Config u8(	//	Host Side
  .iCLK             (CLOCK_50),
  .iRST_N           (hps_fpga_reset_n),
  .iZOOM_MODE_SW    (SW[8]),
  .iEXPOSURE_ADJ    (KEY[1]),
  .iEXPOSURE_DEC_p  (SW[0]),
  //	I2C Side
  .I2C_SCLK         (GPIO_1[24]),
  .I2C_SDAT         (GPIO_1[23])
  );

endmodule