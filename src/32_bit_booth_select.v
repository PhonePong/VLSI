module booth_selector

  #(parameter N = 32)

   (output logic [N:0] PPi,	// output is 33 bits  
    output logic [N:0] monitorShift,
    output logic [N:0] monitorSingle,
    input logic [(N-1):0] Y,	// input is 32 bits
    input logic Single,		// These are from the encoder
    input logic Double,
    input logic Negative);

    wire [N:0] newWord, w2, w3, w4, w5;
    
    assign monitorShift = w2;
    assign monitorSingle = {33{Single}};
    assign newWord = {1'b0, Y};    
    assign w2 = {Y, 1'b0};
    assign w3 = {33{Double}} & w2;
    assign w4 = {33{Single}} & newWord;
    assign w5 = ~(w3 | w4);
    assign PPi = {33{Negative}} ^ (~w5);
endmodule

module test
	
	#();
	//#(parameter N = 31);
	logic [32:0] pp,monitorShift,monitorSing;
	logic [31:0] y;
	logic single, double, neg;

	booth_selector SE (pp,monitorShift,monitorSing, y, single, double, neg);

	initial
		begin
		//$monitor($time,"Y = %d, PP = %d", y, pp);
		y = 10;
		$display("Multiplicand value is: %d", y);
							// PPi
		#2 single = 0; double = 0; neg = 0; 	// 0
		$display("PPi should be 0. Value = %d", pp);

		#2 single = 1; double = 0; neg = 0;	// Y
		$display("PPi should be %d. Value = %d", y, pp);
	
		#2 single = 0; double = 1; neg = 0;	// 2Y
		$display("PPi should be 2x %d. Value = %d", y, pp);

		#2 single = 0; double = 1; neg = 1;	// -2Y
		$display("PPi should be -2x %d. Value = %d", y, pp);

		#2 single = 1; double = 0; neg = 1;	// -Y
		$display("PPi should be - %d. Value = %d", y, pp);

		#2 single = 0; double = 0; neg = 1; 	// -0 (=0)
		$display("PPi should be -0 (=0). Value = %d", pp);
		#2 $finish;
		end
endmodule 
