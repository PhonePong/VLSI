module Toplevel_ALU //This module assembles submodules into ALU

  #(parameter N = 32) // The parameter "N" may be edited to change bit count, bit count of arguments

   (input logic [N-1:0] A, B, 	// 2 32-bit input lines
    input logic [1:0] Sel, 		// 2 bit select line for operations
	//input logic Clk //clock signal for iterative operations if necessary
    output logic [(2*N)-1:0] Result); //Two N-bit input words.

	logic [63:0] mux_out; 
	logic [63:0] m;
    wire [N-1:0] Sum, Diff, Quotient, Remainder; //sum and difference are size of input arguments, divident might? be
	wire [(2*N)-1:0] Product, ExpProd, NatProd; //product, exponentials are larger size. exponentials will be truncated and overflow flags set
	//wire SumValid, DiffValid, ProdValid, EProdValid, NatProdValid, DivValid; //validity signals for all operations
	//wire SumOvf, DiffOvf, ProdOvf, EProdOvf, NatProdOvf, DivOvf; //overflow signals
	wire Cout_add;
	wire Cout_sub;
	
	// #(.N N) force lower modules to this N value
	// Addition
	n_bit_pg_Kogge_Stone_A Adder (A, B, Sum, Cout_add);
	// Subtraction
	n_bit_pg_Kogge_Stone_S Sub (A, B, Diff, Cout_sub);
	// Multiplication
	assign m = 10;
	//Mult_Name Mult #(.N N) (A,B,Prod,ProdOvf,ProdValid);
	// Division
	divide Div (A, B, Quotient, Remainder);
	
	mux mux_1(Sel, {Cout_add, Sum}, {Cout_sub, Diff}, m, {Remainder, Quotient}, mux_out); // instantiate the mux module.
endmodule
// =======================================================================================================

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
endmodule
// =======================================================================================================
// ============================ ADDITION =====================================================
module n_bit_pg_Kogge_Stone_A //Top level module for N-bit Carry Ripple Adder (See Fig. 11.14). //note: modified for Kogg-Stone, NOT expandable.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (input logic [N:1] A, B, //Two N-bit input words.
    input logic Cin, //1-bit carry in.
    output logic [N:1] S, //N-bit sum.
    output logic Cout); //1-bit carry out.

  wire [N:1] P, G; //Wires for the N bitwise PG signals. 
  wire [(N):1] C; //Wires for the N-1 carry signals.
	wire CP;
  
  
    N_Bit_Bitwise_PG BPG1 (P, G, A, B); //Instantiate bitwise PG logic, Eq. (11.5).
    N_Bit_Group_PG GPG1 (C, CP, G[(N-1):1], P[(N-1):1], Cin); //Instantiate group PG logic, Eq. (11.10).
    N_Bit_Sum_Logic SL1 (Cout, S, G[N], {C,Cin}, P); //Instantiate sum logic, Eqs. (11.7) and (11.11).

endmodule
// =======================================================================================================
// ============================ SUBTRACTION =====================================================
module n_bit_pg_Kogge_Stone_S//note: modified for Kogg-Stone, NOT expandable. - ezpz made it a subtractor

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (input logic [N:1] A, B, //Two N-bit input words.
    output logic [N:1] S, //N-bit sum.
    output logic Cout); //1-bit carry out.

	
	wire Cin;
	assign Cin = 1'b1;
	wire [N:1] notb;
	assign notb = ~B;
	
  wire [N:1] P, G; //Wires for the N bitwise PG signals. 
  wire [(N):1] C; //Wires for the N-1 carry signals.
	wire CP;
  
  
    N_Bit_Bitwise_PG BPG1 (P, G, A, notb); //Instantiate bitwise PG logic, Eq. (11.5).
    N_Bit_Group_PG GPG1 (C, CP, G[(N-1):1], P[(N-1):1], Cin); //Instantiate group PG logic, Eq. (11.10).
    N_Bit_Sum_Logic SL1 (Cout, S, G[N], {C,Cin}, P); //Instantiate sum logic, Eqs. (11.7) and (11.11).

endmodule
// =======================================================================================================
// ============================ PG LOGIC =====================================================
module N_Bit_Bitwise_PG //This module realizes the bitwise PG logic of Eq (11.5) and FIG 11.12.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (output logic [N:1] P, G, //N-bit Propagate and Generate signals.
    input logic [N:1] A, B); //Two N-bit input words.

    assign G = A&B; //Bitwise AND of inputs A and B, Eq. (11.5).
    assign P = A^B; //Bitwise XOR of inputs A and B, Eq. (11.5).

endmodule

module N_Bit_Group_PG //This module realizes the group PG logic of Eq (11.10) and FIG 11.14.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.
   
   (output logic [(N):1] GG, //N-1 group generate signals that are output to sum logic.
   output logic CP,
    input logic [(N-1):1] G, P, //PG inputs from bitwise PG logic.
    input logic Cin); //1-bit carry in.

	wire GplusC[(N-1):0];
	
	wire Int1G[(N):2];
	wire Int2G[(N):4];
	wire Int3G[(N):8];
	wire Int4G[(N):16];
	
	wire Int1P[(N):2];
	wire Int2P[(N):4];
	wire Int3P[(N):8];
	wire Int4P[(N):16];
     
    v2_gray_cell Stage1G1 (G[1],Cin,P[1],GG[1]); //only one for this stage
	
	v2_gray_cell Stage2G1 (Int1G[2],Cin,Int1P[2],GG[2]); //only 2, for loop would have 1 term
	v2_gray_cell Stage2G2 (Int1G[3],GG[1],Int1P[3],GG[3]);
	
	v2_gray_cell Stage3G1 (Int2G[4],Cin,Int2P[4],GG[4]); //4, for loop has 3 terms.
	
	v2_gray_cell Stage4G1 (Int3G[8],Cin,Int3P[8],GG[8]); //8, for loop has 7 terms.
	
	v2_gray_cell Stage5G1 (Int4G[16],Cin,Int4P[16],GG[16]); //16, for loop has 15 terms.
	
	genvar i;
	
	generate 
	
	for (i=5; i<=7; i=i+1) begin : KoggGreys3 //Loop saves having to manually assign all ins and outs of many many grey cells.
		v2_gray_cell Stage3Gs (Int2G[i],GG[i-4],Int2P[i],GG[i]); //third stage grey cells
	end
	
	for (i=9; i<=15; i=i+1) begin : KoggGreys4 //Loop saves having to manually assign all ins and outs of many many grey cells.
		v2_gray_cell Stage4Gs (Int3G[i],GG[i-8],Int3P[i],GG[i]); //fourth stage grey cells
	end
	
	for (i=17; i<=31; i=i+1) begin : KoggGreys5 //Loop saves having to manually assign all ins and outs of many many grey cells.
		v2_gray_cell Stage4Gs (Int4G[i],GG[i-16],Int4P[i],GG[i]); //fifth stage grey cells
	end
	
	for (i=2; i<=(N); i=i+1) begin : KoggInts1 //Loop saves having to manually assign all ins and outs of many many black cells.
		v2_black_cell Stage1Bs (G[i],G[i-1],P[i],P[i-1],Int1G[i],Int1P[i]); //first stage black cells
	end
	
	for (i=4; i<=(N); i=i+1) begin : KoggInts2
		v2_black_cell Stage2Bs (Int1G[i],Int1G[i-2],Int1P[i],Int1P[i-2],Int2G[i],Int2P[i]); //second stage blacks
	end
	
	for (i=8; i<=(N); i=i+1) begin : KoggInts3
		v2_black_cell Stage3Bs (Int2G[i],Int2G[i-4],Int2P[i],Int2P[i-4],Int3G[i],Int3P[i]); //third stage blacks
	end
	
	for (i=16; i<=(N); i=i+1) begin : KoggInts4
		v2_black_cell Stage4Bs (Int3G[i],Int3G[i-8],Int3P[i],Int3P[i-8],Int4G[i],Int4P[i]); // fourth stage blacks
	end
	
	endgenerate
	
	wire carryG;
	
	v2_black_cell extra (Int4G[32], Int4G[(32-16)],carryG,CP);
	
	assign GG[N] = carryG;
	
endmodule

module N_Bit_Sum_Logic 			//This module realizes the sum logic of Eq. (11.7) and FIG 11.14.

  #(parameter N = 32) 			// The parameter "N" may be edited to change bit count.

   (output logic Cout, 			//1-bit carry out.
    output logic [N:1] S, 		//N-bit sum.
    input logic GN, 			//Most significant bitwise generate bit.
    input logic [(N-1):0] C, 	//The carry signals from the group PG logic are also the group gernerate signals
								//(see pg. 437).
    input logic [N:1] P); 		//P inputs from bitwise PG logic.

    assign S = P^C; 			//Eq. (11.7).
    assign Cout = GN | P[N]&C[(N-1)]; //Eq. (11.11).

endmodule
// =======================================================================================================
// =================================== CELLS FOR PG NETWORK =============================================================
module v2_gray_cell
	(input logic g1, g2, p1, 
	 output logic gOut);

	wire w;
	assign w = p1 & g2;
	assign gOut = g1 + w;
endmodule

module v2_black_cell
	(input logic g1, g2, p1, p2,
	 output logic gOut, pOut);

	wire w;
	assign w = p1 & g2;
	assign gOut = g1 + w;
	assign pOut = p1 & p2;
endmodule
// =======================================================================================================
// =================================== DIVISION =======================================================

module divide // from https://www.youtube.com/watch?v=zbuldnBPNWg 
	
	#(parameter N = 32)
	(input logic [(N - 1):0] dividend,					// N bit positive dividend
		input logic [(N - 1):0] divisor,				// N bit positive divisor
		output logic [(N - 1):0] quotient, 				// N bit quotient
		output logic [(N - 1):0] R);   					// Remainder
	
	
 	reg [(N - 1):0] quotient = 0;
	reg [(N - 1):0] temp_Numer;
	reg [(N - 1):0] temp_Denom;
	reg [N:0] remaind;   
	integer i;

	always@ (dividend or divisor)						// procedural continuous assignment

		begin
			remaind = 0;
			temp_Numer = dividend;
			temp_Denom = divisor;
			
        	for(i = 0; i < N ;i = i + 1)    							// do N times
				begin
            		remaind = {remaind[ N - 2:0], temp_Numer[N - 1]};	// shift remainder left 1
            		temp_Numer[N - 1:1] = temp_Numer[N - 2:0];			// shift dividend left 1
            		remaind = remaind - temp_Denom;						// remainder = remainder - divisor

            		if(remaind[N - 1] == 1)    							// If sign bit of remainder is 1
						begin
                		temp_Numer[0] = 0;								// Numer LSB = 0
                		remaind = remaind + temp_Denom; 				// add divisor to negative result (restores the remainder)
						end
            		else
                	temp_Numer[0] = 1;									// Numer LSB = 1
        		end
    		quotient = temp_Numer;   									// end
			R = remaind;												// get Remainder
		end 
endmodule


// =================================== TEST BENCH =======================================================
module test_calc; 						//test bench for calculator.

  logic [1:0] select;
  logic [31:0] a, b;
  logic [63:0] out;
  
  Toplevel_ALU top(a, b, select, out); 	// instantiate the calculator.
  
  initial
   begin
		select = 0; a = 10; b = 30;
	#2 select = 1; a = 10; b = 30; 
	#2 select = 2; a = 0; b = 0;
	#2 select = 3; a = 30; b = 10;
	#2 $finish;
   end
endmodule

// =======================================================================================================