module part2(input [8:0]SW,
				 input [1:0]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [0:0]LEDG);

	wire [3:0]sum,BCD0,BCD1;
	eight_bit_FA addr(SW[8],SW[3:0],SW[7:4],1'b0,KEY[1],KEY[0],sum,LEDG[0]);
	BINtoBCD BIN1(sum,BCD0,BCD1);
	BCDto7 hex0(BCD0,HEX0);
	BCDto7 hex1(BCD1,HEX1);

endmodule

module fullAddr(input a,
					 input b,
					 input ci,
					 output s,
					 output co);
					 
	assign k = a^b;
	assign s = ci^k;
	assign co = ~k&b | k&ci;
	
endmodule 

module eight_bit_FA(input sub,
						  input [3:0]A,
						  input [3:0]B,
						  input Cin,
						  input clk,
						  input reset,
						  output [3:0]S,
						  output Overflow);

	wire [3:0]num1,numOut;
	reg [3:0]num2;
	wire Cout;
	wire [2:0]tmpCarry;
	
	always@(posedge clk or negedge reset)
	begin
		if (reset == 0)
				num2 = 4'b0;
		else 
			begin
				if (sub == 0)
					num2 = B;
				else 
					num2 = ~B + 1'b1;
			end
	end
	
	register R0(A,clk,reset,num1);
	register R2(numOut,clk,reset,S);
	register R3((Cout ^ tmpCarry[2]),clk,reset,Overflow);
	 
	fullAddr bit0(num1[0],num2[0],Cin,numOut[0],tmpCarry[0]);
	fullAddr bit1(num1[1],num2[1],tmpCarry[0],numOut[1],tmpCarry[1]);
	fullAddr bit2(num1[2],num2[2],tmpCarry[1],numOut[2],tmpCarry[2]);
	fullAddr bit3(num1[3],num2[3],tmpCarry[2],numOut[3],Cout);
endmodule

module register(input [3:0]in,
					 input clk,
					 input reset,
					 output reg [3:0]out);

	always@(posedge clk or negedge reset)
	begin
		if (reset == 0)
			out <= 4'b0;
		else 
			out <= in;
	end
					 
endmodule

module BCDto7(input [3:0]sw,
				 output [6:0]hex);
				 
	assign hex[0] =  ~(sw[3] | sw[1] | (sw[2] ~^ sw[0]));
	assign hex[1] =  ~(~sw[2] | (sw[0] ~^ sw[1]));
	assign hex[2] =  ~(sw[2] | ~sw[1] | sw[0]);
	assign hex[3] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0] | sw[2]&~sw[1]&sw[0] | ~sw[2]&sw[1] | sw[3]);
	assign hex[4] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0]);
	assign hex[5] =  ~(sw[3] | ~sw[1]&~sw[0] | sw[2]&~sw[1] | sw[2]&~sw[0]);
	assign hex[6] =  ~(sw[3] | sw[1]&~sw[0] | sw[2]^sw[1]);
	
endmodule

module BINtoBCD(input [3:0]BIN,
					 output [3:0]bcd0,
					 output [3:0]bcd1);

	assign bcd0 = BIN%10;
	assign bcd1 = BIN/10;
endmodule

module tb();
	
	reg [3:0]A;
	reg [3:0]B;
	reg reset,clk,sub;
	wire	[6:0]hex0,hex1;
	wire ledg;
	
	part2 test({sub,B,A},{clk,reset},hex0,hex1,ledg);
	
	initial begin
		#0 	clk = 1'b1;	reset = 1'b1;	A = 4'd2;	B = 4'd3; sub = 1;
		#100	clk = 1'b1;	reset = 1'b0;	
		#100	clk = 1'b0;	reset = 1'b1;
		#100	clk = 1'b1;
		#100  clk = 1'b0;
		#100	clk = 1'b1;
		#100	;
	end	
	
endmodule