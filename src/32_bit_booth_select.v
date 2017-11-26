module booth_selector

  #(parameter N = 32)

   (output logic [N:0] PPi,	// output is 33 bits  
    input logic [(N-1):0] Y,	// input is 32 bits
    input logic Single,		// These are from the encoder
    input logic Double,
    input logic Negative);

    wire [N:0] w1, w2, w3, w4, w5;
    
    assign w1 = put_Zero(Y);    
    assign w2 = shift_Left(w1);
    assign w3 = Double & w2;
    assign w4 = Single & w1;
    assign w5 = ~(w3 | w4);
    assign PPi = Negative ^ (~w5);
endmodule

function [32:0] put_Zero;
	//This function returns 33 bits ([32:0])
	//	it just tacks a zero as lsb ([msb:lsb])
	//		this gives M + 1 bits for the booth select
	input [31:0] word;
	integer Bit;
	reg [32:0] temp;

	begin
		temp[0] = 0;
		for(Bit = 1; Bit <= 32; Bit = Bit + 1)
			temp[Bit] = word[Bit - 1];
		
		put_Zero = temp;
	end
endfunction

function [32:0] shift_Left;
	//This function shifts 33 bits left by 1 (<<1)
	input [32:0] word;
	integer Bit;
	reg [32:0] temp;
	
	begin
		/*for(Bit = 32; Bit >= 0; Bit = Bit + 1)
			temp[Bit] = word[Bit - 1];*/
		temp = word << 1;
		
		temp[0] = 0;
		shift_Left = temp;
	end
endfunction

/*module test

  #(parameter N = 32);

  logic [N:1] A, B, S;
  logic Cin, Cout;

  n_bit_pg_carry_ripple A1 (A,B,Cin,S,Cout);

  initial
    begin
     A = 0; B = 0; Cin = 0;
     #2 A   = 64'd25;
     #2 B   = 64'd75;
     #2 Cin = 1'b1;
     #6 $finish;
    end

endmodule*/
module test
	
	#();
	//#(parameter N = 31);
	wire [32:0] pp;
	logic [31:0] y;
	logic single, double, neg;

	booth_selector SE (.PPi(pp), .Y(y), .Single(single), .Double(double), .Negative(neg));

	initial
		begin
		$monitor($time,"Y = %d, PP = %d", y, pp);
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
