module part2(input [3:0]SW,
				 output [3:0]m,
				 output [6:0]HEX0, 
				 output [6:0]HEX1, 
				 output z );
	
	wire [2:0]A;
	wire [3:0]v;
	assign v[3:0] = SW[3:0];
	
	assign HEX1[0] = ~z;	//
	assign HEX1[1] = ~z;	//
	assign HEX1[2] = 1;	//
	assign HEX1[3] = 1;	//
	assign HEX1[3] = 1;	//		circuit B
	assign HEX1[4] = 1;	//
	assign HEX1[5] = 1;	//
	assign HEX1[6] = 1;	//
	
	assign A[2] = v[2];	//
	assign A[1] = v[1];	//		circuit A
	assign A[0] = v[0];	//
	
	assign z = v[3]&v[1] | v[3]&v[2]; 	// comparator
	
	assign m[3] = (z&v[3])|(~z&0);
	assign m[2] = (z&v[2])|(~z&A[2]);
	assign m[1] = (z&v[1])|(~z&A[1]);
	assign m[0] = (z&v[0])|(~z&A[0]);
	
	assign HEX0[0] =  ~(m[3] | m[1] | (m[2] ~^ m[0]));													//
	assign HEX0[1] =  ~(~m[2] | (m[0] ~^ m[1]));															//
	assign HEX0[2] =  ~(m[2] | ~m[1] | m[0]);																//	
	assign HEX0[3] =  ~(~m[2]&~m[0] | m[1]&~m[0] | m[2]&~m[1]&m[0] | ~m[2]&m[1] | m[3]);	//	7 segment decoder
	assign HEX0[4] =  ~(~m[2]&~m[0] | m[1]&~m[0]);														//
	assign HEX0[5] =  ~(m[3] | ~m[1]&~m[0] | m[2]&~m[1] | m[2]&~m[0]);							//
	assign HEX0[6] =  ~(m[3] | m[1]&~m[0] | m[2]^m[1]);												//
	
	
endmodule 



module tb();
		reg  [3:0]SW;
		wire [6:0]hex0;
		wire [6:0]hex1;
		wire [3:0]m;
		wire z;
		
		part2 tpart	(SW,m,hex0,hex1,z);
		
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