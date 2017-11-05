module twoflops(input logic clk,
		input logic d0,
		input logic d1,
		output logic q0, 
		output logic q1);

always_ff @(posedge clk)
 begin
   q1 <= d1;
   q0 <= d0;
 end
endmodule


module test; // This is the test bench. It specifies input signals to drive the DUT.

 logic clk, d0, d1;
 logic q0, q1;

twoflops tf1 (clk, d0, d1, q0, q1); // This line instantiates the DUT.

// Generate the clock.

  initial clk = 0;
  always #5 clk = ~clk; // 10 ns clock period.

initial 
  begin
     d0 = 1'b0; // Initiallize "d0" to 0.
     d1 = 1'b0; // Initiallize "d1" to 0.
     #7  d0 = 1;
     #10 d1 = 1;
     #13 $finish; // Simulate for 7+10+13 = 30 ns (three clock periods).
  end

endmodule 
