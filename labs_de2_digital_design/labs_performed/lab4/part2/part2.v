module part1(input [2:0]KEY,
				 output [15:0]num);
	
	counter c1(KEY[2],KEY[1],KEY[0],num[15:0]);
	
endmodule

module T_ff(input t,
			  input clk,
			  input rst,
			  output reg Q);

	initial begin
		Q = 1'b0;
	end
			  
	always@(posedge clk or negedge rst)
		if (~rst)
			Q = 1'b0;
		else
		begin
			if (clk)
				if (t)
					Q = ~Q;
		end
	
endmodule

module counter(input Enable,
					input Clk,
					input Rst,
					output [15:0]num);
	
	wire [15:0]t;
	assign t[0] = Enable;
	assign t[1] = num[0]&t[0];
	assign t[2] = num[1]&t[1];
	assign t[3] = num[2]&t[2];
	assign t[4] = num[3]&t[3];
	assign t[5] = num[4]&t[4];
	assign t[6] = num[5]&t[5];
	assign t[7] = num[6]&t[6];
	assign t[8] = num[7]&t[7];
	assign t[9] = num[8]&t[1];
	assign t[10] = num[9]&t[9];
	assign t[11] = num[10]&t[10];
	assign t[12] = num[11]&t[11];
	assign t[13] = num[12]&t[12];
	assign t[14] = num[13]&t[13];
	assign t[15] = num[14]&t[14];
	
	T_ff c_0(t[0],Clk,Rst,num[0]);
	T_ff c_1(t[1],Clk,Rst,num[1]);
	T_ff c_2(t[2],Clk,Rst,num[2]);
	T_ff c_3(t[3],Clk,Rst,num[3]);
	T_ff c_4(t[4],Clk,Rst,num[4]);
	T_ff c_5(t[5],Clk,Rst,num[5]);
	T_ff c_6(t[6],Clk,Rst,num[6]);
	T_ff c_7(t[7],Clk,Rst,num[7]);
	T_ff c_8(t[8],Clk,Rst,num[8]);
	T_ff c_9(t[9],Clk,Rst,num[9]);
	T_ff c_10(t[10],Clk,Rst,num[10]);
	T_ff c_11(t[11],Clk,Rst,num[11]);
	T_ff c_12(t[12],Clk,Rst,num[12]);
	T_ff c_13(t[13],Clk,Rst,num[13]);
	T_ff c_14(t[14],Clk,Rst,num[14]);
	T_ff c_15(t[15],Clk,Rst,num[15]);
					
endmodule

module tb();
	
	reg T;
	reg Clk;
	reg Rst;
	wire [15:0]num;
	
	counter c1(T,Clk,Rst,num[15:0]);
	
	initial begin
		#0		Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b0; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b1; T = 1'b1;
		#100 	Rst = 1'b1; Clk = 1'b0; T = 1'b1;
		#100 ;
	end
	
endmodule


					