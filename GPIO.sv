module GPIO (clk,reset_n, botones,data_in, addr, rd_en, wr_en, data_out, leds_botones, leds_rojos, hex0, hex1);

input clk;
input reset_n;
input logic [3:0] botones;
input [31:0] data_in;
input [1:0] addr;
input rd_en;
input wr_en;
output logic [31:0] data_out;
output logic [3:0] leds_botones;
output logic [17:0] leds_rojos;
output logic [7:0] hex0;
output logic [7:0] hex1;


logic [31:0] registros[0:1];
logic [3:0] pulso_button_reg, button_reg, button_reg2, button_reg3;

//actualizar registros
always_ff @(posedge clk or negedge reset_n)
begin

	if(!reset_n) 
	begin
	data_out <= 32'b0;
	button_reg <= 4'b0;
	button_reg2 <= 4'b0;
	button_reg3 <= 4'b0;
	registros [0] <= 32'b0;
	registros [1] <= 32'b0;
	registros [2] <= 32'b0;
	registros [3] <= 32'b0;
	
	end
	
	else
	begin
	if (wr_en)
	begin
		registros [addr] <= data_in;
	end
	
	button_reg <= botones;
	button_reg2 <= button_reg;
	button_reg3 <= button_reg2;
	
	
	for (integrer i = 0; i <4; i = i = 1)
		if (pulso_button_reg [i])
			registro [0][1] <= 1'b1;
			
	if (rd_en) 
	begin
		data_out <= registros [addr];
	end
end
	
assign hex0 = registros [2] [7:0];
assign hex1 = registros [3] [7:0];
assign leds_rojos = registro [1] [17:0];
assign leds_botones = registros [0] [3:'0];

assign pulso_button_reg = ~button_reg2 & button_reg3;

endmodule 
	
	