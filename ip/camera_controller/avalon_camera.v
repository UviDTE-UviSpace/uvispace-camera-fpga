//
// Avalon MM Slave for parallel input/output camera registers
//
module avalon_camera (
    // Avalon clock interface signals
    input clk,
    input reset_n,
    // Signals for Avalon-MM slave port
    input [4:0] avs_s1_address,
    input avs_s1_read,
    output reg [31:0] avs_s1_readdata,
    input avs_s1_write,
    input [31:0] avs_s1_writedata,
    // Registers to export to the camera_config
    output [15:0] avs_export_width,
    output [15:0] avs_export_height,
    output [15:0] avs_export_start_row,
    output [15:0] avs_export_start_column,
    output [15:0] avs_export_row_size,
    output [15:0] avs_export_column_size,
    output [15:0] avs_export_row_mode,
    output [15:0] avs_export_column_mode,
    output [15:0] avs_export_exposure,
	 output [15:0] avs_export_h_blanking,
	 output [15:0] avs_export_v_blanking,
	 output [15:0] avs_export_red_gain,
	 output [15:0] avs_export_blue_gain,
	 output [15:0] avs_export_green1_gain,
	 output [15:0] avs_export_green2_gain,
    //soft reset
    output avs_export_cam_soft_reset_n
    );

// Addresses of the registers to control camera_config
`define ADDR_WIDTH              5'h00
`define ADDR_HEIGHT             5'h01
`define ADDR_START_ROW          5'h02
`define ADDR_START_COLUMN       5'h03
`define ADDR_ROW_SIZE           5'h04
`define ADDR_COLUMN_SIZE        5'h05
`define ADDR_ROW_MODE           5'h06
`define ADDR_COLUMN_MODE        5'h07
`define ADDR_EXPOSURE           5'h08
`define ADDR_H_BLANKING         5'h09
`define ADDR_V_BLANKING         5'h0A
`define ADDR_RED_GAIN           5'h0B
`define ADDR_BLUE_GAIN          5'h0C
`define ADDR_GREEN1_GAIN        5'h0D
`define ADDR_GREEN2_GAIN        5'h0E

// Address of the soft reset
`define SOFT_RESET_N            5'h1F //last address

// Camera configuration registers default values.
parameter WIDTH         = 16'd320;
parameter HEIGHT        = 16'd240;
parameter START_ROW     = 16'h0036;
parameter START_COLUMN  = 16'h0010;
parameter ROW_SIZE      = 16'h059f;
parameter COLUMN_SIZE   = 16'h077f;
parameter ROW_MODE      = 16'h0002;
parameter COLUMN_MODE   = 16'h0002;
parameter EXPOSURE      = 16'h07c0;
parameter H_BLANKING    = 16'h0000;
parameter V_BLANKING    = 16'h0019;
parameter RED_GAIN      = 16'h019C;
parameter BLUE_GAIN     = 16'h009A;
parameter GREEN1_GAIN   = 16'h0013;
parameter GREEN2_GAIN   = 16'h0013;

// camera_config registers
reg [15:0] data_width;
reg [15:0] data_height;
reg [15:0] data_start_row;
reg [15:0] data_start_column;
reg [15:0] data_row_size;
reg [15:0] data_column_size;
reg [15:0] data_row_mode;
reg [15:0] data_column_mode;
reg [15:0] data_exposure;
reg [15:0] data_h_blanking;
reg [15:0] data_v_blanking;
reg [15:0] data_red_gain;
reg [15:0] data_blue_gain;
reg [15:0] data_green1_gain;
reg [15:0] data_green2_gain;

//soft_reset reg
reg cam_soft_reset_n;


// Read/Write registers
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        data_width[15:0]        <= WIDTH[15:0];
        data_height[15:0]       <= HEIGHT[15:0];
        data_start_row[15:0]    <= START_ROW[15:0];
        data_start_column[15:0] <= START_COLUMN[15:0];
        data_row_size[15:0]     <= ROW_SIZE[15:0];
        data_column_size[15:0]  <= COLUMN_SIZE[15:0];
        data_row_mode[15:0]     <= ROW_MODE[15:0];
        data_column_mode[15:0]  <= COLUMN_MODE[15:0];
        data_exposure[15:0]     <= EXPOSURE[15:0];
		  data_h_blanking[15:0]   <= H_BLANKING[15:0];
		  data_v_blanking[15:0]   <= V_BLANKING[15:0];
		  data_red_gain[15:0]     <= RED_GAIN[15:0];
		  data_blue_gain[15:0]    <= BLUE_GAIN[15:0];
		  data_green1_gain[15:0]  <= GREEN1_GAIN[15:0];
		  data_green2_gain[15:0]  <= GREEN2_GAIN[15:0];
        cam_soft_reset_n        <= 1;
    end
    else begin
        if (avs_s1_read) begin
            case (avs_s1_address) //(Read registers from Avalon bus)
                // camera_config
                `ADDR_WIDTH:
                    avs_s1_readdata[15:0] <= data_width[15:0];
                `ADDR_HEIGHT:
                    avs_s1_readdata[15:0] <= data_height[15:0];
                `ADDR_START_ROW:
                    avs_s1_readdata[15:0] <= data_start_row[15:0];
                `ADDR_START_COLUMN:
                    avs_s1_readdata[15:0] <= data_start_column[15:0];
                `ADDR_ROW_SIZE:
                    avs_s1_readdata[15:0] <= data_row_size[15:0];
                `ADDR_COLUMN_SIZE:
                    avs_s1_readdata[15:0] <= data_column_size[15:0];
                `ADDR_ROW_MODE:
                    avs_s1_readdata[15:0] <= data_row_mode[15:0];
                `ADDR_COLUMN_MODE:
                    avs_s1_readdata[15:0] <= data_column_mode[15:0];
                `ADDR_EXPOSURE:
                    avs_s1_readdata[15:0] <= data_exposure[15:0];
					 `ADDR_H_BLANKING:
                    avs_s1_readdata[15:0] <= data_h_blanking[15:0];
					 `ADDR_V_BLANKING:
                    avs_s1_readdata[15:0] <= data_v_blanking[15:0];
					 `ADDR_RED_GAIN:
                    avs_s1_readdata[15:0] <= data_red_gain[15:0];
					 `ADDR_BLUE_GAIN:
                    avs_s1_readdata[15:0] <= data_blue_gain[15:0];
					 `ADDR_GREEN1_GAIN:
                    avs_s1_readdata[15:0] <= data_green1_gain[15:0];
					 `ADDR_GREEN2_GAIN:
                    avs_s1_readdata[15:0] <= data_green2_gain[15:0];
                // soft reset
                `SOFT_RESET_N:
                    avs_s1_readdata[31:0] <= {31'b0, cam_soft_reset_n};
                default:
                    avs_s1_readdata[31:0] <= {32'b0};
            endcase
        end
        // Routine when avs_s1_read is FALSE (Write registers from Avalon bus)
        else begin
            if (avs_s1_write) begin
                case (avs_s1_address)
                    `ADDR_WIDTH:
                        data_width[15:0]        <= avs_s1_writedata[15:0];
                    `ADDR_HEIGHT:
                        data_height[15:0]       <= avs_s1_writedata[15:0];
                    `ADDR_START_ROW:
                        data_start_row[15:0]    <= avs_s1_writedata[15:0];
                    `ADDR_START_COLUMN:
                        data_start_column[15:0] <= avs_s1_writedata[15:0];
                    `ADDR_ROW_SIZE:
                        data_row_size[15:0]     <= avs_s1_writedata[15:0];
                    `ADDR_COLUMN_SIZE:
                        data_column_size[15:0]  <= avs_s1_writedata[15:0];
                    `ADDR_ROW_MODE:
                        data_row_mode[15:0]     <= avs_s1_writedata[15:0];
                    `ADDR_COLUMN_MODE:
                        data_column_mode[15:0]  <= avs_s1_writedata[15:0];
                    `ADDR_EXPOSURE:
                        data_exposure[15:0]     <= avs_s1_writedata[15:0];
						  `ADDR_H_BLANKING:
                        data_h_blanking[15:0]   <= avs_s1_writedata[15:0];
						  `ADDR_V_BLANKING:
                        data_v_blanking[15:0]   <= avs_s1_writedata[15:0];
						  `ADDR_RED_GAIN:
                        data_red_gain[15:0]     <= avs_s1_writedata[15:0];
						  `ADDR_BLUE_GAIN:
                        data_blue_gain[15:0]    <= avs_s1_writedata[15:0];
						  `ADDR_GREEN1_GAIN:
                        data_green1_gain[15:0]  <= avs_s1_writedata[15:0];
						  `ADDR_GREEN2_GAIN:
                        data_green2_gain[15:0]  <= avs_s1_writedata[15:0];
                    // soft reset
                    `SOFT_RESET_N:
                        cam_soft_reset_n        <= avs_s1_writedata[0];
                endcase
            end
        end
    end
end

// Registers to export to the camera_config
assign avs_export_start_row[15:0]    = data_start_row[15:0];
assign avs_export_start_column[15:0] = data_start_column[15:0];
assign avs_export_row_size[15:0]     = data_row_size[15:0];
assign avs_export_column_size[15:0]  = data_column_size[15:0];
assign avs_export_row_mode[15:0]     = data_row_mode[15:0];
assign avs_export_column_mode[15:0]  = data_column_mode[15:0];
assign avs_export_exposure[15:0]     = data_exposure[15:0];
assign avs_export_h_blanking[15:0]   = data_h_blanking[15:0];
assign avs_export_v_blanking[15:0]   = data_v_blanking[15:0];
assign avs_export_red_gain[15:0]     = data_red_gain[15:0];
assign avs_export_blue_gain[15:0]    = data_blue_gain[15:0];
assign avs_export_green1_gain[15:0]  = data_green1_gain[15:0];
assign avs_export_green2_gain[15:0]  = data_green2_gain[15:0];
// Registers to export to the camera_config and others
assign avs_export_width[15:0]  = data_width[15:0];
assign avs_export_height[15:0] = data_height[15:0];
//soft reset
assign avs_export_cam_soft_reset_n = cam_soft_reset_n;

endmodule
