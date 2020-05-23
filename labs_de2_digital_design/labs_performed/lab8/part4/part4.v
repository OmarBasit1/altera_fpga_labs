module part4(input CLOCK_50,
				 input [9:0]SW,
				 input [3:0]KEY,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [7:0]SRAM_ADDR,
				 inout [15:0]SRAM_DQ,
				 output SRAM_CE_N,
				 output SRAM_OE_N,
				 output SRAM_WE_N,
				 output SRAM_UB_N,
				 output SRAM_LB_N);
				 	
	wire [9:0]dataOut;
	
	Sram one(CLOCK_50, SW[7:0], KEY[2:0], SW[9], 1'b0, SW[8], KEY[3], KEY[3], dataOut, 
				SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
	

	display disp1(dataOut,HEX0,HEX1,HEX2);
	
endmodule


module Sram(input clock,
				input [15:0]dataIn,
				input [17:0]address,
				input writeEn,
				input chipEn,
				input readEn,
				input addressSendU,
				input addressSendL,
				output reg [15:0]dataOut,
				output reg [17:0]SRAM_ADDR,
				inout reg [15:0]SRAM_DQ,
				output SRAM_CE_N,				
				output reg SRAM_OE_N,
				output reg SRAM_WE_N,
				output reg SRAM_UB_N,
				output reg SRAM_LB_N);

	assign SRAM_CE_N = chipEn;
	reg [17:0]reg_address;
	reg [15:0]reg_dataIn;
				
	always@(posedge clock)
	begin
		SRAM_OE_N <= readEn;
		SRAM_WE_N <= writeEn;
		SRAM_LB_N <= addressSendL;
		SRAM_UB_N <= addressSendU;
		reg_address <= address;
		reg_dataIn <= dataIn;
	end
	
	always@(address)
	begin
		if (SRAM_LB_N == 0)
			SRAM_ADDR[7:0] <= reg_address[7:0];
		if (SRAM_UB_N == 0)
			SRAM_ADDR[15:8] <= reg_address[15:8];
	end
	
	
	always@(SRAM_ADDR)
	begin
		if (SRAM_WE_N == 0)
			SRAM_DQ = dataIn;
		else
			SRAM_DQ = 16'bzzzzzzzzzzzzzzzz;
	end
	
	always@(SRAM_DQ)
	begin
		if (SRAM_OE_N == 0)
			dataOut = SRAM_DQ;
		else
			dataOut = 16'bzzzzzzzzzzzzzzzz;
	end
			 
endmodule

module display(input [9:0]data,
					output [6:0]hex0,
					output [6:0]hex1,
					output [6:0]hex2);

	wire [3:0]unit,ten,hundred;
	
	assign hundred = data / 8'd100;
	assign ten = (data % 8'd100) / 8'd10;
	assign unit = data % 8'd10;
	
	hex_to_seven zero(unit,hex0);
	hex_to_seven one(ten,hex1);
	hex_to_seven two(hundred,hex2);

endmodule

module hex_to_seven(input [3:0]count,
					output reg [6:0]hex);

	always @(count)
	case (count)
		4'b0000 :      	//Hexadecimal 0
			hex = 7'b1000000 ;
		4'b0001 :    		//Hexadecimal 1
			hex = 7'b1111001 ;
		4'b0010 :  		// Hexadecimal 2
			hex = 7'b0100100 ; 
		4'b0011 : 		// Hexadecimal 3
			hex = 7'b0110000 ;
		4'b0100 :		// Hexadecimal 4
			hex = 7'b0011001 ;
		4'b0101 :		// Hexadecimal 5
			hex = 7'b0010010 ;  
		4'b0110 :		// Hexadecimal 6
			hex = 7'b0000010 ;
		4'b0111 :		// Hexadecimal 7
			hex = 7'b1111000;
		4'b1000 :     		 //Hexadecimal 8
			hex = 7'b0000000;
		4'b1001 :    		//Hexadecimal 9
			hex = 7'b0010000;
	endcase
	
endmodule

