module fullAddr(input a,
					 input b,
					 input ci,
					 output s,
					 output co);
					 
	assign k = a^b;
	assign s = ci^k;
	assign co = ~k&b | k&ci;
	
endmodule 

module part3(input [8:0]SW,
				 output [8:0]LEDR,
				 output [4:0]LEDG);

	wire [8:0]ledr;
	wire [4:0]ledg;
	wire [2:0]tmpCarry;
	
	assign  LEDR = SW;
	
	assign lEDR = ledr;
	assign LEDG = ledg;
				 
	fullAddr bit1(.a(SW[0]),
				.b(SW[4]),
				.ci(SW[8]),
				.s(ledg[0]),
				.co(tmpCarry[0]));
				
	fullAddr bit2(.a(SW[1]),
				.b(SW[5]),
				.ci(tmpCarry[0]),
				.s(ledg[1]),
				.co(tmpCarry[1]));
				
	fullAddr bit3(.a(SW[2]),
				.b(SW[6]),
				.ci(tmpCarry[1]),
				.s(ledg[2]),
				.co(tmpCarry[2]));
				
	fullAddr bit4(.a(SW[3]),
				.b(SW[7]),
				.ci(tmpCarry[2]),
				.s(ledg[3]),
				.co(ledg[4]));
endmodule 

module tb();
	reg [8:0]sw;
	wire [8:0]lr;
	wire [4:0]lg;
	
	part3 tbpart3(sw,lr,lg);
	
	initial begin
		#0 sw = 9'b000000000;
		#100 sw = 9'b010100101;
		#100 sw = 9'b100011001;
		#100;
	end
	
endmodule 