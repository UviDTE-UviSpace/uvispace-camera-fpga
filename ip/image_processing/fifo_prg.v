///
/// Memoria FIFO de tamaño programable
///
/// Proporciona los datos en la misma secuencia de entrada, pero retardados
/// un cierto valor indicado por el tamaño (size) de la FIFO, mientras que
/// el tamaño de la memoria viene establecido por el parámetro MEMORY_SIZE.
///
/// Para ello, cuando su funcionamiento se encuentra desinhibido (ena) graba
/// un dato a cada flanco de reloj (clk).
///
/// Los parámetros MEMORY_WIDTH y MEMORY_SIZE establecen el ancho de dato y 
/// el tamaño físico de la memoria que será utilizada por la FIFO.
/// 
module fifo_prg #(
        parameter MEMORY_WIDTH = 3,
        parameter MEMORY_SIZE = 4096,
        parameter ADDRESS_SIZE = 12,
        parameter WORD_SIZE = MEMORY_WIDTH,
        parameter N = MEMORY_WIDTH 
    ) (
        input clk,
        input reset_n,
        input enable,
        input [N-1:0] data_in,
        input [15:0] size,
        output [N-1:0] data_out
    );
    
    reg [15:0] write_pointer;
    reg [15:0] read_pointer;
    
    always @(posedge clk)
    begin
        if (reset_n) begin
            if (enable) begin
                if (write_pointer < size - 1) begin
                    write_pointer[15:0] <= write_pointer[15:0] + 16'd1;
                end
                else begin
                    write_pointer[15:0] <= 16'd0; 
                end
                if (read_pointer < size - 1) begin
                    read_pointer[15:0] <= read_pointer[15:0] + 16'd1;
                end
                else begin
                    read_pointer[15:0] <= 16'd0;
                end
            end
        end
        else begin
            write_pointer[15:0] <= 16'd0;
            read_pointer[15:0] <= 16'd1;
        end
    end
        
    // RAM memory
    ff_ram #(
        .WORD_SIZE(WORD_SIZE),
        .ADDRESS_SIZE(ADDRESS_SIZE)
    ) mem (
        .clock(clk),
        .enable(enable),
        .address_write(write_pointer[ADDRESS_SIZE-1:0]),
        .write(enable),
        .data_in(data_in[WORD_SIZE-1:0]),
        .address_read(read_pointer[ADDRESS_SIZE-1:0]),
        .read(enable),
        .data_out(data_out[WORD_SIZE-1:0])
    );
   
endmodule
//
// Bloque de memoria RAM con lectura y escritura en el mismo ciclo
//
module ff_ram #(
        parameter WORD_SIZE = 3,
        parameter ADDRESS_SIZE = 12,
        parameter FILENAME = "memory.bin"
    ) ( 
        input clock,
        input enable, 
        input [ADDRESS_SIZE-1:0] address_write,
        input write,
        input [WORD_SIZE-1:0] data_in,
        input [ADDRESS_SIZE-1:0] address_read,
        input read,
        output [WORD_SIZE-1:0] data_out
    );
    
    reg [WORD_SIZE-1:0] data [0:(1<<ADDRESS_SIZE)-1];
    //initial $readmemb (FILENAME, data);
    
    reg [WORD_SIZE-1:0] _data_out;
    always @(posedge clock) begin
        if (enable) begin
            if (read) begin
                _data_out = data[address_read];
            end
            if (write) begin
                data[address_write] = data_in;
            end
        end
    end
    assign data_out = _data_out;
    
endmodule
