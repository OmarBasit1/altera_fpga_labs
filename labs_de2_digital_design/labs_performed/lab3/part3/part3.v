module part3(input [1:0]SW,
				 output [1:0]LEDR);

	Dflipflop D1(SW[0],SW[1],LEDR[0],LEDR[1]);

endmodule

module Dflipflop(input D,
				 input Clk,
				 output Q,
				 output Qnot);
	wire Qs;
	assign Q = Qs;
	assign Qnot  = ~Qs;
	
	Dlat Master(D,~Clk,Qm);
	Dlat Slave(Qm,Clk,Qs);
	
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
	reg [1:0]sw;
	wire [1:0]ledr;
	
	part3 test(sw,ledr);
	
	initial begin
	#0		sw = 2'b00;
	#100 	sw = 2'b10;
	#100 	sw = 2'b00;
	#100 	sw = 2'b10;
	#100 	sw = 2'b01;
	#100 	sw = 2'b11;
	#100 	sw = 2'b00;
	#100 	sw = 2'b11;
	#100 	sw = 2'b00;
	#100 	sw = 2'b00;
	#200  ;
	end
endmodule
