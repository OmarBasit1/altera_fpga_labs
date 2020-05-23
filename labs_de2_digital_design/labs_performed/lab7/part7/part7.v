module part7(input [2:0]KEY,
				 input CLOCK_50,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3,
				 output [9:0]LEDR);

	FSM1 machine1(KEY[0], CLOCK_50, enable, HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0]);
	
	parameter base=3'd0, mul2=3'd1, mul4=3'd2, div2=3'd3, div4=3'd4;
	reg [2:0]pres_state, next_state;
	reg [28:0]count;
	
	wire enable;
	gen_enable gen(CLOCK_50,(reg_key[0] | reg_key[1]), count, enable);
	
	assign LEDR = count[28:19];
	
	wire [1:0]reg_key;
	
	gen_pulse key1(CLOCK_50, KEY[2], reg_key[1]);
	gen_pulse key0(CLOCK_50, KEY[1], reg_key[0]);

	
	always@(negedge reg_key[1] or negedge reg_key[0])
	begin
		case(pres_state)
			base:		
				if 	  (reg_key[0]==0 & reg_key[1]==1)	next_state=mul2;
				else if (reg_key[0]==1 & reg_key[1]==0)	next_state=div2;
				else 										next_state=base;
			mul2:
				if 	  (reg_key[0]==0 & reg_key[1]==1)	next_state=mul4;
				else if (reg_key[0]==1 & reg_key[1]==0)	next_state=base;
				else 										next_state=mul2;
			mul4:
				if 	  (reg_key[0]==0 & reg_key[1]==1)	next_state=mul4;
				else if (reg_key[0]==1 & reg_key[1]==0)	next_state=mul2;
				else 										next_state=mul4;
			div2:
				if 	  (reg_key[0]==0 & reg_key[1]==1)	next_state=base;
				else if (reg_key[0]==1 & reg_key[1]==0)	next_state=div4;
				else 										next_state=div2;
			div4:
				if 	  (reg_key[0]==0 & reg_key[1]==1)	next_state=div2;
				else if (reg_key[0]==1 & reg_key[1]==0)	next_state=div4;
				else 										next_state=div4;
			default:
				next_state=base;
		endcase
	end
	
	always@(negedge KEY[0] or negedge CLOCK_50)
	begin
		if (KEY[0]==0)
			pres_state<=base;
		else
			pres_state<=next_state;
	end
	
	always@(pres_state)
	begin
		case(pres_state)
			base:		count = 28'd50000000;
			mul2:		count = 28'd25000000;
			mul4:		count = 28'd12500000;
			div2:		count = 28'd100000000;
			div4:		count = 28'd200000000;
			default: count = 28'd50000000;
		endcase
	end
	
endmodule


module FSM1(input [0:0]SW,
				 input CLOCK_50,
				 input enable,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);
	
	parameter H=3'd0, E=3'd1, L1=3'd2, L2=3'd3, O=3'd4, space=3'd5, repe=3'd6;
	reg [2:0] pres_state, next_state;
	wire [2:0] tmp0, tmp1, tmp2, tmp3, tmp4, tmp5;
	reg [2:0] in;
	
		
	always@(pres_state or enable)
	begin
		case(pres_state)
			H: 		if(enable)	next_state = E;
						else			next_state = H;
			E: 		if(enable)	next_state = L1;
						else			next_state = E;
			L1:		if(enable)	next_state = L2;
						else			next_state = L1;
			L2:		if(enable)	next_state = O;
						else			next_state = L2;
			O:			if(enable)	next_state = space;
						else			next_state = O;
			space:	if(enable)	next_state = repe;
						else			next_state = space;
			repe: 	next_state = repe;
			default: next_state = H;
		endcase
	end
	
	always@(negedge SW[0] or negedge CLOCK_50)
	begin
		if (SW[0] == 0)
			pres_state <= 0;
		else 
			pres_state <= next_state;
	end
	
	registers_seven zero(in, CLOCK_50, SW[0], enable, tmp0);
	registers_seven one(tmp0, CLOCK_50, SW[0], enable, tmp1);
	registers_seven two(tmp1, CLOCK_50, SW[0], enable, tmp2);
	registers_seven three(tmp2, CLOCK_50, SW[0], enable, tmp3);
	registers_seven four(tmp3, CLOCK_50, SW[0], enable, tmp4);
	registers_seven five(tmp4, CLOCK_50, SW[0], enable, tmp5);
	
	
	always@(pres_state)
	begin
		case(pres_state)
			H:		in = 3'b000;
			E: 	in = 3'b001;
			L1:	in = 3'b010;
			L2:	in = 3'b010;
			O:		in = 3'b011;
			space:in = 3'b111;
			repe: in = tmp5;
		endcase
	end
	
	display disp0(tmp0, HEX0);
	display disp1(tmp1, HEX1);
	display disp2(tmp2, HEX2);
	display disp3(tmp3, HEX3);
	
endmodule

module registers_seven(input [2:0]in,
							  input clock,
							  input reset,
							  input enable,
							  output reg [2:0]out);

	always@(negedge clock or negedge reset)
	begin
		if (reset == 0)
			out <= 3'b111;
		else
			if(enable == 1)
			out <= in;
	end
							  
endmodule

module display(input [2:0]select,
					output reg [6:0]hex);

	always@(*)
	case(select)
		3'b000:	hex = 7'b0001001;		//H
		3'b001:	hex = 7'b0000110;		//E
		3'b010:	hex = 7'b1000111;		//L
		3'b011:	hex = 7'b1000000;		//O
		default: hex = 7'b1111111;		// [space]
	endcase
					
endmodule

module gen_enable(input clk,
						input reset,
						input [27:0]top,
						output reg enable);

	reg [27:0]count;
	
	always@(posedge clk or negedge reset)
	begin
		if (reset == 0)
			count <= top;
		else
		begin
			if (clk == 1)
				count <= count + 28'd1;
			if (count == top)
				count <= 0;
		end
	end
	
	always@(posedge clk)
	begin
		if (count == 28'd0 )
			enable <= 1;
		else
			enable <= 0;
	end
						
endmodule

module gen_pulse(input clk,
					  input key,
					  output reg pulse);

	reg trigger;
	
	always@(posedge clk)
	begin
		if (clk == 1)
		begin
			if (key == 1)
			begin
				trigger <= 0;
				pulse <= 1;
			end
			if (key == 0)
			begin
				trigger <= 1;
				pulse <= 0;
			end
			if (trigger == 1)
				pulse <= 1;
		end
	end
						
endmodule
