module part1(input [0:0]KEY,
				 input [1:0]SW,
				 output reg [0:0]LEDG,
				 output [8:0]LEDR);

	parameter A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8;
	reg [8:0]state;	
	assign LEDR = state;
					 
	always@(negedge SW[0] or negedge KEY[0])
		if (SW[0] == 0)
		begin 
			state <= 9'd1;
			LEDG[0] = 0;
		end
		else
		begin
			state <=9'b0;
			LEDG[0] = 0;
			case(1'b1)
			state[A]:
			begin
				if (SW[1] == 1)
					state[F] <= 1'b1;
				else
					state[B] <= 1'b1;
			end
			state[B]:
			begin
				if (SW[1] == 1)
					state[F] <= 1'b1;
				else
					state[C] <= 1'b1;
			end
			state[C]:
			begin
				if (SW[1] == 1)
					state[F] <= 1'b1;
				else
					state[D] <= 1'b1;
			end
			state[D]:
			begin
				if (SW[1] == 1)
					state[F] <= 1'b1;
				else
				begin
					state[E] <= 1'b1;
					LEDG[0] = 1'b1;
				end
			end
			state[E]:
			begin
				if (SW[1] == 1)
					state[F] <= 1'b1;
				begin
					state[E] <= 1'b1;
					LEDG[0] = 1'b1;
				end
			end
			state[F]:
			begin
				if (SW[1] == 1)
					state[G] <= 1'b1;
				else
					state[B] <= 1'b1;
			end
			state[G]:
			begin
				if (SW[1] == 1)
					state[H] <= 1'b1;
				else
					state[B] <= 1'b1;
			end
			state[H]:
			begin
				if (SW[1] == 1)
				begin
					state[I] <= 1'b1;
					LEDG[0] = 1'b1;
				end
				else
					state[B] <= 1'b1;
			end
			state[I]:
			begin
				if (SW[1] == 1)
				begin
					state[I] <= 1'b1;
					LEDG[0] = 1'b1;
				end
				else
					state[B] <= 1'b1;
			end
			endcase
		end
	

				 
endmodule


