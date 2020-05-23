module part2(input [9:0]SW,
				 input [0:0]KEY,
				 input CLOCK_50,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);

				 
	wire [3:0]bcdmin0,bcdmin1,bcdhour1,bcdhour0;
	wire CLOCK_min,CLOCK_hour;
	wire [6:0]minutes,hours;
	wire [6:0]minSart;
	wire [5:0]hourStart;
	
	assign minSart[6:0] = SW[6:0];
	assign hourStart[5:0] = {3'b0 , SW[9:7]};
	
	Clock_divider minuteClock(CLOCK_50,CLOCK_min);
	
	count countmin(7'd60,CLOCK_min,KEY[0],minSart[6:0],minutes[6:0],CLOCK_hour);
	BintoBCD min(minutes,bcdmin0,bcdmin1);
	BCDto7 min0(bcdmin0,HEX0);
	BCDto7 min1(bcdmin1,HEX1);
	
	count counthour(7'd24,CLOCK_hour,KEY[0],hourStart[5:0],hours[6:0]);
	BintoBCD hour(hours,bcdhour0,bcdhour1);
	BCDto7 hour0(bcdhour0,HEX2);
	BCDto7 hour1(bcdhour1,HEX3);
				 
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

module BintoBCD(input [6:0]bin,
					 output [3:0]bcd0,bcd1);
			
	assign bcd0 = bin%7'd10;
	assign bcd1 = bin/7'd10;
endmodule

module Clock_divider(input clock_in,
							output reg clock_out);

	reg[31:0] counter=32'd0;
	parameter DIVISOR = 32'd50000000;

	always @(posedge clock_in)
	begin
		counter <= counter + 21'd1;
		if(counter>=(DIVISOR-1))
			counter <= 32'd0;
	end

	always@(posedge clock_in)
	begin
		if (counter < DIVISOR/2 )
			clock_out = 1'b0;
		else 
			clock_out = 1'b1;
	end	
endmodule

module count(input [6:0]countEnd,
				 input Clk,
				 input reset,
				 input [6:0]countInit,
				 output reg [6:0]count,
				 output reg rollOver);

	always@(posedge Clk or negedge reset)
	begin
		if (reset == 0)
			count <=  countInit;
		else
		begin 
			if (Clk ==1)
			begin
				count <= count + 1'b1;
				rollOver = 1'b0;
				
				if (count >= (countEnd - 1'b1))
				begin
					count <= 1'b0;
					rollOver = 1'b1;
				end
			end
		end
	end
				 
endmodule 




module tb();
	reg CLOCK_50;
	reg [9:0]sw;
	reg [0:0]key;
	wire [6:0]hex0,hex1,hex2,hex3;
	
	part2 test(sw,key,CLOCK_50,hex0,hex1,hex2,hex3);
	
	initial begin
		#0 	CLOCK_50 = 1'b0;	key[0] = 1'b1;
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
		#100 	CLOCK_50 = 1'b1;	sw[9:0] = 10'b1110011110;
		#100 	CLOCK_50 = 1'b0;
		#100 	CLOCK_50 = 1'b1;	key[0] = 1'b0;		
		#100 	CLOCK_50 = 1'b0;	key[0] = 1'b0; 
		#100 	CLOCK_50 = 1'b1;	key[0] = 1'b1;
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