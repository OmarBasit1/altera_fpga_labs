module part4(HEX0,SW);
	input [2:0]SW;
	output [6:0] HEX0;
	
	wire [6:0] hexOut;
	wire C = SW[0];
	wire B = SW[1];
	wire A = SW[2];
	
	assign HEX0 = ~hexOut;
	
	assign hexOut[0] = ~A & C;
	assign hexOut[1] = (~A & ~B & ~C) | (~A & B & C);
	assign hexOut[2] = (~A & ~B & ~C) | (~A & B & C);
	assign hexOut[3] = (~A & C) | (~A & B);
	assign hexOut[4] = ~A;
	assign hexOut[5] = ~A;
	assign hexOut[6] = ~A & ~B;
endmodule


module tb;
	wire  [6:0] hex;
	reg   [2:0] SW;
	
	part4 tpart(hex, SW);
	
	initial begin
		#000 SW = 3'b000;
		#100 SW = 3'b001;
		#100 SW = 3'b010;
		#100 SW = 3'b011;
		#100 SW = 3'b100;
		#100 SW = 3'b101;
		#100 SW = 3'b110;
		#100 SW = 3'b111;
		#100 SW =3'b000;
	end
endmodule 