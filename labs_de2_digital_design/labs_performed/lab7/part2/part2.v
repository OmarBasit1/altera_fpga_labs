module part2(input [0:0]KEY,
				 input [1:0]SW,
				 output [0:0]LEDG,
				 output [3:0]LEDR);

	reg [3:0]pres_state, next_state;
	parameter A=4'd0, B=4'd1, C=4'd2, D=4'd3, E=4'd4, F=4'd5, G=4'd6, H=4'd7, I=4'd8;
	
	always@(SW[1] or pres_state)
	begin
		case(pres_state)
			A:
				if(!SW[1])	next_state = B;
				else 			next_state = F;
			B:
				if(!SW[1])	next_state = C;
				else 			next_state = F;
			C:
				if(!SW[1])	next_state = D;
				else 			next_state = F;
			D:
				if(!SW[1])	next_state = E;
				else 			next_state = F;
			E:
				if(!SW[1])	next_state = E;
				else 			next_state = F;
			F:
				if(!SW[1])	next_state = B;
				else 			next_state = G;
			G:
				if(!SW[1])	next_state = B;
				else 			next_state = H;
			H:
				if(!SW[1])	next_state = B;
				else 			next_state = I;
			I:
				if(!SW[1])	next_state = B;
				else 			next_state = I;

			default:
				next_state = 4'bxxxx;
		endcase
	end
	
	always@(negedge KEY[0] or negedge SW[0])
	begin
		if(SW[0] == 0)
		begin
			pres_state <= 4'b0;
		end
		else
		begin
			pres_state <= next_state;
		end
	end
	
	assign LEDG = pres_state[3] | pres_state[2] & !pres_state[1] & !pres_state[0];
	assign LEDR = pres_state;
				 
endmodule

