

`define ENABLE_HPS
//`define ENABLE_CLK

module uvispace_top_de0_nano_soc(

      ///////// ADC /////////
      output             ADC_CONVST,
      output             ADC_SCK,
      output             ADC_SDI,
      input              ADC_SDO,

      ///////// ARDUINO /////////
      inout       [15:0] ARDUINO_IO,
      inout              ARDUINO_RESET_N,

`ifdef ENABLE_CLK
      ///////// CLK /////////
      output             CLK_I2C_SCL,
      inout              CLK_I2C_SDA,
`endif /*ENABLE_CLK*/

      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// GPIO /////////
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

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
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
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

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW
);


//============================================================================
//  Structural coding
//============================================================================

uvispace_top u0 (

  ///////// CLOCK /////////
  .CLOCK_50(FPGA_CLK1_50),
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

  /////PULSE_LED////
  .pulse_led                   ( LED[0] ),
  /////RESET_STREAM_N/////
  .reset_stream_key            ( KEY[0] ),
  ////EN_CAM_CAPTURE/////
  .camera_capture_en           ( 1'b1 )
  );

endmodule
