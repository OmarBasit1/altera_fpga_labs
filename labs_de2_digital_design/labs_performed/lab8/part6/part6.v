module part6(input CLOCK_50,
				 input [9:0]SW,
				 input [3:0]KEY,
				 output [3:0]LEDR,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);
				 
	wire [7:0]dataOut;
	wire [4:0]count;
	cycle cyc(CLOCK_50, SW[9], count);
	
	reg [4:0] address;
	
	always@(SW[8])
	begin
		if (SW[8] == 1)
			address = KEY[3:0];
		else 
			address = count;
	end
		
	assign LEDR = count;
	
	lpmram ram1(address, CLOCK_50, SW[7:0], SW[8], dataOut);
	
	display disp0(dataOut, HEX0, HEX1);
	display disp1(SW[7:0], HEX2, HEX3);

endmodule

module ram_single(input [4:0]address,
						input clock,
						input [7:0]dataIn,
						input writeEn,
						output [7:0]dataOut);
	
	reg [4:0]reg_address;
	reg [7:0]reg_dataIn;
	reg reg_writeEn;
	
	always@(posedge clock)
	begin
		reg_address <= address;
		reg_dataIn <= dataIn;
		reg_writeEn <= writeEn;
	end
	
	reg [7:0] memory_array [3:0];
	
	always@(reg_address or reg_dataIn or reg_writeEn)
	begin
		if (reg_writeEn)
			memory_array[reg_address] <= reg_dataIn;
	end
		
		assign dataOut = memory_array[reg_address];
		
endmodule

module cycle(input clock,
				 input reset,
				 output reg [4:0]count);
	
	reg [26:0]sec_count;
	
	always@(negedge clock or negedge reset)
	begin
		if (reset == 0)
			sec_count <= 0;
		else if (sec_count == 26'd50000000)
			sec_count <= 0;
		else
			sec_count <= sec_count + 1'b1;
	end
	
	always@(negedge clock or negedge reset)
	begin
		if (reset == 0)
		begin
			count <= 0;
		end
		else if (sec_count == 0)
		begin
			count <= count + 1'b1;
		end
	end
		
endmodule

module display(input [7:0]data,
					output [6:0]hex0,
					output [6:0]hex1);
					
		hex_to_seven zero(data[3:0], hex0);
		hex_to_seven one(data[7:4], hex1);
		
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
		4'b1010	:
			hex = 7'b0001000;
		4'b1011	:
			hex = 7'b1100000;
		4'b1100	:
			hex = 7'b0110001;
		4'b1101	:
			hex = 7'b1000010;
		4'b1110	:
			hex = 7'b0110000;
		4'b1111	:
			hex = 7'b0111000;
	endcase
	
endmodule

/*module lpmram (
	address,
	clock,
	data,
	wren,
	q);*/