module part5(SW,HEX0);
	input [17:0]SW;
	output [0:6]HEX0;

	wire [2:0]M;
	
	part3(SW[17:15],SW[14:12],SW[11:9],SW[8:6],SW[5:3],SW[2:0],M);
	part4(M,HEX0);
endmodule

module part3(S,U,V,W,X,Y,M);
	input [0:2]S,U,V,W,X,Y;
	output [0:2]M;

	reg [0:2] M;
	

	
	always@(S,U,V,W,X,Y)
		if(S[0]==0 & S[1]==0 & S[2]==0)
			M[0:2] = U[0:2];
		else
		if(S[0]==1 & S[1]==0 & S[2]==0)
			M[0:2] = V[0:2];
		else
		if(S[0]==0 & S[1]==1 & S[2]==0)
			M[0:2] = W[0:2];
		else
		if(S[0]==1 & S[1]==1 & S[2]==0)
			M[0:2] = X[0:2];
		else
			M[0:2] = Y[0:2];
endmodule

module part4(c,DISPLAY);
	input [0:2]c;
	output [0:6]DISPLAY;
	
	wire C = c[0];
	wire B = c[1];
	wire A = c[2];
	
	assign DISPLAY[0] = C;
	assign DISPLAY[1] = (~A & ~B & ~C) | (A & B & C);
	assign DISPLAY[2] = (~A & ~B & ~C) | (A & B & C);
	assign DISPLAY[3] = (~A & C) | (~A & B);
	assign DISPLAY[4] = ~A;
	assign DISPLAY[5] = ~A;
	assign DISPLAY[6] = ~A & ~B;
endmodule
