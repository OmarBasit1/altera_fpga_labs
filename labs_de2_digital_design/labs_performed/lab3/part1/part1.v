module part1(input Clk,
				 input R,
				 input S,
				 output Q);

	wire R_g, S_g,Qa,Qb /*synthesis keep*/;
	
	assign R_g = R & Clk;
	assign S_g = S & Clk;
	assign Qa = ~(R_g|Qb);
	assign Qb = ~(S_g|Qa);
	
	assign Q = Qa;
endmodule 

module tb();
	
	reg Clk;
	reg R;
	reg S;
	wire Q;
	
	part1 test(Clk,R,S,Q);
	
	initial begin
		#0 	Clk = 1;	R = 1;	S = 0;
		#100 	Clk = 0; R = 1;	S = 0;
		#100 	Clk = 0;	R = 0;	S = 1;
		#100 	Clk = 1; R = 0;	S = 1;
		#100;
	end
endmodule