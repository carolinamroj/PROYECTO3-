module RAM (data_in, wren, addr, CLOCK, data_out );

parameter WIDTH = 32;
parameter DEPTH = 1024;

input wren, CLOCK;
input [WIDTH-1 :0] data_in;
input [$clog2(DEPTH-1)-1:0] addr;
//input [$clog2(DEPTH-1)-1 :0] address;
output logic [WIDTH -1 :0] data_out;

logic [WIDTH -1 :0] mem [(1<<WIDTH) -1 :0]; // ancho de palabra y cantidad depalabras

always_ff @(posedge CLOCK)
begin

	if (wren) // se activa la escritura
		mem[addr] <= data_in; // direccion donde escribo data_in
			
			//lectura asincrona
			
	
end

assign data_out = mem[addr]; //direccion donde leo data_out
endmodule
