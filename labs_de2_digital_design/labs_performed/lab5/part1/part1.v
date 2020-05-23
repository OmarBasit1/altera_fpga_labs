module part1(input CLOCK_50,
				 input [3:3]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2);
	wire [8:0]count;
	wire [3:0] unit,ten,hundred;
	
	Clock_divider second_clock(CLOCK_50,CLOCK_1);
	counter counter1(CLOCK_1,KEY, count);
	BCDcounter converter(count,unit,ten,hundred);
	BCDto7 one(unit,HEX0);
	BCDto7 two(ten,HEX1);
	BCDto7 three(hundred,HEX2);
	
endmodule 

module BCDcounter(input [8:0]num,
						output [3:0]unit,ten,hundred);

	assign unit = num%10;
	assign ten = (num/10)%10;
	assign hundred = num/100;

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

module Clock_divider(input clock_in,
							output reg clock_out);

	reg[27:0] counter=28'd0;
	parameter DIVISOR = 28'd50000000;

	always @(posedge clock_in)
	begin
		counter <= counter + 28'd1;
		if(counter>=(DIVISOR-1))
			counter <= 28'd0;
	end
	
		always@(posedge clock_in)
	begin
		if (counter < DIVISOR/2 )
			clock_out = 1'b0;
		else 
			clock_out = 1'b1;
	end
endmodule

module counter(input Clk,input reset,
					output reg [8:0]count = 0);
					
	always@(posedge Clk or negedge reset)	
	begin
		if (reset == 0)
			count <= 8'd0;
		else
		count <= count+8'd1;
	end				
endmodule

module tb();
	reg CLOCK_50;
	wire [6:0]hex0,hex1,hex2;
	
	part1 test(CLOCK_50,hex0,hex1,hex2);
	
	initial begin
		#0 	CLOCK_50 = 1'b0; 
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;
	end
endmodule