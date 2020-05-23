module part5(input [7:0]SW,
				 input [1:0]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);
	
	wire [7:0]BinA;
	wire [3:0]hexA0,hexA1,hexB0,hexB1;
	
	sixd_flipflop register(SW[7:0],KEY[1],KEY[0],BinA[7:0]);
	Bin2HEX B2HA(BinA[7:0],hexA0[3:0],hexA1[3:0]);
	Bin2HEX B2HB(SW[7:0],hexB0[3:0],hexB1[3:0]);
	HEXto7 h0(hexB0[3:0],HEX0[6:0]);
	HEXto7 h1(hexB1[3:0],HEX1[6:0]);
	HEXto7 h2(hexA0[3:0],HEX2[6:0]);
	HEXto7 h3(hexA1[3:0],HEX3[6:0]);
endmodule



module HEXto7(input [3:0]sw,
				 output [6:0]_hex);
	reg [6:0]hex;
	assign _hex = ~hex;
	always@(*)
		case(sw)
			4'b0000 :
			hex = 7'h3f;
			4'b0001 :
			hex = 7'h06;
			4'b0010 :
			hex = 7'h5b;
			4'b0011 :
			hex = 7'h4f;
			4'b0100 :
			hex = 7'h66;
			4'b0101 :
			hex = 7'h6d;
			4'b0110 :
			hex = 7'h7d;
			4'b0111 :
			hex = 7'h07;
			4'b1000 :
			hex = 7'h7f;
			4'b1001 :
			hex = 7'h67;
			4'b1010 :
			hex = 7'h77;
			4'b1011 :
			hex = 7'h7c;
			4'b1100 :
			hex = 7'h39;
			4'b1101 :
			hex = 7'h5e;
			4'b1110 :
			hex = 7'h79;
			4'b1111 :
			hex = 7'h71;
			endcase
endmodule 

module Bin2HEX(input [7:0]bin,
					output [3:0]HEXlow,
					output [3:0]HEXhigh);
					
	assign HEXlow[3:0] = bin[3:0];
	assign HEXhigh[3:0] = bin[7:4];
					
endmodule

module d_flipflop(input D,
			  input Clk,
			  input Rst,
			  output reg Q);
	
	always@(posedge Clk or negedge Rst)
	if (Rst==0)
		Q = 0;
	else
		Q = D;
	
endmodule 

module sixd_flipflop(input [7:0]D,
				  input Clk,
				  input Rst,
			     output [7:0]Q);
			
	d_flipflop zero(D[0],Clk,Rst,Q[0]);
	d_flipflop one(D[1],Clk,Rst,Q[1]);
	d_flipflop two(D[2],Clk,Rst,Q[2]);
	d_flipflop three(D[3],Clk,Rst,Q[3]);
	d_flipflop four(D[4],Clk,Rst,Q[4]);
	d_flipflop five(D[5],Clk,Rst,Q[5]);
	d_flipflop six(D[6],Clk,Rst,Q[6]);
	d_flipflop seven(D[7],Clk,Rst,Q[7]);
	
endmodule 

module tb();
	reg [7:0]SW;
	reg [1:0]KEY;
	wire [6:0]HEX0;
	wire [6:0]HEX1;
	wire [6:0]HEX2;
	wire [6:0]HEX3;
	
	part5 test(SW[7:0],KEY[1:0],HEX0[6:0],HEX1[6:0],HEX2[6:0],HEX3[6:0]);
	
	initial begin
		#0 	SW = 8'h23;	KEY = 2'b01;
		#100	SW = 8'h23;	KEY = 2'b00;
		#100	SW = 8'h23;	KEY = 2'b01;
		#100	SW = 8'h23;	KEY = 2'b11;
		#100	SW = 8'h23;	KEY = 2'b11;
		#100	SW = 8'h23;	KEY = 2'b01;
		#100	SW = 8'h59;	KEY = 2'b01;
		#100	SW = 8'h59;	KEY = 2'b01;
		#100	SW = 8'h59;	KEY = 2'b00;
		#100	SW = 8'h59;	KEY = 2'b01;
		#100;
		
	end
endmodule 