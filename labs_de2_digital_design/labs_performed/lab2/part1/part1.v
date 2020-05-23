module part1(input [3:0]sw,
				 output [6:0]hex0);
	assign hex0[0] =  ~(sw[3] | sw[1] | (sw[2] ~^ sw[0]));
	assign hex0[1] =  ~(~sw[2] | (sw[0] ~^ sw[1]));
	assign hex0[2] =  ~(sw[2] | ~sw[1] | sw[0]);
	assign hex0[3] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0] | sw[2]&~sw[1]&sw[0] | ~sw[2]&sw[1] | sw[3]);
	assign hex0[4] =  ~(~sw[2]&~sw[0] | sw[1]&~sw[0]);
	assign hex0[5] =  ~(sw[3] | ~sw[1]&~sw[0] | sw[2]&~sw[1] | sw[2]&~sw[0]);
	assign hex0[6] =  ~(sw[3] | sw[1]&~sw[0] | sw[2]^sw[1]);
endmodule 

module tb();
	wire  [6:0] hex;
	reg   [3:0] SW;
	
	part1 tpart(SW,hex);
	
	initial begin
		#000 SW = 4'b0000;
		#100 SW = 4'b0001;
		#100 SW = 4'b0010;
		#100 SW = 4'b0011;
		#100 SW = 4'b0100;
		#100 SW = 4'b0101;
		#100 SW = 4'b0110;
		#100 SW = 4'b0111;
		#100 SW = 4'b1000;
		#000 SW = 4'b1000;
		#100 SW = 4'b1001;
		#100 SW = 4'b1010;
		#100 SW = 4'b1011;
		#100 SW = 4'b1100;
		#100 SW = 4'b1101;
		#100 SW = 4'b1110;
		#100 SW = 4'b1111;
		#100;
		end
endmodule