///
/// 3x3 Erosion block
/// -----------------
///
/// This module implements the morphological operation of erosion, with a square
/// mask of 3x3.
///
/// .. image:: erosion.png
///
///    Erosion block
///
module erosion #(
        parameter N = 1,
        // Erosion mask
        parameter k00 = 1, k01 = 1, k02 = 1,
        parameter k10 = 1, k11 = 1, k12 = 1,
        parameter k20 = 1, k21 = 1, k22 = 1
    ) (
        input clock,
        input reset_n,
        // Image size
        input [15:0] width,
        // Image data input
        input in_write,
        input [N-1:0] in_pixel,
        // Image data output
        output out_read,
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
        // Size,
        .width(width[15:0]),
        // Data input
        .read(in_write), 
        .pi(in_pixel),
        // Data output
        .po00(pix00), .po01(pix01), .po02(pix02),
        .po10(pix10), .po11(pix11), .po12(pix12),
        .po20(pix20), .po21(pix21), .po22(pix22),
        .valid(out_read)
    );
    
    // Erosion
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: eros
            assign out_pixel[i] = k00 & pix00[i] & k01 & pix01[i] & k02 & pix02[i] &
                                  k10 & pix10[i] & k11 & pix11[i] & k12 & pix12[i] &
                                  k20 & pix20[i] & k21 & pix21[i] & k22 & pix22[i];
        end
    endgenerate
        
endmodule
//
module erosion5x5 #(
        parameter N = 1,
        // Erosion mask
        parameter k00 = 1, k01 = 1, k02 = 1, k03 = 1, k04 = 1,
        parameter k10 = 1, k11 = 1, k12 = 1, k13 = 1, k14 = 1,
        parameter k20 = 1, k21 = 1, k22 = 1, k23 = 1, k24 = 1,
        parameter k30 = 1, k31 = 1, k32 = 1, k33 = 1, k34 = 1,
        parameter k40 = 1, k41 = 1, k42 = 1, k43 = 1, k44 = 1
    ) (
        input clock,
        input reset_n,
        // Image size
        input [15:0] width,
        // Image data input
        input in_write,
        input [N-1:0] in_pixel,
        // Image data output
        output out_read,
        output [N-1:0] out_pixel
    );
    
    wire [N-1:0] pix00, pix01, pix02, pix03, pix04;
    wire [N-1:0] pix10, pix11, pix12, pix13, pix14;
    wire [N-1:0] pix20, pix21, pix22, pix23, pix24;
    wire [N-1:0] pix30, pix31, pix32, pix33, pix34;
    wire [N-1:0] pix40, pix41, pix42, pix43, pix44;
        
    fifo5x5 #(
        .N(N)
    ) fifo (
        .clock(clock),
        .reset_n(reset_n),
        // Size,
        .width(width[15:0]),
        // Data input
        .read(in_write), 
        .pi(in_pixel),
        // Data output
        .po00(pix00), .po01(pix01), .po02(pix02), .po03(pix03), .po04(pix04),
        .po10(pix10), .po11(pix11), .po12(pix12), .po13(pix13), .po14(pix14),
        .po20(pix20), .po21(pix21), .po22(pix22), .po23(pix23), .po24(pix24),
        .po30(pix30), .po31(pix31), .po32(pix32), .po33(pix33), .po34(pix34),
        .po40(pix40), .po41(pix41), .po42(pix42), .po43(pix43), .po44(pix44),
        .valid(out_read)
    );
    
    // Erosion
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: eros
            assign out_pixel[i] = k00 & pix00[i] & k01 & pix01[i] & k02 & pix02[i] & k03 & pix03[i] & k04 & pix04[i] &
                                  k10 & pix10[i] & k11 & pix11[i] & k12 & pix12[i] & k13 & pix13[i] & k14 & pix14[i] &
                                  k20 & pix20[i] & k21 & pix21[i] & k22 & pix22[i] & k23 & pix23[i] & k24 & pix24[i] &
                                  k30 & pix30[i] & k31 & pix31[i] & k32 & pix32[i] & k33 & pix33[i] & k34 & pix34[i] &
                                  k40 & pix40[i] & k41 & pix41[i] & k42 & pix42[i] & k43 & pix43[i] & k44 & pix44[i];
        end
    endgenerate
        
endmodule
