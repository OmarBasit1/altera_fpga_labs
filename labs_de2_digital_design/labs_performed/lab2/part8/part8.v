module part8(input [5:0]SW,
				 output [6:0]HEX0,
				 output [6:0]HEX1);
				 
	reg [3:0]unit;
	reg [3:0]ten;
	wire [6:0]num;
	assign num = SW[5:0];
	
	always@(SW)
	begin
		unit = num%10;
		ten = num/10;
	end	 
	
	BCDto7 h0(.sw(unit),.hex(HEX0));
	BCDto7 h1(.sw(ten),.hex(HEX1));
	
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


module tb();
	reg [5:0]sw;
	wire [6:0]hex0;
	wire [6:0]hex1;
	
	part8 parttb(sw,hex0,hex1);
	
	initial begin
	
		#0 sw = 6'b111111;
		#100;
	
	end
	
endmodule 