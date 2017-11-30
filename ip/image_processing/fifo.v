///
/// FIFO memory block for 3x3 convolution
/// -------------------------------------
///
/// Proporciona los datos necesarios para realizar una convolución de 3x3, a 
/// partir de los datos de la imagen, proporcionados de forma secuencial.
///
/// Para ello, cuando su funcionamiento se encuentra desinhibido (enable) y a 
/// partir de los datos de la imagen y por medio de una serie de registros 
/// conectados en serie, de tal modo que conforman una memoria "fifo", a cada 
/// flanco de reloj se carga un valor y se desplazan los siguientes. De tal 
/// forma que para empezar a procesar la imagen se debe esperar a la señal que 
/// se activa cuando se encuentra listo (ready).
/// 
/// Dado que los datos sólo son válidos para unas determinadas posiciones, que
/// dependen de las dimensiones de la imagen (WIDTH y HEIGHT), se genera una 
/// señal que identifica cuando se dispone de un dato válido (valid) para su 
/// procesamiento.
///
/// ..Note:: Los datos sólo son válidos para los "pixels" de entrada corres-
/// pondientes al rango de la imagen [0, WIDTH-3] y [3, HEIGHT-1].
///
/// Además, para reiniciar la transmisión de los datos en "streaming", se
/// dispone de una señal de (reset) en paralelo.
///
module fifo3x3 #( 
        parameter N = 3,
        parameter MEMORY_SIZE = 4096,
        parameter ADDRESS_SIZE = 12,
        parameter K = 3 // Kernel SIZE
//        parameter WIDTH = 8,
//        parameter HEIGHT = 8
    ) (
        input clock,
        input reset_n,
        // Size
        input [15:0] width,
        // Data input
        input read, 
        input [N-1:0] pi,
        // Data output
        output [N-1:0] po00, po01, po02,
        output [N-1:0] po10, po11, po12,
        output [N-1:0] po20, po21, po22,
        output valid
    );
    
    reg [15:0] SIZE;
    always @(posedge clock)
    begin
        if (!reset_n) begin
            SIZE[15:0] <= width[15:0] - K[15:0]; 
        end
    end
    
    wire [N-1:0] net_in [0:K-1];
    wire [N-1:0] net_out [0:K-1];
    
    wire [N-1:0] net_o0 [0:K-1];
    wire [N-1:0] net_o1 [0:K-1];
    wire [N-1:0] net_o2 [0:K-1];
    
    genvar i;
    generate
        for (i = 1; i < K; i = i + 1) begin: fbuffer
            fifo_prg #(
                .MEMORY_WIDTH(N),
                .MEMORY_SIZE(MEMORY_SIZE),
                .ADDRESS_SIZE(ADDRESS_SIZE)
            ) ffbuf (
                .clk(clock),
                .reset_n(reset_n),
                .enable(read),
                .data_in(net_in[i][N-1:0]),
                .size(SIZE[15:0]),
                .data_out(net_out[i][N-1:0])
            );
        end
        for (i = 0; i < K; i = i + 1) begin: rbuffer
            register3 #(N) regs(
                .clock(clock),
                .enable(read),
                .d(net_out[i][N-1:0]),
                .q0(net_o0[i][N-1:0]),
                .q1(net_o1[i][N-1:0]),
                .q2(net_o2[i][N-1:0])
            );
        end
        for (i = 0; i < (K - 1); i = i + 1) begin: conn
            assign net_in[i+1][N-1:0] = net_o2[i][N-1:0];
        end
    endgenerate
    
    assign net_in[0][N-1:0] = pi[N-1:0];
    assign net_out[0][N-1:0] = net_in[0][N-1:0];
    assign po22[N-1:0] = net_o0[0][N-1:0];
    assign po21[N-1:0] = net_o1[0][N-1:0];
    assign po20[N-1:0] = net_o2[0][N-1:0];
    assign po12[N-1:0] = net_o0[1][N-1:0];
    assign po11[N-1:0] = net_o1[1][N-1:0];
    assign po10[N-1:0] = net_o2[1][N-1:0];
    assign po02[N-1:0] = net_o0[2][N-1:0];
    assign po01[N-1:0] = net_o1[2][N-1:0];
    assign po00[N-1:0] = net_o2[2][N-1:0];
        
    reg _valid;
    always @(posedge clock) 
    begin
        if (reset_n) begin
            _valid <= read;
        end
        else begin
            _valid <= 1'b0;
        end
    end
    assign valid = _valid;
   
endmodule
//
module fifo5x5 #( 
        parameter N = 3,
        parameter MEMORY_SIZE = 4096,
        parameter ADDRESS_SIZE = 12,
        parameter K = 5 // Kernel SIZE
//        parameter WIDTH = 8,
//        parameter HEIGHT = 8
    ) (
        input clock,
        input reset_n,
        // Size
        input [15:0] width,
        // Data input
        input read, 
        input [N-1:0] pi,
        // Data output
        output [N-1:0] po00, po01, po02, po03, po04,
        output [N-1:0] po10, po11, po12, po13, po14,
        output [N-1:0] po20, po21, po22, po23, po24,
        output [N-1:0] po30, po31, po32, po33, po34,
        output [N-1:0] po40, po41, po42, po43, po44,
        output valid
    );
    
    reg [15:0] SIZE;
    always @(posedge clock)
    begin
        if (!reset_n) begin
            SIZE[15:0] <= width[15:0] - K[15:0]; 
        end
    end
    
    wire [N-1:0] net_in [0:K-1];
    wire [N-1:0] net_out [0:K-1];
    
    wire [N-1:0] net_i [0:K-1];
    wire [N-1:0] net_o0 [0:K-1];
    wire [N-1:0] net_o1 [0:K-1];
    wire [N-1:0] net_o2 [0:K-1];
    wire [N-1:0] net_o3 [0:K-1];
    wire [N-1:0] net_o4 [0:K-1];
    
    genvar i;
    generate
        for (i = 0; i < K; i = i + 1) begin: fbuffer
            fifo_prg #(
                .MEMORY_WIDTH(N),
                .MEMORY_SIZE(MEMORY_SIZE),
                .ADDRESS_SIZE(ADDRESS_SIZE)
            ) ffbuf (
                .clk(clock),
                .reset_n(reset_n),
                .enable(read),
                .data_in(net_in[i][N-1:0]),
                .size(SIZE[15:0]),
                .data_out(net_out[i][N-1:0])
            );
        end
        for (i = 0; i < K; i = i + 1) begin: rbuffer
            register5 #(N) regs(
                .clock(clock),
                .enable(read),
                .d(net_i[i][N-1:0]),
                .q0(net_o0[i][N-1:0]),
                .q1(net_o1[i][N-1:0]),
                .q2(net_o2[i][N-1:0]),
                .q3(net_o3[i][N-1:0]),
                .q4(net_o4[i][N-1:0])
            );
            assign net_i[i][N-1:0] = net_out[i][N-1:0];
        end
        for (i = 0; i < (K - 1); i = i + 1) begin: conn
            assign net_in[i+1][N-1:0] = net_o4[i][N-1:0];
        end
    endgenerate
    
    assign net_in[0][N-1:0] = pi[N-1:0];
    assign po00[N-1:0] = net_o0[0][N-1:0];
    assign po01[N-1:0] = net_o0[1][N-1:0];
    assign po02[N-1:0] = net_o0[2][N-1:0];
    assign po03[N-1:0] = net_o0[3][N-1:0];
    assign po04[N-1:0] = net_o0[4][N-1:0];
    assign po10[N-1:0] = net_o1[0][N-1:0];
    assign po11[N-1:0] = net_o1[1][N-1:0];
    assign po12[N-1:0] = net_o1[2][N-1:0];
    assign po13[N-1:0] = net_o1[3][N-1:0];
    assign po14[N-1:0] = net_o1[4][N-1:0];
    assign po20[N-1:0] = net_o2[0][N-1:0];
    assign po21[N-1:0] = net_o2[1][N-1:0];
    assign po22[N-1:0] = net_o2[2][N-1:0];
    assign po23[N-1:0] = net_o2[3][N-1:0];
    assign po24[N-1:0] = net_o2[4][N-1:0];
    assign po30[N-1:0] = net_o2[0][N-1:0];
    assign po31[N-1:0] = net_o2[1][N-1:0];
    assign po32[N-1:0] = net_o2[2][N-1:0];
    assign po33[N-1:0] = net_o2[3][N-1:0];
    assign po34[N-1:0] = net_o2[4][N-1:0];
    assign po40[N-1:0] = net_o2[0][N-1:0];
    assign po41[N-1:0] = net_o2[1][N-1:0];
    assign po42[N-1:0] = net_o2[2][N-1:0];
    assign po43[N-1:0] = net_o2[3][N-1:0];
    assign po44[N-1:0] = net_o2[4][N-1:0];
        
    reg _valid;
    always @(posedge clock) 
    begin
        if (reset_n) begin
            _valid <= read;
        end
        else begin
            _valid <= 1'b0;
        end
    end
    assign valid = _valid;
   
endmodule
//
module register3 #(
        parameter N = 8,
        parameter K = 3
    ) (
        input clock,
        input enable,
        input [N-1:0] d,
        output [N-1:0] q0,
        output [N-1:0] q1,
        output [N-1:0] q2
    );
    
    wire [N-1:0] net_i [0:K-1];
    wire [N-1:0] net_o [0:K-1];
    
    genvar i;
    generate
        for (i = 0; i < K; i = i + 1) begin: rbuff
            register1 #(N) regs (
                .clock(clock),
                .enable(enable),
                .d(net_i[i][N-1:0]),  
                .q(net_o[i][N-1:0])
            );
        end
    endgenerate
    
    generate
        for (i = 0; i < (K - 1); i = i + 1) begin: cbuff
            assign net_i[i+1][N-1:0] = net_o[i][N-1:0];        
        end
    endgenerate
    
    assign net_i[0][N-1:0] = d[N-1:0];
    assign q0[N-1:0] = net_o[0][N-1:0];
    assign q1[N-1:0] = net_o[1][N-1:0];
    assign q2[N-1:0] = net_o[2][N-1:0];

endmodule
//
module register5 #(
        parameter N = 8,
        parameter K = 5
    ) (
        input clock,
        input enable,
        input [N-1:0] d,
        output [N-1:0] q0,
        output [N-1:0] q1,
        output [N-1:0] q2,
        output [N-1:0] q3,
        output [N-1:0] q4
    );
    
    wire [N-1:0] net_i [0:K-1];
    wire [N-1:0] net_o [0:K-1];
    
    genvar i;
    generate
        for (i = 0; i < K; i = i + 1) begin: rbuff
            register1 #(N) regs (
                .clock(clock),
                .enable(enable),
                .d(net_i[i][N-1:0]),  
                .q(net_o[i][N-1:0])
            );
        end
    endgenerate
    
    generate
        for (i = 0; i < (K - 1); i = i + 1) begin: cbuff
            assign net_i[i+1][N-1:0] = net_o[i][N-1:0];        
        end
    endgenerate
    
    assign net_i[0][N-1:0] = d[N-1:0];
    assign q0[N-1:0] = net_o[0][N-1:0];
    assign q1[N-1:0] = net_o[1][N-1:0];
    assign q2[N-1:0] = net_o[2][N-1:0];
    assign q3[N-1:0] = net_o[3][N-1:0];
    assign q4[N-1:0] = net_o[4][N-1:0];

endmodule
//
// N bits register
//
module register1 #( 
        parameter N = 8
    ) (
        input clock,
        input enable,
        input [N-1:0] d,
        output [N-1:0] q
    );
   
   reg [N-1:0] _q;
   always @(posedge clock) begin
      if (enable) _q <= d;
   end
   assign q = _q;

endmodule
