module part2(input [1:0]SW,
				 output [1:0]LEDR);
			wire [1:0]sw,ledr;
			assign sw[1:0] = SW[1:0];
			assign LEDR[0] = ledr[0];
			assign LEDR[1] = ~ledr[0];
			
			Dlat D1(sw[0],sw[1],ledr[0]);	 
endmodule

module Dlat(input D,
				 input Clk,
				 output Q);

	wire S_g,R_g,Clk_g,Qa,Qb/*synthesis keep*/;
	
	assign S_g = D&Clk;
	assign R_g = ~D&Clk;
	assign Qa = ~(R_g|Qb);
	assign Qb = ~(S_g|Qa);
	
	assign Q = Qa;
	
endmodule 

module tb();
	wire Q;
	reg Clk;
	reg D;
	
	Dlat test(D,Clk,Q);
	
	initial begin 
		#0		Clk = 1;	D = 1;
		#100	Clk = 0; D = 0;
		#100	Clk = 1;	D = 0;
		#100 	Clk = 0;	D = 1;
		#100 	Clk = 1;	D = 1;
		#100;
	end
endmodule
