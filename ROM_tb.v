'timescale 1ns/1ps

module ROM_tb;

    // Parámetros
    parameter D_ANCHO = 32;
    parameter A_ANCHO = 10;

    // Señales
    logic [A_ANCHO-1:0] ADDR;
    logic [D_ANCHO-1:0] DOUT;

    string file_name;

    // DUT
    ROM dut (
        .ADDR(ADDR),
        .DOUT(DOUT)
    );

    // Sobrescribir el archivo de memoria mediante plusargs
    initial begin
        if ($value$plusargs("FILE=%s", file_name)) begin
            $display("---- Cargando archivo de memoria: %s ----", file_name);
            $readmemh(file_name, dut.mem);
        end else begin
            $display("---- Usando archivo por defecto: algoritmosel.txt ----");
        end
    end

    // Estímulos
    initial begin
        $display("Iniciando simulación ROM...");
        ADDR = 0;

        repeat (20) begin
            #10;
            $display("ADDR = %0d | DOUT = %h", ADDR, DOUT);
            ADDR++;
        end

        $display("Fin de simulación.");
        #20 $finish;
    end

endmodule