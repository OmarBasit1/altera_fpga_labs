module part4(input D,
				 input Clk,
				 output Qa,
				 output Qb,
				 output Qc);
	Dlat D1(D,Clk,Qa);
	Dflipflop Dpos(D,Clk,Qb);
	Dflipflop Dneg(D,~Clk,Qc);
endmodule 

module Dlat(input D,
				 input Clk,
				 output Q);
	wire S_g,R_g,Clk_g,Qa,Qb;
	assign S_g = D&Clk;
	assign R_g = ~D&Clk;
	assign Qa = ~(R_g|Qb);
	assign Qb = ~(S_g|Qa);
	assign Q = Qa;
endmodule

module Dflipflop(input D,
				 input Clk,
				 output Q);
	wire Qs;
	assign Q = Qs;
	Dlat Master(D,~Clk,Qm);
	Dlat Slave(Qm,Clk,Qs);
endmodule


module tb();
	reg D,Clk;
	wire Qa,Qb,Qc;
	
	part4 test(D,Clk,Qa,Qb,Qc);
	
	initial begin
	#0 	Clk = 0;	D = 0;
	#100	Clk = 0;	D = 0;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 1;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 0;
	#100  Clk = 0;	D = 0;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 0;
	#100  Clk = 0;	D = 0;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 1;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 0;
	#100	Clk = 1;	D = 1;
	#100  Clk = 0;	D = 1;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 1;
	#100	Clk = 0;	D = 0;
	#100;	
	end
endmodule 