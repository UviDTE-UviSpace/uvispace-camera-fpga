/*
Module for converting input RAW data to RGB values.

The input data presents the 'Bayer patter' i.e. There are 4 different
components (G1-R-B-G2) that form a square: The upper row contains the
first green component (G1) and the red one; and the lower row contains
the blue component and the second green one (G2).

The output data has an RGB format. Thus, every pixel is formed by
merging the 4 components from the 'Bayer pattern' into the 3 colours
values. This implies that there will be a new valid pixel every 4 cycles
of the input clock.
*/
    
module RAW2RGB( 
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
wire    [11:0]  mDATA_0;
wire    [11:0]  mDATA_1;
reg     [11:0]  mDATAd_0;
reg     [11:0]  mDATAd_1;
reg     [11:0]  mCCD_R;
reg     [12:0]  mCCD_G;
reg     [11:0]  mCCD_B;
reg             mDVAL;

assign  oRed    =   mCCD_R[11:0];
assign  oGreen  =   mCCD_G[12:1];
assign  oBlue   =   mCCD_B[11:0];
assign  oDVAL   =   mDVAL;

// RAM buffer with capacity for storing 2 taps (image rows), of 1280
// 12-bit width elements. A tap is a shift register.
// If clken is set, the data will shift with every clock edge, and a new
// value will be stored (the value of shiftin). Moreover, the output
// value will shift as well, and a new component will be obtained at
// every clock pulse.
Line_Buffer     u0(
    .clken(iDVAL),
    .clock(iCLK),
    .shiftin(iDATA),
    .taps0x(mDATA_1),
    .taps1x(mDATA_0)
    );

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
        // mDATA_0 contains the data of the upper right row.
        // mDATA_1 contains the data of the lower right row.
        // As mDATAd_0 and mDATAd_1 read the value of mDATA_0 and mDATA_0 at the
        // previous cycle, they contain the left components of the upper and
        // lower rows, respectively (At the time of evaluating them).
        mDATAd_0    <=  mDATA_0;
        mDATAd_1    <=  mDATA_1;
        mDVAL       <=  {iY_Cont[0]|iX_Cont[0]} ?   1'b0    :   iDVAL;
        // Set each RGB component to their corresponding input:
        // Red component is the upper left.
        // Green component is the addition of the lower left and upper right.
        // Blue component is the lower right.
        if({iY_Cont[0],iX_Cont[0]}==2'b10)
        begin
         mCCD_R  <=  mDATA_0;
         mCCD_G  <=  mDATAd_0+mDATA_1;
         mCCD_B  <=  mDATAd_1;
        end  
        else if({iY_Cont[0],iX_Cont[0]}==2'b11)
        begin
         mCCD_R  <=  mDATAd_0;
         mCCD_G  <=  mDATA_0+mDATAd_1;
         mCCD_B  <=  mDATA_1;
        end
        else if({iY_Cont[0],iX_Cont[0]}==2'b00)
        begin
            mCCD_R  <=  mDATA_1;
            mCCD_G  <=  mDATA_0+mDATAd_1;
            mCCD_B  <=  mDATAd_0;
        end
        else if({iY_Cont[0],iX_Cont[0]}==2'b01)
        begin
         mCCD_R  <=  mDATAd_1;
         mCCD_G  <=  mDATAd_0+mDATA_1;
         mCCD_B  <=  mDATA_0;
        end
    end
end

endmodule
