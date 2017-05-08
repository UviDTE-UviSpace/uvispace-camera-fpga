//
// Avalon MM Slave for parallel input/output camera registers 
//
module avalon_camera (
        // Avalon clock interface signals
        input csi_clk,
        input csi_reset_n,
        // Signals for Avalon-MM slave port
        input [4:0] avs_s1_address,
        input avs_s1_read,
        output reg [31:0] avs_s1_readdata,
        input avs_s1_write,
        input [31:0] avs_s1_writedata,
        // Control signals to export to the top module
        output avs_export_clk,
        output avs_export_capture_start,
        input avs_export_capture_done,
        output avs_export_capture_configure,
        input avs_export_capture_ready,
        output avs_export_capture_select_vga,
        output [7:0] avs_export_capture_select_output,
        output avs_export_capture_read,
        input [31:0] avs_export_capture_readdata,
        // Registers to export to the top module
        output [15:0] avs_export_width,
        output [15:0] avs_export_height,
        output [15:0] avs_export_start_row,
        output [15:0] avs_export_start_column,
        output [15:0] avs_export_row_size,
        output [15:0] avs_export_column_size,
        output [15:0] avs_export_row_mode,
        output [15:0] avs_export_column_mode,
        output [15:0] avs_export_exposure
    );
    
    // Slave address constant
    `define CAPTURE_START           5'h00
    `define CAPTURE_CONFIGURE       5'h01
    `define CAPTURE_SELECT_VGA      5'h02
    `define CAPTURE_SELECT_OUTPUT   5'h03
    `define CAPTURE_DATA            5'h04
    
    // Registers address
    `define ADDR_WIDTH          5'h08
    `define ADDR_HEIGHT         5'h0a
    `define ADDR_START_ROW      5'h0c
    `define ADDR_START_COLUMN   5'h0e
    `define ADDR_ROW_SIZE       5'h10
    `define ADDR_COLUMN_SIZE    5'h12
    `define ADDR_ROW_MODE       5'h14
    `define ADDR_COLUMN_MODE    5'h16
    `define ADDR_EXPOSURE       5'h18
    
    // Registers default values
    parameter WIDTH = 16'd320;
    parameter HEIGHT = 16'd240;
    parameter START_ROW = 16'h0036;
    parameter START_COLUMN = 16'h0010;
    parameter ROW_SIZE = 16'h059f;
    parameter COLUMN_SIZE = 16'h077f;
    parameter ROW_MODE = 16'h0002;
    parameter COLUMN_MODE = 16'h0002;
    parameter EXPOSURE = 16'h07c0;

    // SDRAM clock
    assign avs_export_clk = csi_clk;
    assign avs_export_capture_read = read;
    
    // Control registers
    reg capture_start;
    reg capture_configure;
    reg select_vga;
    reg [7:0] select_output;
    // Configuration registers    
    reg [15:0] data_width;
    reg [15:0] data_height;
    reg [15:0] data_start_row;
    reg [15:0] data_start_column;
    reg [15:0] data_row_size;
    reg [15:0] data_column_size;
    reg [15:0] data_row_mode;
    reg [15:0] data_column_mode;
    reg [15:0] data_exposure;
    
    reg read;

    // Read/Write registers
    always @(posedge csi_clk or negedge csi_reset_n) 
    begin
        if (!csi_reset_n) begin
            read <= 1'b0;
            avs_s1_readdata <= 32'd0;
            // Control outputs
            capture_start <= 1'b0;
            capture_configure  <= 1'b0;
            select_vga <= 1'b0;
            select_output <= 8'b0;
            // Configuration registers
            data_width[15:0] <= WIDTH[15:0];
            data_height[15:0] <= HEIGHT[15:0];
            data_start_row[15:0] <= START_ROW[15:0];
            data_start_column[15:0] <= START_COLUMN[15:0];
            data_row_size[15:0] <= ROW_SIZE[15:0];
            data_column_size[15:0] <= COLUMN_SIZE[15:0];
            data_row_mode[15:0] <= ROW_MODE[15:0];
            data_column_mode[15:0] <= COLUMN_MODE[15:0];
            data_exposure[15:0] <= EXPOSURE[15:0];
        end
        else begin
            if (avs_s1_read) begin
                case (avs_s1_address)
                    `CAPTURE_DATA:
                        begin
                            read <= ~read;
                            avs_s1_readdata[31:0] <= avs_export_capture_readdata[31:0];
                        end
                    `CAPTURE_START:
                        avs_s1_readdata[31:0] <= {31'b0, avs_export_capture_done};
                    `CAPTURE_CONFIGURE:
                        avs_s1_readdata[31:0] <= {31'b0, avs_export_capture_ready};
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
                    default:
                        avs_s1_readdata <= avs_s1_readdata;  
                endcase
            end
            // if avs_s1_read is FALSE...
            else begin
                read <= 1'b0;
                avs_s1_readdata <= 32'd0;
            
                if (avs_s1_write) begin
                    case (avs_s1_address)
                        `CAPTURE_START:
                            capture_start <= avs_s1_writedata[0];
                        `CAPTURE_CONFIGURE:
                            capture_configure  <= avs_s1_writedata[0];
                        `CAPTURE_SELECT_VGA:
                            select_vga <= avs_s1_writedata[0];
                        `CAPTURE_SELECT_OUTPUT:
                            select_output <= avs_s1_writedata[7:0];
                        `ADDR_WIDTH:
                            data_width[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_HEIGHT:
                            data_height[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_START_ROW:
                            data_start_row[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_START_COLUMN:
                            data_start_column[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_ROW_SIZE:
                            data_row_size[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_COLUMN_SIZE:
                            data_column_size[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_ROW_MODE:
                            data_row_mode[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_COLUMN_MODE:
                            data_column_mode[15:0] <= avs_s1_writedata[15:0];
                        `ADDR_EXPOSURE:
                            data_exposure[15:0] <= avs_s1_writedata[15:0];
                    endcase
                end
            end
        end
    end
    
    // Control signals
    assign avs_export_capture_start = capture_start;
    assign avs_export_capture_configure = capture_configure;
    assign avs_export_capture_select_vga = select_vga;
    assign avs_export_capture_select_output[7:0] = select_output[7:0]; 
    
    // Configuration signals
    assign avs_export_width[15:0] = data_width[15:0];
    assign avs_export_height[15:0] = data_height[15:0];
    assign avs_export_start_row[15:0] = data_start_row[15:0];
    assign avs_export_start_column[15:0] = data_start_column[15:0];
    assign avs_export_row_size[15:0] = data_row_size[15:0];
    assign avs_export_column_size[15:0] = data_column_size[15:0];
    assign avs_export_row_mode[15:0] = data_row_mode[15:0];
    assign avs_export_column_mode[15:0] = data_column_mode[15:0];
    assign avs_export_exposure[15:0] = data_exposure[15:0];

endmodule
