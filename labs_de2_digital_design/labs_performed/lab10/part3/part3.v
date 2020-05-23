module part3(input [1:0]SW,
				 input [1:0]KEY,
				 output [7:0]LEDG,
				 output [9:0]LEDR);

	cpu mycpu(KEY[1], KEY[0], SW[0], SW[1], {LEDR[7:0], LEDG[7:0]}, LEDR[9]);

endmodule

module cpu(input clock,
			  input Resetn,
			  input Run,
			  input ram_init,
			  output [15:0]LEDs,
			  output done_led);
			  
	wire [15:0]DIN, ADDR, DOUT;
	wire W, Done, wr_en, display_en;
	assign done_led = Done;
	
	assign wr_en = ~(ADDR[15] | ADDR[14] | ADDR[13] | ADDR[12]) & W;
	assign display_en = ~(ADDR[15] | ADDR[14] | ADDR[13] | ~ADDR[12]) & W;
	
	processor proc(DIN, Resetn, clock, Run, ADDR, W, Done, DOUT, LEDs);
	
	memory	memory_inst (
	.address ( ADDR ),
	.clock ( clock ),
	.data ( DOUT ),
	.wren ( wr_en ),
	.q ( DIN )
	);
	//assign LEDs = DOUT;
	regn led(DOUT, display_en, clock, LED);	//correct after debugging
	
			  
endmodule

/*module memory(input [6:0]addr,
				  input [15:0]data,
				  input wr_en,
				  input clock,
				  input key,
				  output [15:0]q,
				  output led);
	
	init_mem	init_mem_inst (
	.clock ( clock ),
	.init ( ~key ),
	.dataout ( data ),
	.init_busy ( led ),
	.ram_address ( addr ),
	.ram_wren ( wr_en )
	);
	
	reg [15:0]mem_block[127:0];
	
	
	always@(negedge clock)
	begin
		if (wr_en)
			mem_block[addr] <= data;
	end
	
	assign q = mem_block[addr];
	
endmodule*/

module processor(input [15:0]DIN,
					  input Resetn,
					  input Clock,
					  input Run, 
					  output [15:0]ADDR,
					  output W,
					  output Done, 
					  output [15:0]Dout,
					  output [15:0]LEDs);
	
	wire [15:0]busloop;
	assign LEDs = DIN;
	
	wire [15:0]R_d0 = busloop;		//input
	wire [15:0]R_d1 = busloop;
	wire [15:0]R_d2 = busloop;
	wire [15:0]R_d3 = busloop;
	wire [15:0]R_d4 = busloop;
	wire [15:0]R_d5 = busloop;
	wire [15:0]R_d6 = busloop;
	wire [15:0]R_d7 = busloop;
	wire [15:0]A = busloop;
	wire [15:0]G;
	wire [15:0]A_reg,G_reg;
	wire [15:0]R_q0;					//output
	wire [15:0]R_q1;
	wire [15:0]R_q2;
	wire [15:0]R_q3;
	wire [15:0]R_q4;
	wire [15:0]R_q5;
	wire [15:0]R_q6;
	wire [15:0]R_q7;
	wire [7:0]R_in, R_out;
	wire [8:0]IR;
	wire PC_in, Dout_in, ADDR_in, W_D, flag;
	wire A_in,G_in,G_out,Din_out, Add_Sub, IR_in;
	
	
	regn r0(R_d0, R_in[0], Clock,R_q0);
	regn r1(R_d1, R_in[1], Clock,R_q1);
	regn r2(R_d2, R_in[2], Clock,R_q2);
	regn r3(R_d3, R_in[3], Clock,R_q3);
	regn r4(R_d4, R_in[4], Clock,R_q4);
	regn r5(R_d5, R_in[5], Clock,R_q5);
	regn r6(R_d6, R_in[6], Clock,R_q6);
	counter PC(R_d7, Resetn, R_in[7], Clock, PC_in, R_q7);
	
	regn a(A, A_in, Clock,A_reg);
	regn g(G, G_in, Clock,G_reg);
	regn #(9) ir(DIN[8:0], IR_in, Clock,IR);
	
	regn Bus(busloop, Dout_in, Clock, Dout);
	regn addr(busloop, ADDR_in, Clock, ADDR);
	regn W_register(W_D, 1'b1, Clock, W);
	
	AddSub adder(A_reg, busloop, Add_Sub, G);
	assign flag = ~ (G_reg[0] | G_reg[1] | G_reg[2] | G_reg[3] | G_reg[4] | G_reg[5] 
						| G_reg[6] | G_reg[7] | G_reg[8] | G_reg[9] | G_reg[10] | G_reg[11] 
						| G_reg[12] | G_reg[13] | G_reg[14] | G_reg[15]);
						
	multiplexer mux(DIN, R_q0, R_q1, R_q2, R_q3, R_q4, R_q5, R_q6, R_q7,
													G_reg, R_out, G_out, Din_out, busloop);
	
	control_unit CU(Clock, Run, Resetn, IR, flag, R_out, G_out, Din_out, PC_in,
									R_in, A_in, G_in, Add_Sub, IR_in, ADDR_in, Dout_in, W_D, Done);
	
endmodule

module control_unit(input clock,
						  input run,
						  input resetn,
						  input [8:0]IR,
						  input G_flag,
						  output reg [7:0]Rout,
						  output reg Gout,
						  output reg DINout,
						  output reg incr_ptr,
						  output reg [7:0]Rin,
						  output reg Ain,
						  output reg Gin,
						  output reg AddSub,
						  output reg IR_in,
						  output reg ADDR_in,
						  output reg DOUTin,
						  output reg W_D,
						  output reg Done);
			
	parameter T0 = 3'b0, T1 = 3'd1, T2 = 3'd2, T3 = 3'd3, T4 = 3'd4, T5 = 3'd5, T6=3'd6;
	parameter mv = 3'd0, mvi = 3'd1, add = 3'd2, sub = 3'd3, ld = 3'd4, st = 3'd5, mvnz = 3'd6;
	reg [2:0]pres_state, next_state;
	
	wire [2:0]instruction,Rx,Ry;
	assign instruction = IR[8:6];
	
	wire [7:0]Xreg, Yreg;
	
	dec3to8 decX (IR[5:3], 1'b1, Xreg);
	dec3to8 decY (IR[2:0], 1'b1, Yreg);
	
	
	always@(instruction or pres_state or G_flag)
	begin
		case(pres_state)
			T0:
			begin
				next_state = T1;
			end
			T1:
			begin
				next_state = T2;
			end
			T2:
			begin
				next_state = T3;
			end
			T3:
			begin
				if (instruction == mv | instruction == mvi)
					next_state = T0;
				else if (instruction == mvnz & G_flag == 1)
					next_state = T0;
				else 
					next_state = T4;
			end
			T4:
			begin
				next_state = T5;
			end
			T5:
			begin
				next_state = T0;
			end
		endcase
	end
	
	always@(negedge clock or negedge resetn or negedge run)
	begin
		if(resetn == 0)
			pres_state <= T0;
		else if (run == 0)
			pres_state <= pres_state;
		else
			pres_state <= next_state;			
	end
	
	always@(pres_state)
	begin
		case(pres_state)
			T0:
			begin
				IR_in = 1'b0;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				ADDR_in = 1'b1;
				DOUTin = 1'b0;
				W_D = 1'b0;
				Rout[7] = 1'b1;
				incr_ptr = 1'b0;
			end
			T1:
			begin
				IR_in = 1'b0;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				ADDR_in = 1'b0;
				DOUTin = 1'b0;
				W_D = 1'b0;
				incr_ptr = 1'b1;
			end
			T2:
			begin
				IR_in = 1'b1;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				ADDR_in = 1'b0;
				DOUTin = 1'b0;
				W_D = 1'b0;
				incr_ptr = 1'b0;
			end
			T3:
			begin
				IR_in = 1'b0;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				ADDR_in = 1'b0;
				DOUTin = 1'b0;
				W_D = 1'b0;
				incr_ptr = 1'b0;
				if (instruction == mv)
				begin
					Rout = Yreg;
					Rin = Xreg;
					Done = 1'b1;
				end
				else if (instruction == mvi)
				begin
					ADDR_in = 1'b1;
					Rout[7] = 1'b1;
				end
				else if (instruction == add)
				begin
					Rout = Xreg;
					Ain = 1'b1;
				end
				else if (instruction == sub)
				begin
					Rout = Xreg;
					Ain = 1'b1;
				end
				else if (instruction == ld)
				begin
					Rout = Yreg;
					ADDR_in = 1'b1;
				end
				else if (instruction == st)
				begin
					Rout = Yreg;
					ADDR_in = 1'b1;
				end
				else if (instruction == mvnz)
				begin
					Rout = Yreg;
					Rin = Xreg;
					Done = 1'b1;
				end
			end
			T4:
			begin
				IR_in = 1'b0;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				ADDR_in = 1'b0;
				DOUTin = 1'b0;
				W_D = 1'b0;
				incr_ptr = 1'b0;
				if (instruction == add)
				begin
					Rout = Yreg;
					Gin = 1'b1;
				end
				else if (instruction == mvi)
				begin
					incr_ptr = 1'b1;
				end
				else if (instruction == sub)
				begin
					Rout = Yreg;
					Gin = 1'b1;
					AddSub = 1'b1;
				end
				else if (instruction == st)
				begin
					Rout = Xreg;
					DOUTin = 1'b1;
				end
			end
			T5:
			begin
				IR_in = 1'b0;
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b1;
				ADDR_in = 1'b0;
				DOUTin = 1'b0;
				W_D = 1'b0;
				incr_ptr = 1'b0;
				if (instruction == add | instruction == sub)
				begin
					Gout = 1'b1;
					Rin = Xreg;
				end
				else if (instruction == mvi)
				begin
					DINout = 1'b1;
					Done = 1'b1;
					Rin = Xreg;
				end
				else if (instruction == ld)
				begin
					Rin = Xreg;
				end
				else if (instruction == st)
				begin
					ADDR_in = 1'b1;
					W_D = 1'b1;
				end
			end
		endcase
	end
			
endmodule

module multiplexer(input [15:0]Din,
						 input [15:0]R0,
						 input [15:0]R1,
						 input [15:0]R2,
						 input [15:0]R3,
						 input [15:0]R4,
						 input [15:0]R5,
						 input [15:0]R6,
						 input [15:0]R7,
						 input [15:0]G,
						 input [7:0]R_out,
						 input G_out,
						 input Din_out,
						 output reg [15:0]DBUS);

	always@(*)
	begin
		if (Din_out == 1)
			DBUS = Din;
		else if(G_out == 1)
			DBUS = G;
		else if (R_out[0] == 1)
			DBUS = R0;
		else if (R_out[1] == 1)
			DBUS = R1;
		else if (R_out[2] == 1)
			DBUS = R2;
		else if (R_out[3] == 1)
			DBUS = R3;
		else if (R_out[4] == 1)
			DBUS = R4;
		else if (R_out[5] == 1)
			DBUS = R5;
		else if (R_out[6] == 1)
			DBUS = R6;
		else if (R_out[7] == 1)
			DBUS = R7;
		else 
			DBUS = 16'b0;
		end
endmodule

module AddSub(input [15:0]A,
				  input [15:0]DBUS,
				  input sub,
				  output reg [15:0]G);
		
	always@(*)
	begin
		if (sub == 1)
			G = A - DBUS;
		else
			G = A + DBUS;
	end
		
endmodule

module regn(R, Rin, Clock, Q);

	parameter n = 16;
	input [n-1:0] R;
	input Rin, Clock;
	output reg [n-1:0] Q;
	
	always @(negedge Clock)
		if (Rin)
	Q <= R;
	
endmodule

module counter(input [15:0]R,
					input reset,
					input Rin,
					input Clock,
					input increment,
					output reg [15:0]Q);
		
	always@(negedge Clock or negedge reset)
	begin
		if (!reset)
			Q <= 0;
		else if (Rin)
			Q <= R;
		else if (increment)
			Q <= Q + 1;
	end
		
endmodule

module dec3to8(input [2:0]W,
					input En,
					output reg [7:0]Y);

	always @(W or En)
	begin
		if (En == 1)
			case (W)
				3'b000: Y = 8'b00000001;
				3'b001: Y = 8'b00000010;
				3'b010: Y = 8'b00000100;
				3'b011: Y = 8'b00001000;
				3'b100: Y = 8'b00010000;
				3'b101: Y = 8'b00100000;
				3'b110: Y = 8'b01000000;
				3'b111: Y = 8'b10000000;
			endcase
		else
			Y = 8'b00000000;
	end
	
endmodule