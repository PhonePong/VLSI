module v2_black_cell
	// From pg. 440,
	// 	g1 = G(i:k)
	// 	g2 = G(k-1:j)
	// 	p1 = P(i:k)
	// 	p2 = P(k-1:j)
	// 	gOut = G(i:j)
	// 	pOut = P(i:j)
	(input logic g1, g2, p1, p2,
	 output logic gOut, pOut);

	wire w;
	assign w = p1 & g2;
	assign gOut = g1 + w;
	assign pOut = p1 & p2;
endmodule

module test

	#();	
	logic g1, g2, p1, p2;
	logic gOut, pOut;

	v2_black_cell BC (g1, g2, p1, p2, gOut, pOut);

	initial
		begin
		g1 = 0; g2 = 0; p1 = 0; p2 = 0;
		#2 g1 = 0; g2 = 0; p1 = 0; p2 = 1;
		#2 g1 = 0; g2 = 0; p1 = 1; p2 = 0;  
		#2 g1 = 0; g2 = 0; p1 = 1; p2 = 1; 
		#2 g1 = 0; g2 = 1; p1 = 0; p2 = 0; 
		#2 g1 = 0; g2 = 1; p1 = 0; p2 = 1; 
		#2 g1 = 0; g2 = 1; p1 = 1; p2 = 0; 
		#2 g1 = 0; g2 = 1; p1 = 1; p2 = 1; 
		#2 g1 = 1; g2 = 0; p1 = 0; p2 = 0; 
		#2 g1 = 1; g2 = 0; p1 = 0; p2 = 1; 
		#2 g1 = 1; g2 = 0; p1 = 1; p2 = 0; 
		#2 g1 = 1; g2 = 0; p1 = 1; p2 = 1; 
		#2 g1 = 1; g2 = 1; p1 = 0; p2 = 0; 
		#2 g1 = 1; g2 = 1; p1 = 0; p2 = 1; 
		#2 g1 = 1; g2 = 1; p1 = 1; p2 = 0; 
		#2 g1 = 1; g2 = 1; p1 = 1; p2 = 1;
		#2 $finish;
		end
endmodule 
