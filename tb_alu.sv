`timescale 1ns / 1ps

module tb_alu;

    logic [31:0] tb_src_a;
    logic [31:0] tb_src_b;
    logic [4:0]  tb_alu_control;
    logic [31:0] tb_alu_result;
    logic        tb_zero;

    typedef enum logic [4:0] {
        ALU_ADD  = 5'b00000,
        ALU_SUB  = 5'b00001,
        ALU_SLL  = 5'b00010,
        ALU_SLT  = 5'b00011,
        ALU_SLTU = 5'b00100,
        ALU_XOR  = 5'b00101,
        ALU_SRL  = 5'b00110,
        ALU_SRA  = 5'b00111,
        ALU_OR   = 5'b01000,
        ALU_AND  = 5'b01001
    } alu_op_t;

    alu dut (
        .src_a(tb_src_a),
        .src_b(tb_src_b),
        .alu_control(tb_alu_control),
        .alu_result(tb_alu_result),
        .zero(tb_zero)
    );

    initial begin
        $display("=== INICIANDO TEST DE ALU TINUC ===");


        tb_src_a = 32'd10;
        tb_src_b = 32'd20;
        tb_alu_control = ALU_ADD;
        #10; 
        check_result(32'd30, "ADD (10 + 20)");

        
        tb_src_a = 32'd15;
        tb_src_b = 32'd15; 
        tb_alu_control = ALU_SUB;
        #10;
        check_result(32'd0, "SUB (15 - 15)");
        if (tb_zero !== 1'b1) $error("FALLO: Flag Zero no se activó.");
        else $display("PASS: Flag Zero correcto");


        tb_src_a = 32'h0000FFFF;
        tb_src_b = 32'hFFFF0000;
        tb_alu_control = ALU_AND;
        #10;
        check_result(32'h00000000, "AND (No overlap)");


        tb_src_a = 32'h0000FFFF;
        tb_src_b = 32'hFFFF0000;
        tb_alu_control = ALU_OR;
        #10;
        check_result(32'hFFFFFFFF, "OR (Full fill)");

        tb_src_a = -32'd10; 
        tb_src_b = 32'd5;
        tb_alu_control = ALU_SLT;
        #10;
        check_result(32'd1, "SLT (-10 < 5)");

        tb_src_a = -32'd10; 
        tb_src_b = 32'd5;
        tb_alu_control = ALU_SLTU;
        #10;
        check_result(32'd0, "SLTU (HugeNum < 5 -> False)");

        tb_src_a = -32'd8;
        tb_src_b = 32'd1;
        tb_alu_control = ALU_SRA;
        #10;
        check_result(-32'd4, "SRA (-8 >>> 1 = -4)");

        tb_src_a = -32'd8;
        tb_src_b = 32'd1;
        tb_alu_control = ALU_SRL;
        #10;
		  
        check_result(32'h7FFFFFFC, "SRL (-8 >> 1 = Large Pos)");

        $display("=== TEST FINALIZADO ===");
        $finish;
    end

    task check_result(input [31:0] expected, input string test_name);
        if (tb_alu_result === expected) begin
            $display("PASS: %s | Output: %h", test_name, tb_alu_result);
        end else begin
            $error("FAIL: %s | Esperado: %h | Obtenido: %h", test_name, expected, tb_alu_result);
        end
    endtask

endmodule	
