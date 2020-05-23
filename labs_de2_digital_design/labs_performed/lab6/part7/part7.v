module part7(input [7:0]SW,
				 input [2:0]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);

reg [7:0]dataa;
reg [7:0]datab;
wire [15:0]result;
wire [3:0]hexa,hexb,hexc,hexd;

always@(*)
begin
	if (KEY[0] == 0)
		dataa[7:0] = SW[7:0];
	if (KEY[1] == 0)
		datab[7:0] = SW[7:0];
	if (KEY[2] == 0)
		begin
		datab[7:0] = 8'b0;
		dataa[7:0] = 8'b0;
		end
end
				 
mult_lpm mult(dataa,datab,result);
			 


HexDisp one(result[3:0],HEX0);
HexDisp two(result[7:4],HEX1);
HexDisp three(result[11:8],HEX2);
HexDisp four(result[15:12],HEX3);

endmodule

module Bin2HEX(input [15:0]bin,
					output [3:0]HeX0,
					output [3:0]HeX1,
					output [3:0]HeX2,
					output [3:0]HeX3);
					
	assign HeX0[3:0] = bin[3:0];
	assign HeX1[3:0] = bin[7:4];
	assign HeX2[3:0] = bin[11:8];
	assign HeX3[3:0] = bin[15:12];
					
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
