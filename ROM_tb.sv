`timescale 1ns/1ps

module ROM_tb;

    // Parámetros locales del TB
    parameter D_ANCHO = 32;
    parameter A_ANCHO = 10;

    logic [A_ANCHO-1:0] ADDR;
    logic [D_ANCHO-1:0] DOUT;

    // Instancia del DUT indicando qué archivo debe leer
    ROM #(
        .fichero("Programainst.txt")
    ) dut (
        .ADDR(ADDR),
        .DOUT(DOUT)
    );

    initial begin
        $display("Iniciando simulación con archivo Programainst.txt...");
        ADDR = 0;

        // Leer primeras direcciones para verificar
        repeat (20) begin
            #10;
            $display("ADDR = %0d | DOUT = %h", ADDR, DOUT);
            ADDR++;
        end

        $display("Fin de la simulación.");
        #10 $finish;
    end

endmodule