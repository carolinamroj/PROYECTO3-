/**
 * Módulo: ALU (Unidad Aritmético-Lógica)
 * Proyecto: TinuC (RISC-V 32-bit Subset)
 * Descripción: ALU combinacional pura con soporte para operaciones
 * aritméticas, lógicas, desplazamientos y comparaciones.
 */

module alu (
    input  logic [31:0] src_a,       // Operando A (x[rs1] o PC)
    input  logic [31:0] src_b,       // Operando B (x[rs2] o Inmediato)
    input  logic [4:0]  alu_control, // Señal de control (según Fig. 3)
    output logic [31:0] alu_result,  // Resultado de la operación
    output logic        zero         // Flag Zero (para BEQ/BNE)
);
	
    // Definición de códigos de operación (ALU Control)
    // Se pueden ajustar según lo que decida tu decodificador (Unit ID)
    typedef enum logic [4:0] {
        ALU_ADD  = 5'b00000, // ADD, ADDI, LW, SW, AUIPC, JAL...
        ALU_SUB  = 5'b00001, // SUB, BEQ, BNE
        ALU_SLL  = 5'b00010, // SLL, SLLI
        ALU_SLT  = 5'b00011, // SLT, SLTI (Set Less Than Signed)
        ALU_SLTU = 5'b00100, // SLTU, SLTIU (Set Less Than Unsigned)
        ALU_XOR  = 5'b00101, // XOR, XORI
        ALU_SRL  = 5'b00110, // SRL, SRLI
        ALU_SRA  = 5'b00111, // SRA, SRAI (Arithmetic shift)
        ALU_OR   = 5'b01000, // OR, ORI
        ALU_AND  = 5'b01001  // AND, ANDI
        // LUI se maneja pasando op_a=0 y op_b=imm en la etapa anterior, usando ALU_ADD
    } alu_op_t;

    always_comb begin
        // Valor por defecto para evitar latches
        alu_result = '0;

        case (alu_control)
            ALU_ADD:  alu_result = src_a + src_b;
            
            ALU_SUB:  alu_result = src_a - src_b;
            
            ALU_AND:  alu_result = src_a & src_b;
            
            ALU_OR:   alu_result = src_a | src_b;
            
            ALU_XOR:  alu_result = src_a ^ src_b;
            
            // Desplazamientos: RISC-V usa solo los 5 bits menos significativos de src_b
            ALU_SLL:  alu_result = src_a << src_b[4:0];
            
            ALU_SRL:  alu_result = src_a >> src_b[4:0];
            
            // Desplazamiento Aritmético (Mantiene el signo)
            // Importante: Castear a $signed para que SystemVerilog use '>>>' correctamente
            ALU_SRA:  alu_result = $signed(src_a) >>> src_b[4:0];

            // Comparaciones (Set Less Than)
            // SLT (Con signo)
            ALU_SLT:  alu_result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;
            
            // SLTU (Sin signo - Comparación natural de enteros)
            ALU_SLTU: alu_result = (src_a < src_b) ? 32'd1 : 32'd0;

            default:  alu_result = 32'b0; // Operación segura por defecto
        endcase
    end

    // Generación del flag Zero
    // Se activa si el resultado es 0. Útil para ramas (Branches) BEQ/BNE.
    // Nota: Para BEQ, la ALU hace una resta (SUB). Si A==B, A-B=0 -> Zero=1.
    assign zero = (alu_result == 32'b0);

endmodule