
 module register (

 input logic CLK,
 input logic RESET_N,
 input logic RegWrite,
 input logic [4:0] ReadRegister1,
 input logic [4:0] ReadRegister2,
 input logic [4:0] WriteRegister,
 input  logic [31:0] WriteData,
 
 output logic [31:0] ReadData1,
 output logic [31:0] ReadData2
 );
 
 logic [31:0] register_file [0:31];
 
 always_ff @(posedge CLK or negedge RESET_N)
	begin
		if (!RESET_N)
			begin
				for (int i = 0; i < 32; i++)
					begin
						register_file[i] <= 32'b0;
					end
			end
		else if (RegWrite && (WriteRegister != 5'b0))
			begin
				register_file[WriteRegister] <= WriteData;
			end
	end
	
	
	assign ReadData1 = (ReadRegister1 == 5'b0) ? 32'b0 : register_file[ReadRegister1];
	assign ReadData2 = (ReadRegister2 == 5'b0) ? 32'b0 : register_file[ReadRegister2];
	
 endmodule 
 
 
  

