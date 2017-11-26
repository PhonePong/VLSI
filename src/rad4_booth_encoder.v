module	rad4_booth_encoder 
	// From pg. 482,
	// 	x3 = x(2i-1)
	// 	x2 = x(2i)
	// 	x1 = x(2i+1)
	// 	si = SINGLE(i)
	// 	di = DOUBLE(i)
	// 	ni = NEGATIVE(i)
	(input logic x3, x2, x1,
	 output logic si, di, ni);

	wire w1, w2, w3, w4, w5;

	assign si = x3 ^ x2;
	assign w1 = ~x1;
	assign w2 = ~x3;
	assign w3 = ~x2;
	assign w4 = ~(x3 & x2 & w1);
	assign w5 = ~(w2 & w3 & x1);
	assign di = ~w4 | ~w5;
	assign ni = x1;
endmodule

module test

	#();	
	logic x3, x2, x1;
	logic single, double, neg;

	rad4_booth_encoder BE (x3, x2, x1, single, double, neg);

	initial
		begin
		   x1 = 0; x2 = 0; x3 = 0;
		#2 x1 = 0; x2 = 0; x3 = 1;
		#2 x1 = 0; x2 = 1; x3 = 0;
		#2 x1 = 0; x2 = 1; x3 = 1;
		#2 x1 = 1; x2 = 0; x3 = 0;
		#2 x1 = 1; x2 = 0; x3 = 1;
		#2 x1 = 1; x2 = 1; x3 = 0;
		#2 x1 = 1; x2 = 1; x3 = 1;
		#2 $finish;
		end
endmodule 
