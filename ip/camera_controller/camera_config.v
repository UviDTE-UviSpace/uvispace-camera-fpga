///
/// Camera configuration
/// --------------------
///
/// This module configures the camera sensor through its control registers.
/// For in this way control and configure: the exposition time, the resolution
/// and the frame rate.
///
/// .. figure:: camera_config.png
///
///    Camera configuration block
///
/// For this, it generates the necessary signals for to control the I2C bus, 
/// that communicates with the cammera registers.
///
/// So, each configuration register has 16 bits width, and they are used for 
/// to configure the active image for to be tranfered by the camera sensor, so
/// that:
///
/// exposure (ie)
///   This is the level of exposition time value.
/// start_row (sr)
///   This is the configuration entry of start row (0x0036).
/// start_column (sc)
///   This is the configuration entry of start column (0x0010).
/// row_size (rs)
///   This is the configuration entry of row size (2 * skip * height - 1).
/// column_size (cs)
///   This is the configuration entry of column size (2 * skip * width - 1).
/// row_mode (rm)
///   This is the configuration entry of row mode (skip) [skip = 0, 1, 2] .
/// column_mode (cm) 
///   This is the configuration entry of column mode (skip) [skip = 0, 1, 2].
///
module camera_config #(
        // Clock settings
        parameter CLK_FREQ = 50000000, // 50 MHz
        parameter I2C_FREQ = 20000 // 20 kHz
    ) (
        // Host Side
        input clock,
        input reset_n,
        // Reg inputs
        input [15:0] exposure,
        input [15:0] start_row,
        input [15:0] start_column,
        input [15:0] row_size,
        input [15:0] column_size,
        input [15:0] row_mode,
        input [15:0] column_mode,
        // Ready output
        output out_ready,
        // I2C Side
        output I2C_SCLK,
        inout I2C_SDAT
    );
   
//------------------------------------------------------------------------------

   // I2C Control Clock
   reg [15:0] mI2C_CLK_DIV;
   reg [31:0] mI2C_DATA;
   reg mI2C_CTRL_CLK;
   reg mI2C_GO;
   wire mI2C_END;
   wire mI2C_ACK; 
   always@(posedge clock or negedge reset_n)
   begin
      if (!reset_n) begin
         mI2C_CTRL_CLK <= 0;
         mI2C_CLK_DIV <= 0;
      end
      else begin
         if (mI2C_CLK_DIV < (CLK_FREQ / I2C_FREQ)) 
            mI2C_CLK_DIV <= mI2C_CLK_DIV + 1;
         else begin
            mI2C_CLK_DIV <= 0;
            mI2C_CTRL_CLK <= ~mI2C_CTRL_CLK;
         end
      end
   end
   
   // I2C controller
   I2C_Controller u0	(
      .CLOCK(mI2C_CTRL_CLK), // Controller Work Clock
      .I2C_SCLK(I2C_SCLK), // I2C CLOCK
      .I2C_SDAT(I2C_SDAT), // I2C DATA
      .I2C_DATA(mI2C_DATA), // DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
      .GO(mI2C_GO), // GO transfor
      .END(mI2C_END), // END transfor 
      .ACK(mI2C_ACK), // ACK
      .RESET(reset_n) //
   );
   
//------------------------------------------------------------------------------

    // LUT Data Number
    parameter LUT_SIZE = 25;
    
    // Configuration control
    reg [23:0] LUT_DATA;
    reg [5:0] LUT_INDEX;
    reg [3:0] mSetup_ST;
    
    reg _ready;
   
    always @(posedge mI2C_CTRL_CLK or negedge reset_n)
    begin
        if (!reset_n) begin
            LUT_INDEX <= 0;
            mSetup_ST <= 0;
            mI2C_GO <= 0;
            _ready <= 1'b0;
        end
        else if (LUT_INDEX < LUT_SIZE) begin
            case (mSetup_ST)
                0: begin
                    mI2C_DATA	<= {8'hBA, LUT_DATA};
                    mI2C_GO <= 1;
                    mSetup_ST	<= 1;
                end
                1: begin
                    if (mI2C_END) begin
                        if (!mI2C_ACK)
                            mSetup_ST <= 2;
                        else
                            mSetup_ST <= 0;							
                        mI2C_GO <= 0;
                    end
                end
                2: begin
                    LUT_INDEX	<= LUT_INDEX + 1;
                    mSetup_ST	<= 0;
                end
            endcase
            _ready <= 1'b0;
        end
        else begin
            _ready <= 1'b1;
        end
    end
    
    // Generates ready signal for system initialization
    reg ready;
    always @(posedge clock)
    begin
        if (reset_n) begin
            ready <= _ready; 
        end
        else begin
            ready <= 1'b0;
        end
    end
    assign out_ready = ready;

    // Config Data LUT
    always begin
        case (LUT_INDEX)
            0: LUT_DATA <= 24'h000000;
            1: LUT_DATA <= 24'h20c000; // Mirror Row and Columns
            2: LUT_DATA	<= {8'h09, exposure}; // Exposure
            3: LUT_DATA <= 24'h050000; // H_Blanking
            4: LUT_DATA <= 24'h060019; // V_Blanking
            5: LUT_DATA <= 24'h0A8000; // Change latch
            6: LUT_DATA <= 24'h2B0013; // Green 1 Gain
            7: LUT_DATA <= 24'h2C009A; // Blue Gain
            8: LUT_DATA <= 24'h2D019C; // Red Gain
            9: LUT_DATA <= 24'h2E0013; // Green 2 Gain
            10: LUT_DATA <= 24'h100051; // Set up PLL power on
            // PLL_m_Factor << 8 + PLL_n_Divider. Default = h111807
            11: LUT_DATA <= 24'h112003; 
            12: LUT_DATA <= 24'h120001; // PLL_p1_Divider
            13: LUT_DATA <= 24'h100053; // Set USE PLL
            14: LUT_DATA <= 24'h980000; // Disable calibration
        `ifdef ENABLE_TEST_PATTERN
            15: LUT_DATA <= 24'hA00001; // Test pattern control
            16: LUT_DATA <= 24'hA10123; // Test green pattern value
            17: LUT_DATA <= 24'hA20456; // Test red pattern value
        `else
            15: LUT_DATA <= 24'hA00000; // Test pattern control
            16: LUT_DATA <= 24'hA10000; // Test green pattern value
            17: LUT_DATA <= 24'hA20FFF; // Test red pattern value
        `endif
            18: LUT_DATA <= {8'h01, start_row}; // Set start row
            19: LUT_DATA <= {8'h02, start_column}; // Set start column
            20: LUT_DATA <= {8'h03, row_size}; // Set row size
            21: LUT_DATA <= {8'h04, column_size}; // Set column size
            22: LUT_DATA <= {8'h22, row_mode}; // Set row mode in bin mode
            23: LUT_DATA <= {8'h23, column_mode}; // Set column mode in bin mode
            24: LUT_DATA <= 24'h4901A8; // Row black target
            //25: LUT_DATA <= 24'h1E4106; // Set snapshot mode
            default: LUT_DATA <= 24'h000000;
        endcase
    end
   
//------------------------------------------------------------------------------

endmodule
