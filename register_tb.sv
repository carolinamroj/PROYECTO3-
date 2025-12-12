
 module register_tb;
    // Señales
    logic CLK, RESET_N, RegWrite;
    logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    logic [31:0] WriteData, ReadData1, ReadData2;
    
    // Instancia del banco de registros
    register dut (
	  .CLK(CLK),
	  .RESET_N(RESET_N),
	  .RegWrite(RegWrite),
	  .ReadRegister1(ReadRegister1),
	  .ReadRegister2(ReadRegister2),
	  .WriteRegister(WriteRegister), 
	  .WriteData(WriteData),
	  .ReadData1(ReadData1), 
	  .ReadData2(ReadData2)
	  );
    
    // Generar reloj
    always #5 CLK = ~CLK;
    
    initial begin
        // Inicializar
        CLK = 0;
        RESET_N = 0;
        RegWrite = 0;
        ReadRegister1 = 0;
        ReadRegister2 = 0;
        WriteRegister = 0;
        WriteData = 0;
        
        // Test 1: Reset
        #20;
        RESET_N = 1;
        #10;
        
        // Test 2: Escribir en posición 0 (no debería escribir)
        RegWrite = 1;
        WriteRegister = 0;
        WriteData = 32'h12345678;
        #10;
        
        // Test 3: Escribir en 3 posiciones diferentes
        WriteRegister = 1;
        WriteData = 32'h11111111;
        #10;
        
        WriteRegister = 2;
        WriteData = 32'h22222222;
        #10;
        
        WriteRegister = 3;
        WriteData = 32'h33333333;
        #10;
        
        // Test 4: Leer esas posiciones
        ReadRegister1 = 1;
        ReadRegister2 = 2;
        #1;
        $display("Registro 1: %h, Registro 2: %h", ReadData1, ReadData2);
        
        ReadRegister1 = 3;
        #1;
        $display("Registro 3: %h", ReadData1);
        
        // Test 5: Verificar que x0 siempre es 0
        ReadRegister1 = 0;
        #1;
        $display("Registro 0: %h (debe ser 0)", ReadData1);
        
        $display("Test completado");
        $finish;
    end

endmodule 

