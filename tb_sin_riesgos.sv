`timescale 1ns / 1ps

 module tb_sin_riesgos;
 
	logic CLK;
	logic RESET_N;
	localparam ficheroram = "DATA.txt";
	localparam ficherorom = "FIBONACCI.txt";
	
	pipelined_sin_riesgos # (.ficheroram(ficheroram), .ficherorom(ficherorom)) uut (
	.CLK(CLK),
	.RESET_N(RESET_N)
	);
	
	
	always 
		begin
			CLK = 0; 
			#10; 
			CLK = 1; 
			#10; 
		end
 
 initial 
	begin
		RESET_N = 0; 
		
		$display("Inicio de la simulacion...");
		
		#50; 
		RESET_N = 1; // Desactivamos reset, el procesador arranca
		$display("Reset liberado. Procesador corriendo.");
		
		// Tiempo Extendido: 50,000 ns (Para el ordenamiento)
		#50000; 
		
		$display("Fin de la simulacion.");
		$stop; 
	end
 
 endmodule
