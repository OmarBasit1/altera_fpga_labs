module part2(SW,LEDR);
	input [17:0]SW;
	output [7:0]LEDR;
	
	assign LEDR[0] = (~SW[17] & SW[0] | (SW[17] & SW[8]));	
	assign LEDR[1] = (~SW[17] & SW[1] | (SW[17] & SW[9]));
	assign LEDR[2] = (~SW[17] & SW[2] | (SW[17] & SW[10]));
	assign LEDR[3] = (~SW[17] & SW[3] | (SW[17] & SW[11]));
	assign LEDR[4] = (~SW[17] & SW[4] | (SW[17] & SW[12]));
	assign LEDR[5] = (~SW[17] & SW[5] | (SW[17] & SW[13]));
	assign LEDR[6] = (~SW[17] & SW[6] | (SW[17] & SW[14]));
	assign LEDR[7] = (~SW[17] & SW[7] | (SW[17] & SW[15]));

endmodule

