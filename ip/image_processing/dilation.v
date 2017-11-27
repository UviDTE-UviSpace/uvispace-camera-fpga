///
/// Morphological operator of dilation
/// -------------------------------------
///
/// This module implements the morphological operation of dilation with a 
/// square 3x3 mask.
///
/// .. image:: dilation.png
///
///    Dilation block
///
module dilation #(
        parameter N = 1,
        // Erosion mask
        parameter k00 = 1, k01 = 1, k02 = 1,
        parameter k10 = 1, k11 = 1, k12 = 1,
        parameter k20 = 1, k21 = 1, k22 = 1
    ) (
        input clock,
        input reset_n,
        // Size
        input [15:0] img_width,
        // Image data input
        input in_valid,
        input [N-1:0] in_pixel,
        // Image data output
        output out_valid,
        output [N-1:0] out_pixel
    );
    
    wire [N-1:0] pix00, pix01, pix02;
    wire [N-1:0] pix10, pix11, pix12;
    wire [N-1:0] pix20, pix21, pix22;
        
    fifo3x3 #(
        .N(N)
    ) fifo (
        .clock(clock),
        .reset_n(reset_n),
        // Size
        .width(img_width[15:0]),
        // Data input
        .read(in_valid), 
        .pi(in_pixel),
        // Data output
        .po00(pix00), .po01(pix01), .po02(pix02),
        .po10(pix10), .po11(pix11), .po12(pix12),
        .po20(pix20), .po21(pix21), .po22(pix22),
        .valid(out_valid)
    );
        
    // Dilation
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: dila
            assign out_pixel[i] = (k00 & pix00[i]) | (k01 & pix01[i]) | (k02 & pix02[i]) |
                                  (k10 & pix10[i]) | (k11 & pix11[i]) | (k12 & pix12[i]) |
                                  (k20 & pix20[i]) | (k21 & pix21[i]) | (k22 & pix22[i]);
        end
    endgenerate
        
endmodule
