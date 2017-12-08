module test_mux; //test bench for mux.
  logic [1:0] select;
  logic [63:0] a, s, m, d, out; 
  mux mux_1(select, a, b, m, d, out); // instantiate the mux module.
  initial
   begin
		select = 0; a = 10; b = 30; m = 50; d = 70;
	#2 select = 1; a = 10; b = 30; m = 50; d = 70;
	#2 select = 2; a = 10; b = 30; m = 50; d = 70;
	#2 select = 3; a = 10; b = 30; m = 50; d = 70;
	#2 $finish;
	
    //#1; a = 1;
    //#1; b = 0;
    //#2; select = 1'bx;
    //#2; select = 1'bz;
    //#2; select = 1;
    //#3; b = 1;
   end
endmodule: test_mux

module mux (input logic [1:0] mux_select,
			input logic	[63:0] addition,
			input logic	[63:0] subtract,
			input logic	[63:0] mult,
			input logic	[63:0] div,//the actual mux.
			output logic [63:0] mux_output);
  always_comb
   begin
    case(mux_select)
       0: mux_output = addition;
       1: mux_output = subtract;
	   2: mux_output = mult;
	   3: mux_output = div;
       default mux_output = 1'bx;
    endcase
   end
endmodule: mux
    
