module part4(input [2:0]SW,
				 input [0:0]KEY,
				 output [6:0]HEX0);
				 
	parameter zero=4'b0, one=4'd1, two=4'd2, three=4'd3, four=4'd4, five=4'd5, six=4'd6, seven=4'd7, eight=4'd8, nine=4'd9;
	reg [3:0]pres_state, next_state;
	wire [3:0]count;
	
	always@(SW[1] or SW[2])
	begin
		case(pres_state)
			zero:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = zero;
				else if (SW[2]==0 & SW[1]==1)
					next_state = one;
				else if (SW[2]==1 & SW[1]==0)
					next_state = two;
				else 
					next_state = nine;
			end
			one:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = one;
				else if (SW[2]==0 & SW[1]==1)
					next_state = two;
				else if (SW[2]==1 & SW[1]==0)
					next_state = three;
				else 
					next_state = zero;
			end
			two:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = two;
				else if (SW[2]==0 & SW[1]==1)
					next_state = three;
				else if (SW[2]==1 & SW[1]==0)
					next_state = four;
				else 
					next_state = one;
			end
			three:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = three;
				else if (SW[2]==0 & SW[1]==1)
					next_state = four;
				else if (SW[2]==1 & SW[1]==0)
					next_state = five;
				else 
					next_state = two;
			end
			four:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = four;
				else if (SW[2]==0 & SW[1]==1)
					next_state = five;
				else if (SW[2]==1 & SW[1]==0)
					next_state = six;
				else 
					next_state = three;
			end
			five:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = five;
				else if (SW[2]==0 & SW[1]==1)
					next_state = six;
				else if (SW[2]==1 & SW[1]==0)
					next_state = seven;
				else 
					next_state = four;
			end
			six:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = six;
				else if (SW[2]==0 & SW[1]==1)
					next_state = seven;
				else if (SW[2]==1 & SW[1]==0)
					next_state = eight;
				else 
					next_state = five;
			end
			seven:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = seven;
				else if (SW[2]==0 & SW[1]==1)
					next_state = eight;
				else if (SW[2]==1 & SW[1]==0)
					next_state = nine;
				else 
					next_state = six;
			end
			eight:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = eight;
				else if (SW[2]==0 & SW[1]==1)
					next_state = nine;
				else if (SW[2]==1 & SW[1]==0)
					next_state = zero;
				else 
					next_state = seven;
			end
			nine:
			begin
				if(SW[2]==0 & SW[1]==0)
					next_state = nine;
				else if (SW[2]==0 & SW[1]==1)
					next_state = zero;
				else if (SW[2]==1 & SW[1]==0)
					next_state = one;
				else 
					next_state = eight;
			end
		endcase
	end
	
	always@(negedge SW[0] or negedge KEY[0])
	begin
		if (SW[0] == 0)
			pres_state <= zero;
		else
			pres_state <= next_state;
	end
	
	assign count = pres_state;
	
	display disp1(count, HEX0);
	
	
endmodule

module display(input [3:0]count,
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
