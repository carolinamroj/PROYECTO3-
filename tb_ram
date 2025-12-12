`timescale 1ns / 1ps
module tb_ram;

parameter WIDTH = 32;
parameter DEPTH = 1024;
parameter fichero = "basura.txt";

logic CLOCK, wren;
logic [WIDTH-1 :0] data_in;
logic [$clog2(DEPTH-1) -1:0] addr;
logic [WIDTH -1 :0] data_out;

parameter line= 24;
localparam limit_addr = DEPTH -1;
int i;
int dir;
int num_test = 10;

//INATANCIA DEL DUT

RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH), .fichero(fichero)) dut(
	.data_in(data_in),
	.wren(wren),
	.addr(addr),
	.CLOCK(CLOCK),
	.data_out(data_out)
);


initial begin 
	CLOCK = 0;
	forever #5 CLOCK = ~CLOCK; // periodo de 10 ns
end


task inicio;
	begin
		wren = 0;
		data_in = 0;
		addr = 0;
	@(negedge CLOCK);
	
	end 
endtask

task escritura (
	input [$clog2(DEPTH-1)-1:0] write_addr,
	input [WIDTH -1 : 0] write_data_in
);
	
	begin
		addr = write_addr;
		data_in = write_data_in;
		wren = 1;
		repeat(2) @(negedge CLOCK);
		wren = 0;
	end
endtask

//Lectura asincrona

task lectura (
	input [$clog2(DEPTH-1) -1:0] read_addr
);

	begin 
		addr = read_addr;
		repeat(2) @(negedge CLOCK);
	end
endtask

initial begin
	inicio();
	
	
	//PRUEBA PARA EL FICHERO
	
	// leer posiciones aleatorias del fichero
	for (i = 0; i< num_test; i++)
	begin
		dir = $urandom_range(0, line -1);
		lectura(dir);
		@(negedge CLOCK)
		
		$display("mem[%0d] = 0x%h (desde fichero %s)", dir, data_out, fichero);
	end
	
	// escrituras aleatorias
	
	for (i=0; i< num_test; i++)
	begin
		dir = $urandom_range(0, line -1);
		data_in = $urandom; // dato aleatorio de 32 bits
		
		escritura(dir, data_in);
		
		$display("Escrito 0x%h en mem[%0d]", data_in, dir);
	end
		
	// volver a leer para verificar los cambios
	
	for (i = 0; i< num_test; i++)
	begin
		dir = $urandom_range(0, line -1);
		lectura(dir);
		@(negedge CLOCK);
		$display("mem[%0d] = 0x%h",dir, data_out);
	end
		
	
	//OTRAS PRUEBAS
		
	// escribir
	escritura(0, 32'hF673E6AF);
	
	//leer el mismo valor 
	lectura(0);
	if (data_out == 32'hF673E6AF )
		$display("Resultado correcto : Leido 0x%h en la dir 0", data_out);
	else
		$display("Verificacion fallida: esperado 0xF673E6HG, obtenido 0x%h", data_out);
		
	escritura(100, 32'hC8743ED9);
	
	lectura(100);
	#2;
	if (data_out == 32'hC8743ED9)
		$display("Verificacion correcta: Leido 0x%h en la dir 100", data_out);
	else
		$display("Verificacion fallida: esperado 0xC8743ED9, obtenido 0x%h", data_out);
		
	//vuelvo a leer la primera direccion
	lectura(0);
	#2;
	if (data_out == 32'hF673E6AF )
		$display("Resultado correcto : Leido 0x%h en la dir 0", data_out);
	else
		$display("Verificacion fallida: esperado 0xF673E6HG, obtenido 0x%h", data_out);
	
	// escribir y leer en los limites 
	
	
	escritura(limit_addr, 32'hFF876ABF);
	lectura(limit_addr);
	
	if (data_out == 32'hFF876ABF)
		$display("Verificacion correcta: Leido 0x%h en la direccion limite ", data_out);
	else
		$display("Verificacion fallida: esperado 0xFF876ABF, obtenido 0x%h", data_out);
		
		
	repeat(5) @(negedge CLOCK);
	$display("FINALIZADO");
	$finish;
end

endmodule

	
