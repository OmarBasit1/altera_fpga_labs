module part4(input CLOCK_50, input [3:3] KEY,
				 output [6:0]HEX0,output [1:0]GPIO_0);
	wire CLOCK_1;
	wire [3:0]count;
	assign GPIO_0[0]=1'd0;
	assign GPIO_0[1] = CLOCK_1;
	
	//downClocker clock(CLOCK_50, KEY ,CLOCK_1);
	Clock_divider clocker(CLOCK_50, CLOCK_1);
	counter counter1(CLOCK_1,count);
	BCDto7 hex0(count,HEX0);
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

	reg[31:0] counter=28'd0;
	parameter DIVISOR = 32'd50000000;

	always @(posedge clock_in)
	begin
		counter <= (counter == DIVISOR-1) ? 'b0 : counter + 1'b1;
	end
	
	//assign clock_out = (counter<DIVISOR/2)?1'b0:1'b1;
	always@(posedge clock_in)
	begin
		if (counter < DIVISOR/2 )
			clock_out = 1'b0;
		else 
			clock_out = 1'b1;
	end
endmodule

module downClocker(input clk, input reset, output reg clkOut);
	reg [28:0] counter;
	
	always @(posedge clk or negedge reset) begin
		if(~reset)
			counter = 29'b0;
		else
			if(counter == 29'd24999999) begin
				clkOut = ~clkOut;
				counter = 29'd0;
			end
			else
				counter = counter + 29'b1;
		end
endmodule

module counter(input Clk,
					output reg [3:0]count);
					
	always@(posedge Clk)	
	begin
		count <= (count == 4'd9) ? 4'b0 : count + 4'b1;
	end				
endmodule

module tb();
	
	reg CLOCK_50;
	wire CLOCK_1;
	wire [3:0]count;
	wire [6:0]hex0;
	
	part4 test(CLOCK_50,CLOCK_1,count,hex0);
	
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


