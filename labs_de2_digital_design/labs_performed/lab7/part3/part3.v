module part3(input [0:0]KEY,
				 input [1:0]SW,
				 output [0:0]LEDG,
				 output [3:0]LEDR);
	
	wire all_one, all_zero, out;

	shift_reg_4 check(KEY[0], SW[0], SW[1], out, all_one, all_zero, LEDR[3:0]);
	
	assign LEDG = all_one | all_zero;

endmodule

module shift_reg_4(input clock,
						 input reset,
						 input in,
						 output reg out,
						 output all_one,
						 output all_zero,
						 output [3:0]data);
		
		reg [2:0]inside_;
		assign data = {out, inside_[2:0]};

		always@(negedge clock or negedge reset)
		begin
			if (reset == 0)
			begin 
				inside_ <= 0;
				out <=0;
			end
			else
			begin
				inside_[0] <= in;
				inside_[1] <= inside_[0];
				inside_[2] <= inside_[1];
				out		 <= inside_[2];
			end
 		end
		
		assign all_one = inside_[0] & inside_[1] & inside_[2] & out;
		assign all_zero = ~(inside_[0] | inside_[1] | inside_[2] | out);
		
endmodule