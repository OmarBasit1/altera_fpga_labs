module part1(SW,LEDR);
	input [17:0]SW;
	output[17:0]LEDR;
	
	assign LEDR = SW;
endmodule

module tb;
	wire [17:0] LEDR;
	reg [17:0] SW;
	
	part1 p (SW, LEDR);
	
	initial begin 
		#0 SW = 0;
		#100 SW = 69;
		#100 SW = 96;
	end
endmodule

