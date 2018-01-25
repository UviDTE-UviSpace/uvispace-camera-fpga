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

//=======================================================
//Top level entity. Contains the inputs and outputs wired to external pins.
//=======================================================
module uvispace_top_de1_soc(
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


uvispace_top u0 (
    ///////// ADC /////////
	.ADC_CS_N(ADC_CS_N),
	.ADC_DIN(ADC_DIN),
	.ADC_DOUT(ADC_DOUT),
	.ADC_SCLK(ADC_SCLK),
  ///////// AUD /////////
  	.AUD_ADCDAT(AUD_ADCDAT),
  	.AUD_ADCLRCK(AUD_ADCLRCK),
  	.AUD_BCLK(AUD_BCLK),
	.AUD_DACDAT(AUD_DACDAT),
	.AUD_DACLRCK(AUD_DACLRCK),
	.AUD_XCK(AUD_XCK),
  ///////// CLOCK2 /////////
	.CLOCK2_50(CLOCK2_50),
  ///////// CLOCK3 /////////
	.CLOCK3_50(CLOCK3_50),
  ///////// CLOCK4 /////////
	.CLOCK4_50(CLOCK4_50),
  ///////// CLOCK /////////
	.CLOCK_50(CLOCK_50),
  ///////// DRAM /////////
	.DRAM_ADDR(DRAM_ADDR),   //Address Bus
	.DRAM_BA(DRAM_BA),     //Bank address
	.DRAM_CAS_N(DRAM_CAS_N),  //Column address strobe
	.DRAM_CKE(DRAM_CKE),    //Clock enable
	.DRAM_CLK(DRAM_CLK),    //Clock
	.DRAM_CS_N(DRAM_CS_N),   //Chip select
	.DRAM_DQ(DRAM_DQ),     //Data Bus
	.DRAM_LDQM(DRAM_LDQM),   //Low-byte data mask
	.DRAM_RAS_N(DRAM_RAS_N),  //Row adress strobe
	.DRAM_UDQM(DRAM_UDQM),   //High-byte data mask
	.DRAM_WE_N(DRAM_WE_N),   //Write enable
  ///////// FAN /////////
	.FAN_CTRL(FAN_CTRL),
  ///////// FPGA /////////
	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),
  ///////// GPIO /////////
	.GPIO_0(GPIO_0),
	.GPIO_1(GPIO_1),
  ///////// HEX /////////
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5),
  ///////// HPS /////////
  `ifdef ENABLE_HPS
	.HPS_CONV_USB_N(HPS_CONV_USB_N),
	.HPS_DDR3_ADDR(HPS_DDR3_ADDR),
	.HPS_DDR3_BA(HPS_DDR3_BA),
	.HPS_DDR3_CAS_N(HPS_DDR3_CAS_N),
	.HPS_DDR3_CKE(HPS_DDR3_CKE),
	.HPS_DDR3_CK_N(HPS_DDR3_CK_N),
	.HPS_DDR3_CK_P(HPS_DDR3_CK_P),
	.HPS_DDR3_CS_N(HPS_DDR3_CS_N),
	.HPS_DDR3_DM(HPS_DDR3_DM),
	.HPS_DDR3_DQ(HPS_DDR3_DQ),
	.HPS_DDR3_DQS_N(HPS_DDR3_DQS_N),
	.HPS_DDR3_DQS_P(HPS_DDR3_DQS_P),
	.HPS_DDR3_ODT(HPS_DDR3_ODT),
	.HPS_DDR3_RAS_N(HPS_DDR3_RAS_N),
	.HPS_DDR3_RESET_N(HPS_DDR3_RESET_N),
 	.HPS_DDR3_RZQ(HPS_DDR3_RZQ),
	.HPS_DDR3_WE_N(HPS_DDR3_WE_N),
	.HPS_ENET_GTX_CLK(HPS_ENET_GTX_CLK),
	.HPS_ENET_INT_N(HPS_ENET_INT_N),
	.HPS_ENET_MDC(HPS_ENET_MDC),
	.HPS_ENET_MDIO(HPS_ENET_MDIO),
	.HPS_ENET_RX_CLK(HPS_ENET_RX_CLK),
	.HPS_ENET_RX_DATA(HPS_ENET_RX_DATA),
	.HPS_ENET_RX_DV(HPS_ENET_RX_DV),
	.HPS_ENET_TX_DATA(HPS_ENET_TX_DATA),
	.HPS_ENET_TX_EN(HPS_ENET_TX_EN),
	.HPS_FLASH_DATA(HPS_FLASH_DATA),
	.HPS_FLASH_DCLK(HPS_FLASH_DCLK),
	.HPS_FLASH_NCSO(HPS_FLASH_NCSO),
	.HPS_GSENSOR_INT(HPS_GSENSOR_INT),
	.HPS_I2C1_SCLK(HPS_I2C1_SCLK),
	.HPS_I2C1_SDAT(HPS_I2C1_SDAT),
	.HPS_I2C2_SCLK(HPS_I2C2_SCLK),
	.HPS_I2C2_SDAT(HPS_I2C2_SDAT),
	.HPS_I2C_CONTROL(HPS_I2C_CONTROL),
	.HPS_KEY(HPS_KEY),
	.HPS_LED(HPS_LED),
	.HPS_LTC_GPIO(HPS_LTC_GPIO),
	.HPS_SD_CLK(HPS_SD_CLK),
	.HPS_SD_CMD(HPS_SD_CMD),
	.HPS_SD_DATA(HPS_SD_DATA),
	.HPS_SPIM_CLK(HPS_SPIM_CLK),
	.HPS_SPIM_MISO(HPS_SPIM_MISO),
	.HPS_SPIM_MOSI(HPS_SPIM_MOSI),
	.HPS_SPIM_SS(HPS_SPIM_SS),
	.HPS_UART_RX(HPS_UART_RX),
	.HPS_UART_TX(HPS_UART_TX),
	.HPS_USB_CLKOUT(HPS_USB_CLKOUT),
	.HPS_USB_DATA(HPS_USB_DATA),
	.HPS_USB_DIR(HPS_USB_DIR),
	.HPS_USB_NXT(HPS_USB_NXT),
	.HPS_USB_STP(HPS_USB_STP),
  `endif /*ENABLE_HPS*/
  ///////// IRDA /////////
	.IRDA_RXD(IRDA_RXD),
	.IRDA_TXD(IRDA_TXD),
  ///////// KEY /////////
	.KEY(KEY),
  ///////// LEDR /////////
	.LEDR(LEDR),
  ///////// PS2 /////////
	.PS2_CLK(PS2_CLK),
	.PS2_CLK2(PS2_CLK2),
	.PS2_DAT(PS2_DAT),
	.PS2_DAT2(PS2_DAT2),
  ///////// SW /////////
	.SW(SW),
  ///////// TD /////////
	.TD_CLK27(TD_CLK27),
	.TD_DATA(TD_DATA),
	.TD_HS(TD_HS),
	.TD_RESET_N(TD_RESET_N),
	.TD_VS(TD_VS),
  ///////// VGA /////////
	.VGA_B(VGA_B),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_G(VGA_G),
	.VGA_HS(VGA_HS),
	.VGA_R(VGA_R),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS)
  );

endmodule