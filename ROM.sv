module ROM (ADDR, DOUT);

input [9:0] ADDR;
output logic [31:0] DOUT;

parameter d_ancho = 32;
parameter a_ancho = 10;

logic [d_ancho-1:0] mem[(1<<a_ancho)-1:0];

initial
	$readmemh ("FIBONACCI.txt",mem);
	
assign DOUT = mem[ADDR];
endmodule
