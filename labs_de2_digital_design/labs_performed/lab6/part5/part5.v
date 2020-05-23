module part5();

	

endmodule

module N_mul(input [N-1:0]A,
			    input [N-1:0]B,
				 output [2*N-1:0]P);
	parameter N = 4;
	
	generate
		genvar i;
		for (i=0; i<N; i=i+1)
			begin: gen1
				wire [N+i-1:0]tmp1;
				genvar j;
				for (j=0; j<N; j=j+1)
					begin: gen2
				
						assign tmp1[j+i] = B[i] & A[j];
					end				
			end
	endgenerate
	
	N_bit_Add #(4+1) one(tmp1)
				 
endmodule

module fullAddr(input a,
					 input b,
					 input ci,
					 output s,
					 output co);
	wire k;				 
	assign k = a^b;
	assign s = ci^k;
	assign co = ~k&b | k&ci;
	
endmodule 


module N_bit_Add(input [N-1:0]num1,
						  input [N-1:0]num2,
						  input Cin,
						  output [N-1:0]numOut,
						  output Overflow);
	parameter N = 4;	
	
	wire [N-1:0]tmpCarry;	
	assign Overflow = tmpCarry[N-1];
	
	generate
		genvar i;
		for (i=0; i<N; i=i+1)
			begin: gen1
				fullAddr bit(num1[i],num2[i],Cin,numOut[i],tmpCarry[i]);
			end
	endgenerate
	
endmodule
