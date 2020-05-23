module part8(input [7:0]SW,
				 input [3:0]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3,
				 output [0:0]LEDG);

	reg [7:0]A,B,C,D;
	wire [15:0]S;
	wire [15:0]tmpmul1,tmpmul2;
	
	always@(negedge KEY[2])
	begin
		if (KEY[1] == 0)
			begin
			if (KEY[0] == 0)
			begin
				A[7:0] = SW[7:0];
			end
			else 
			begin
				B[7:0] = SW[7:0];
			end
			end
		else
			begin
			if (KEY[0] == 0)
			begin
				C[7:0] = SW[7:0];
			end
			else 
			begin
				D[7:0] = SW[7:0];
			end
		end
	end
	
	mult_lpm one(KEY[3],KEY[2],A,B,tmpmul1);
	mult_lpm two(KEY[3],KEY[2],C,D,tmpmul2);
	add_lpm three(KEY[3],KEY[2],tmpmul1,tmpmul2,LEDG[0],S);
	
	HexDisp Disp0(S[3:0], HEX0[6:0]);
	HexDisp Disp1(S[7:4], HEX1[6:0]);
	HexDisp Disp2(S[11:8], HEX2[6:0]);
	HexDisp Disp3(S[15:12], HEX3[6:0]);
	
endmodule


module HexDisp(input [3:0]sw,
				   output [6:0]hex0);
	assign hex0[0] =  ~(sw[3] | sw[1] | (sw[2] ~^ sw[0]));
	assign hex0[1] =  ~(~sw[2] | (sw[0] ~^ sw[1]));
	assign hex0[2] =  ~(sw[2] | ~sw[1] | sw[0]);
	assign hex0[3] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0] | sw[2]&~sw[1]&sw[0] | ~sw[2]&sw[1] | sw[3]);
	assign hex0[4] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0]);
	assign hex0[5] =  ~(sw[3] | ~sw[1]&~sw[0] | sw[2]&~sw[1] | sw[2]&~sw[0]);
	assign hex0[6] =  ~(sw[3] | sw[1]&~sw[0] | sw[2]^sw[1]);
endmodule
