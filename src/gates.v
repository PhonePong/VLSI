module gates(input logic [0:3] a,
		input logic [0:3] b,
		output logic [0:3] y1, 
		output logic y2);

assign y1[0] = a[0]&&b[0];
assign y1[1] = a[1]&&b[1];
assign y1[2] = a[2]&&b[2];
assign y1[3] = a[3]&&b[3];
assign y2 = &a;

endmodule


module test; // This is the test bench. It specifies input signals to drive the DUT.

 logic [0:3]a, b, y1;
 logic y2;

gates ands (a, b, y1, y2); // This line instantiates the DUT.

initial 
  begin
     a = 4'b0000; // Initiallize "a" to 0.
     b = 4'b0000; // Initiallize "b" to 0.
     #5 a = 4'b0101;
	b = 4'b1010;	
     #5 a = 4'b1111;
     #10 $finish; // Simulate for 7+10+13 = 30 ns (three clock periods).
  end

endmodule 
