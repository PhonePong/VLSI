module v3_gray_cell
	// From pg. 440,
	// 	g1 = G(i:k)
	// 	g2 = G(k-1:m)
	// 	g3 = G(m-1:j)
	// 	p1 = P(i:k)
	// 	p2 = P(k-1:j)
	// 	gOut = G(i:j)
	(input logic g1, g2, g3, p1, p2,
	 output logic gOut);

	wire w1, w2, w3;
	assign w1 = p2 & g3;
	assign w2 = g2 + w1;
	assign w3 = p1 & w2;
	assign gOut = g1 + w3;
endmodule

module test

	#();	
	logic g1, g2, g3, p1, p2;
	logic gOut;

	v3_gray_cell GC (g1, g2, g3, p1, p2, gOut);

	initial
		begin
		   g1 = 0; g2 = 0; g3 = 0; p1 = 0; p2 = 0;
		#2 g1 = 0; g2 = 0; g3 = 0; p1 = 0; p2 = 1;
		#2 g1 = 0; g2 = 0; g3 = 0; p1 = 1; p2 = 0;
		#2 g1 = 0; g2 = 0; g3 = 0; p1 = 1; p2 = 1;
		#2 g1 = 0; g2 = 0; g3 = 1; p1 = 0; p2 = 0;
		#2 g1 = 0; g2 = 0; g3 = 1; p1 = 0; p2 = 1;
		#2 g1 = 0; g2 = 0; g3 = 1; p1 = 1; p2 = 0;
		#2 g1 = 0; g2 = 0; g3 = 1; p1 = 1; p2 = 1;
		#2 g1 = 0; g2 = 1; g3 = 0; p1 = 0; p2 = 0;
		#2 g1 = 0; g2 = 1; g3 = 0; p1 = 0; p2 = 1;
		#2 g1 = 0; g2 = 1; g3 = 0; p1 = 1; p2 = 0;
		#2 g1 = 0; g2 = 1; g3 = 0; p1 = 1; p2 = 1;
		#2 g1 = 0; g2 = 1; g3 = 1; p1 = 0; p2 = 0;
		#2 g1 = 0; g2 = 1; g3 = 1; p1 = 0; p2 = 1;
		#2 g1 = 0; g2 = 1; g3 = 1; p1 = 1; p2 = 0;
		#2 g1 = 0; g2 = 1; g3 = 1; p1 = 1; p2 = 1;
		#2 g1 = 1; g2 = 0; g3 = 0; p1 = 0; p2 = 0;
		#2 g1 = 1; g2 = 0; g3 = 0; p1 = 0; p2 = 1;
		#2 g1 = 1; g2 = 0; g3 = 0; p1 = 1; p2 = 0;
		#2 g1 = 1; g2 = 0; g3 = 0; p1 = 1; p2 = 1;
		#2 g1 = 1; g2 = 0; g3 = 1; p1 = 0; p2 = 0;
		#2 g1 = 1; g2 = 0; g3 = 1; p1 = 0; p2 = 1;
		#2 g1 = 1; g2 = 0; g3 = 1; p1 = 1; p2 = 0;
		#2 g1 = 1; g2 = 0; g3 = 1; p1 = 1; p2 = 1;
		#2 g1 = 1; g2 = 1; g3 = 0; p1 = 0; p2 = 0;
		#2 g1 = 1; g2 = 1; g3 = 0; p1 = 0; p2 = 1;
		#2 g1 = 1; g2 = 1; g3 = 0; p1 = 1; p2 = 0;
		#2 g1 = 1; g2 = 1; g3 = 0; p1 = 1; p2 = 1;
		#2 g1 = 1; g2 = 1; g3 = 1; p1 = 0; p2 = 0;
		#2 g1 = 1; g2 = 1; g3 = 1; p1 = 0; p2 = 1;
		#2 g1 = 1; g2 = 1; g3 = 1; p1 = 1; p2 = 0;
		#2 g1 = 1; g2 = 1; g3 = 1; p1 = 1; p2 = 1;
		#2 $finish;
		end
endmodule 
