//
// Avalon MM Slave for parallel input/output camera registers 
//
module avalon_camera (
        // Avalon clock interface signals
        input clk,
        input reset_n,
        // Signals for Avalon-MM slave port
        input [3:0] avs_s1_address,
        input avs_s1_read,
        output reg [31:0] avs_s1_readdata,
        input avs_s1_write,
        input [31:0] avs_s1_writedata,
        // Control signals to export to the image capture
		  output avs_export_start_capture,
		  output [31:0] avs_export_buff0,
		  output [15:0] avs_export_buff1,
		  input avs_export_buff0full,
		  input avs_export_buff1full,
        // Registers to export to the camera_config
        output [15:0] avs_export_start_row,
        output [15:0] avs_export_start_column,
        output [15:0] avs_export_row_size,
        output [15:0] avs_export_column_size,
        output [15:0] avs_export_row_mode,
        output [15:0] avs_export_column_mode,
		  output [15:0] avs_export_exposure,
		  // Registers to export to the camera_config an
		  output [15:0] avs_export_width,
        output [15:0] avs_export_height,
		  //soft reset
        output avs_export_cam_soft_reset_n
    );
    
    // Addresses of the registers to control image_capture
    `define ADDR_START_CAPTURE      4'h00
    `define ADDR_BUFF0				   4'h01
    `define ADDR_BUFF1            	4'h02
	 `define ADDR_BUFF0FULL        	4'h03
	 `define ADDR_BUFF1FULL        	4'h04
    // Addresses of the registers to control camera_config
    `define ADDR_START_ROW      		4'h05
    `define ADDR_START_COLUMN   		4'h06
    `define ADDR_ROW_SIZE       		4'h07
    `define ADDR_COLUMN_SIZE    		4'h08
    `define ADDR_ROW_MODE       		4'h09
    `define ADDR_COLUMN_MODE    		4'h0a
    `define ADDR_EXPOSURE       		4'h0b
	 // Addresses of the registers used in image_capture and camera_config
	 `define ADDR_WIDTH          		4'h0c
    `define ADDR_HEIGHT         		4'h0d
	 // Address of the soft reset 
	 `define SOFT_RESET_N            4'h0e
    
    // Camera config registers default values
    parameter WIDTH = 16'd320;
    parameter HEIGHT = 16'd240;
    parameter START_ROW = 16'h0036;
    parameter START_COLUMN = 16'h0010;
    parameter ROW_SIZE = 16'h059f;
    parameter COLUMN_SIZE = 16'h077f;
    parameter ROW_MODE = 16'h0002;
    parameter COLUMN_MODE = 16'h0002;
    parameter EXPOSURE = 16'h07c0;
    
    // image_capture regs
    reg start_capture;
    reg [31:0] buff0;
	 reg [31:0] buff1;
    reg buff0full;
	 reg buff1full;
    // camera_config regs   
    reg [15:0] data_start_row;
    reg [15:0] data_start_column;
    reg [15:0] data_row_size;
    reg [15:0] data_column_size;
    reg [15:0] data_row_mode;
    reg [15:0] data_column_mode;
    reg [15:0] data_exposure;
	 //image_capture and camera_config regs
	 reg [15:0] data_width;
    reg [15:0] data_height;
	 //soft_reset reg
    reg cam_soft_reset_n;
    

    // Read/Write registers
    always @(posedge clk or negedge reset_n) 
    begin
        if (!reset_n) begin
   
				start_capture <= 1'b0;
				buff0[31:0] <= 32'd0;
				buff1[31:0] <= 32'd0;
            data_start_row[15:0] <= START_ROW[15:0];
            data_start_column[15:0] <= START_COLUMN[15:0];
            data_row_size[15:0] <= ROW_SIZE[15:0];
            data_column_size[15:0] <= COLUMN_SIZE[15:0];
            data_row_mode[15:0] <= ROW_MODE[15:0];
            data_column_mode[15:0] <= COLUMN_MODE[15:0];
            data_exposure[15:0] <= EXPOSURE[15:0];
				data_width[15:0] <= WIDTH[15:0];
            data_height[15:0] <= HEIGHT[15:0];
            cam_soft_reset_n <= 1;
        end
        else begin
            if (avs_s1_read) begin
                case (avs_s1_address)
							//image_capture
							`ADDR_START_CAPTURE:
								avs_s1_readdata[31:0] <= {31'b0, start_capture};
							`ADDR_BUFF0:
                        avs_s1_readdata[31:0] <= buff0;
							`ADDR_BUFF1:
                        avs_s1_readdata[31:0] <= buff1;
							`ADDR_BUFF0FULL:
                        avs_s1_readdata[31:0] <= {31'b0, buff0full};
							`ADDR_BUFF1FULL:
                        avs_s1_readdata[31:0] <= {31'b0, buff1full};
						   //camera_config
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
							//image_capture and camera_config	
							`ADDR_WIDTH: 
                        avs_s1_readdata[15:0] <= data_width[15:0];  
							`ADDR_HEIGHT:
                        avs_s1_readdata[15:0] <= data_height[15:0];
							//soft reset
							`SOFT_RESET_N:
                        avs_s1_readdata[15:0] <= {15'b0, cam_soft_reset_n};
                    default:
                        avs_s1_readdata <= {32'd0};  
                endcase
            end
            // if avs_s1_read is FALSE...
            else begin
                if (avs_s1_write) begin
                    case (avs_s1_address)
						  //image_capture
							`ADDR_START_CAPTURE:
								start_capture <= avs_s1_writedata[0];
							`ADDR_BUFF0:
                        buff0 <= avs_s1_writedata[31:0];
							`ADDR_BUFF1:
                        buff1 <= avs_s1_writedata[31:0];
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
							`ADDR_WIDTH:
								 data_width[15:0] <= avs_s1_writedata[15:0];
							`ADDR_HEIGHT:
								 data_height[15:0] <= avs_s1_writedata[15:0];
							`SOFT_RESET_N:
								 cam_soft_reset_n <= avs_s1_writedata[0];
                    endcase
                end
            end
        end
    end
    
	 //buff0full and buff1full registers
	 //this signals are coming from the capture_image and may be clocked 
	 //by a different clock. Thats why asynchronous set is done here 
	 //to set this signals. The processor uses this signals to know that
	 //one line has finished and can read the buffer. The processor is
	 //in charge of erase this signals through the avalon bus.
	 always @(posedge clk or negedge reset_n or posedge avs_export_buff0full) begin
      if (avs_export_buff0full) buff0full <= 1'b1;
		else if (!reset_n) buff0full <= 1'b0;
		else begin
			if (avs_s1_write == 1) begin
				case (avs_s1_address) 
					`ADDR_BUFF0FULL: buff0full <= avs_s1_writedata[0];
				endcase
			end
		end
	end
	always @(posedge clk or negedge reset_n or posedge avs_export_buff1full) begin
      if (avs_export_buff1full) buff1full <= 1'b1;
		else if (!reset_n) buff1full <= 1'b0; 
		else begin
			 if (avs_s1_write == 1) begin
				case (avs_s1_address) 
					`ADDR_BUFF1FULL: buff1full <= avs_s1_writedata[0];
				endcase
			end
		end
	end
	 
    // Control signals to export to the image capture
    assign avs_export_start_capture = start_capture;
	 assign avs_export_buff0 = buff0;
	 assign avs_export_buff1 = buff1;
    // Registers to export to the camera_config
    assign avs_export_start_row[15:0] = data_start_row[15:0];
    assign avs_export_start_column[15:0] = data_start_column[15:0];
    assign avs_export_row_size[15:0] = data_row_size[15:0];
    assign avs_export_column_size[15:0] = data_column_size[15:0];
    assign avs_export_row_mode[15:0] = data_row_mode[15:0];
    assign avs_export_column_mode[15:0] = data_column_mode[15:0];
    assign avs_export_exposure[15:0] = data_exposure[15:0];
	 // Registers to export to the camera_config an
	 assign avs_export_width[15:0] = data_width[15:0];
    assign avs_export_height[15:0] = data_height[15:0];
	 //soft reset
    assign avs_export_cam_soft_reset_n = cam_soft_reset_n;

endmodule
