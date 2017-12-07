module full_adder
	// From pg. 440,
	// 	A = G(i:k)
	// 	B = G(k-1:j)
	// 	Cin = P(i:k)
	// 	gOut = G(i:j)
	(input logic A, B, Cin, 
	 output logic Cout, S);

	wire w, w2, w3;
	assign w = A ^ B;
	assign S = Cin ^ w;
	assign w2 = A & B;
	assign w3 = w & Cin;
	assign Cout = w2 | w3;
endmodule

module test

	#();	
	logic A, B, Cin;
	logic Cout, S;

	full_adder FA (A, B, Cin, Cout, S);

	initial
		begin
		   Cin = 0; A = 0; B = 0;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 0; A = 0; B = 1;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 0; A = 1; B = 0; 
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 0; A = 1; B = 1;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 1; A = 0; B = 0;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 1; A = 0; B = 1;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 1; A = 1; B = 0;
        #2  $display("Cout: %b S: %b", Cout, S);
		 Cin = 1; A = 1; B = 1; 
        #2  $display("Cout: %b S: %b", Cout, S);
		#2 $finish;
		end
endmodule 