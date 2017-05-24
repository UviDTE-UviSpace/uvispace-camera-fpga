/*
Module for converting input RAW data to RGB values.

The input data presents the 'Bayer patter' i.e. There are 4 different
components (G1-R-B-G2) that form a square: The upper row contains the
first green component (G1) and the red one; and the lower row contains
the blue component and the second green one (G2). However, the camera is
configured with the mirror mode (both rows and columns are mirrored) and
the previous pattern is inverted.

The output data has an RGB format. Thus, every pixel is formed by
merging the 4 components from the 'Bayer pattern' into the 3 colours
values. This implies that there will be a new valid pixel only a quarter
of the input clock pulses.

For merging the pixel array, it is necessary to buffer one entire row
and evaluate the pixels during the odd rows. This buffer is achieved
using a FIFO memory implemented at the FPGA memory blocks. The buffering
of the pixels left components is achieved storing on a register the
input values for using their content on the following cycle.
*/
module raw2rgb( 
    oRed,
    oGreen,
    oBlue,
    oDVAL,
    iX_Cont,
    iY_Cont,
    iDATA,
    iDVAL,
    iCLK,
    iRST
    );
    input   [10:0]  iX_Cont;
    input   [10:0]  iY_Cont;
    input   [11:0]  iDATA;
    input           iDVAL;
    input           iCLK;
    input           iRST;
    output  [11:0]  oRed;
    output  [11:0]  oGreen;
    output  [11:0]  oBlue;
    output          oDVAL;
// Module internal signals.
reg     [11:0]  mCCD_R;
reg     [12:0]  mCCD_G;
reg     [11:0]  mCCD_B;
reg             mDVAL;
reg     [11:0]  upper_row_pixel;
reg     [11:0]  upper_row_pixel_delayed;
reg     [11:0]  lower_row_pixel;
reg     [11:0]  lower_row_pixel_delayed;
// FIFO memory control signals.
wire            fifo_read_en;
wire            fifo_write_en;
wire    [11:0]  fifo_data_out;

/*
The even rows are stored on a FIFO memory, that is implemented on the FPGA
memory blocks.
Thus, the FIFO is written while the even rows are being read from the camera,
and it is read when the odd rows are being read.
*/
onchip_fifo fifo(
        .clock(iCLK),
        .aclr(!iRST),
        .rdreq(fifo_read_en),
        .wrreq(fifo_write_en),
        .data(iDATA),
        .q(fifo_data_out)
    );
    assign fifo_write_en = iDVAL & !iY_Cont[0];
    assign fifo_read_en = iDVAL & iY_Cont[0];

// Output signals assignment.
assign  oRed    =   mCCD_R[11:0];
assign  oGreen  =   mCCD_G[12:1];
assign  oBlue   =   mCCD_B[11:0];
assign  oDVAL   =   mDVAL;
// Core element of the module. Pixel conversion to RGB components.
always@(posedge iCLK or negedge iRST)
begin
    if(!iRST)
    begin
        mCCD_R  <=  0;
        mCCD_G  <=  0;
        mCCD_B  <=  0;
        mDATAd_0<=  0;
        mDATAd_1<=  0;
        mDVAL   <=  0;
    end
    else
    begin
        /*
        Each image pixel is composed by 4 components following a Bayer pattern.
        Thus, this hardware module must store in 4 different registers the
        values of each pixel components. 
        The components belonging to the upper row are stored on a FIFO memory.
        Moreover, it is necessary to use a shift register for storing one pulse
        the component values and having at the same moment the left (delayed)
        components and the right (actual) components.
        */
        upper_row_pixel_delayed <= upper_row_pixel;
        upper_row_pixel         <= fifo_data_out;
        lower_row_pixel_delayed <= lower_row_pixel;
        lower_row_pixel         <= iDATA;
        // There will only be a valid data when both the odd rows and columns
        // are being read.
        mDVAL       <=  {iY_Cont[0] & iX_Cont[0]} ? iDVAL : 1'b0;
        /*
        The camera is configured with the mirror mode. Thus, the pixel array
        structure will be an inverted Bayer pattern, i.e. for a given pixel, the
        position of its components will be:
        - Blue component at the top left position
        - Green1 component at the lower left position
        - Green2 component at the top right position
        - Red component at the lower right position
        */
        if ({iY_Cont[0],iX_Cont[0]}==2'b11) begin
            mCCD_R  <=  lower_row_pixel;
            mCCD_G  <=  upper_row_pixel + lower_row_pixel_delayed;
            mCCD_B  <=  upper_row_pixel_delayed;
        end
    end
end

endmodule
