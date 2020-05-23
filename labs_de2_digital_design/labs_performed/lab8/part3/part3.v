module part3(input [9:0]SW,
				 input [3:0]KEY,
				 output [9:0]LEDR,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2);

	wire [31:0]data;
	assign LEDR = SW;
				 
ram_single first(KEY[3:0], SW[9], SW[7:0], SW[8], data);

	/*module ramlpm (
	address,
	clock,
	data,
	wren,
	q);*/
	
	display one(data[7:0], HEX0, HEX1, HEX2);

endmodule

module ram_single(input [4:0]address,
						input clock,
						input [31:0]dataIn,
						input writeEn,
						output [31:0]dataOut);
	
	reg [4:0]reg_address;
	reg [31:0]reg_dataIn;
	reg reg_writeEn;
	
	always@(posedge clock)
	begin
		reg_address <= address;
		reg_dataIn <= dataIn;
		reg_writeEn <= writeEn;
	end
	
	reg [7:0] memory_array [31:0];
	
	always@(reg_address or reg_dataIn or reg_writeEn)
	begin
		if (reg_writeEn)
			memory_array[reg_address] <= reg_dataIn;
	end
		
		assign dataOut = memory_array[reg_address];
		
endmodule


module display(input [7:0]data,
					output [6:0]hex0,
					output [6:0]hex1,
					output [6:0]hex2);

	wire [3:0]unit,ten,hundred;
	
	assign hundred = data / 100;
	assign ten = (data % 100) / 10;
	assign unit = data % 10;
	
	hex_to_seven zero(unit,hex0);
	hex_to_seven one(ten,hex1);
	hex_to_seven two(hundred,hex2);

endmodule

module hex_to_seven(input [3:0]count,
					output reg [6:0]hex);

	always @*
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
