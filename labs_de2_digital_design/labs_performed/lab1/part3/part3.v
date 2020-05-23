module part3(SW,LEDR,LEDG);
	input [0:17] SW;
	output [0:2] LEDR;
	output [0:2] LEDG;
		
	assign LEDR[0:2] = SW[15:17];

	reg [0:2] LEDG;
	

	
	always@(SW [0:17])
		if(SW[15]==0 & SW[16]==0 & SW[17]==0)
			LEDG[0:2] = SW[0:2];
		else
		if(SW[15]==1 & SW[16]==0 & SW[17]==0)
			LEDG[0:2] = SW[3:5];
		else
		if(SW[15]==0 & SW[16]==1 & SW[17]==0)
			LEDG[0:2] = SW[6:8];
		else
		if(SW[15]==1 & SW[16]==1 & SW[17]==0)
			LEDG[0:2] = SW[9:11];
		else
			LEDG[0:2] = SW[12:14];

	
endmodule
