module part2(input [3:0]KEY,
				 output [9:0]LEDR,
				 output [7:0]LEDG,
				 output [6:0]HEX0,
				 output [6:0]HEX1,
				 output [6:0]HEX2,
				 output [6:0]HEX3);
				 
	wire [15:0]BUS, DIN;
	assign LEDG[7:0] = BUS[7:0];
	assign LEDR[7:0] = BUS[15:8];
	processor CPU(KEY[3], KEY[2], KEY[1], KEY[0], LEDR[9], BUS, DIN);

	display disp(DIN, HEX0, HEX1, HEX2, HEX3);
	
endmodule

module processor(input MClock,
					  input PClock,
					  input Run, 
					  input Resetn,
					  output Done, 
					  output [15:0]Bus,
					  output [15:0]Din_display);
	
	wire [15:0]DIN;
	
	memory M(MClock, Resetn, DIN);
	assign Din_display = DIN;
	
	wire [15:0]busloop;
	assign Bus = busloop;
	
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
	wire A_in,G_in,G_out,Din_out, Add_Sub, IR_in;
	
	
	regn r0(R_d0, R_in[0], PClock,R_q0);
	regn r1(R_d1, R_in[1], PClock,R_q1);
	regn r2(R_d2, R_in[2], PClock,R_q2);
	regn r3(R_d3, R_in[3], PClock,R_q3);
	regn r4(R_d4, R_in[4], PClock,R_q4);
	regn r5(R_d5, R_in[5], PClock,R_q5);
	regn r6(R_d6, R_in[6], PClock,R_q6);
	regn r7(R_d7, R_in[7], PClock,R_q7);
	
	
	regn a(A, A_in, PClock,A_reg);
	regn g(G, G_in, PClock,G_reg);
	regn #(9) ir(DIN[8:0], IR_in, PClock,IR);
	
	AddSub adder(A_reg, busloop, Add_Sub, G);
	multiplexer mux(DIN, R_q0, R_q1, R_q2, R_q3, R_q4, R_q5, R_q6, R_q7,
													G_reg, R_out, G_out, Din_out, busloop);
	
	control_unit CU(PClock, Run, Resetn, IR, R_out, G_out, Din_out,
											R_in, A_in, G_in, Add_Sub, IR_in, Done);
	
endmodule

module control_unit(input clock,
						  input run,
						  input resetn,
						  input [8:0]IR,
						  output reg [7:0]Rout,
						  output reg Gout,
						  output reg DINout,
						  output reg [7:0]Rin,
						  output reg Ain,
						  output reg Gin,
						  output reg AddSub,
						  output reg IRin,
						  output reg Done);
			
	parameter T0 = 2'b0, T1 = 2'd1, T2 = 2'd2, T3 = 2'd3;
	parameter nop = 3'b0, mv = 3'b001, mvi = 3'b010, add = 3'b011, sub = 3'b100;
	reg [1:0]pres_state, next_state;
	
	wire [2:0]instruction,Rx,Ry;
	assign instruction = IR[8:6];
	
	wire [7:0]Xreg, Yreg;
	
	dec3to8 decX (IR[5:3], 1'b1, Xreg);
	dec3to8 decY (IR[2:0], 1'b1, Yreg);
	
	
	always@(IR or pres_state)
	begin
		case(pres_state)
			T0:
			begin
				next_state = T1;
				IRin = 1'b1;
			end
			T1:
			begin
				IRin = 1'b0;
				if(instruction == nop)
					next_state = T0;
				else if(instruction == mv)
					next_state = T0;
				else if(instruction == mvi)
					next_state = T0;
				else 
					next_state = T2;
			end
			T2:
				next_state = T3;
			T3:
				next_state = T0;
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
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
			end
			T1:
			begin
					Rin = 8'b0;
					AddSub = 1'b0;
					Gin = 1'b0;
					Ain = 1'b0;
					Rout = 8'b0;
					Gout = 1'b0;
					DINout = 1'b0;
					Done = 1'b0;
					if (instruction == mv)
					begin
						Rin = Xreg;
						Rout = Yreg;
						Done = 1'b1;
					end
					else if (instruction == mvi)
					begin
						Rin = Xreg;
						DINout = 1'b1;
						Done = 1'b1;
					end
					else if (instruction == add)
					begin
						Ain = 1'b1;
						Rout = Xreg;
					end
					else if (instruction == sub)
					begin
						Ain = 1'b1;
						Rout = Xreg;
					end
				end
			T2:
			begin
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				if (instruction == add)
				begin
					Rout = Yreg;
					Gin = 1'b1;
				end
				else if (instruction == sub)
				begin
					Rout = Yreg;
					Gin = 1'b1;
					AddSub = 1'b1;
				end
			end
			T3:
			begin
				Rin = 8'b0;
				AddSub = 1'b0;
				Gin = 1'b0;
				Ain = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				Done = 1'b0;
				if (instruction == add | instruction == sub)
				begin
					Gout =1'b1;
					Rin = Xreg;
					Done = 1'b1;
				end
			end
		endcase
	end
			
endmodule

module memory(input MClock,
				  input Resetn,
				  output [15:0]data);

	reg [4:0]count;
	always@(negedge MClock or negedge Resetn)
	begin
		if (!Resetn)
			count <= 5'b11111;
		else 
			count <= count + 1'b1;
	end
	
	lpmram ram(count,MClock,16'b0,1'b0,data);	  
				  
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

module display(input [15:0]data,
					output [6:0]hex0,
					output [6:0]hex1,
					output [6:0]hex2,
					output [6:0]hex3);
					
		hex_to_seven zero(data[3:0], hex0);
		hex_to_seven one(data[7:4], hex1);
		hex_to_seven two(data[11:8], hex2);
		hex_to_seven three(data[15:12], hex3);
		
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
		4'b1010	:				//A
			hex = 7'b0001000;
		4'b1011	:				//b
			hex = 7'b0000011;
		4'b1100	:				//C
			hex = 7'b1000110;
		4'b1101	:				//d
			hex = 7'b0100001;
		4'b1110	:				//E
			hex = 7'b0000110;
		4'b1111	:				//F
			hex = 7'b0001110;
	endcase
	
endmodule