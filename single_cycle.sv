
 module single_cycle (
	input  logic CLK,  
	logic RESET_N 
	);
	
	// Interfaz ROM
	logic [31:0] iaddr;
	logic [31:0] idata;
	
	// Interfaz RAM  
	logic [31:0] daddr;  
	logic [31:0] ddata_w;
	logic [31:0] ddata_r;
	logic        d_w;
	logic        d_r;
	
	
	// CORE
	core_riscv (
	.CLK(CLK),
	.reset(RESET_N),
	.idata(idata) //Instrucciones
	.iaddr(iaddr) //Direccionamiento ROM
	.ddata_r(ddata_r) //Datos  leidos de la RAM
	.daddr(daddr) //Direccionamiento RAM
	.ddata_w(ddata_w) //Datos escribir en la RAM
	.d_w(d_w) //enable escritura RAM
	.d_r(d_r) //enable lectura RAM, no utilizado en single cycle
	;)
	
	// ROM
	ROM instruction_memory (
	.ADDR(iaddr[9:0]), // Dirección
	.DOUT(idata) // Instrucción leída
    );

	// RAM  
	RAM (
	.CLOCK(CLK),
	.wren(d_w), //Habilitación escritura
	.addr(d_r[9:0]), //Dirección
	.data_in(ddata_w), // Datos a escribir
	.data_out(ddata_r) // Datos leidos
    );

endmodule 


