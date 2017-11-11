module v2_gray_cell
	// From pg. 440,
	// 	g1 = G(i:k)
	// 	g2 = G(k-1:j)
	// 	p1 = P(i:k)
	// 	gOut = G(i:j)
	(input logic g1, g2, p1, 
	 output logic gOut);

	wire w;
	assign w = p1 & g2;
	assign gOut = g1 + w;
endmodule

module test

	#();	
	logic g1, g2, p1;
	logic gOut;

	v2_gray_cell GC (g1, g2, p1, gOut);

	initial
		begin
		   g1 = 0; g2 = 0; p1 = 0;
		#2 g1 = 0; g2 = 0; p1 = 1;
		#2 g1 = 0; g2 = 1; p1 = 0; 
		#2 g1 = 0; g2 = 1; p1 = 1;
		#2 g1 = 1; g2 = 0; p1 = 0;
		#2 g1 = 1; g2 = 0; p1 = 1;
		#2 g1 = 1; g2 = 1; p1 = 0;
		#2 g1 = 1; g2 = 1; p1 = 1; 
		#2 $finish;
		end
endmodule 
