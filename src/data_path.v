module data_path(input logic a,
		input logic b,
		input logic clk,
		output logic y);
 
   assign U4 = a ^ b;
   x_reg qflop(U4, clk);
   y_reg qflop(x_reg, clk, y);
 
endmodule 
