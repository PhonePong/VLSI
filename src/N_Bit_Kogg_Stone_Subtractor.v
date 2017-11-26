module n_bit_pg_Kogge_Stone_S//note: modified for Kogg-Stone, NOT expandable. - ezpz made it a subtractor

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (input logic [N:1] A, B, //Two N-bit input words. A-B No carry in.
    output logic [N:1] S, //N-bit sum.
    output logic Cout); //1-bit carry out.

  wire [N:1] P, G; //Wires for the N bitwise PG signals. 
  wire [(N-1):1] C; //Wires for the N-1 carry signals.
  wire [N:1] notB
  
  assign notB = not B;
  
    N_Bit_Bitwise_PG BPG1 (P, G, A, notB); //Instantiate bitwise PG logic, Eq. (11.5).
    N_Bit_Group_PG GPG1 (C, G[(N-1):1], P[(N-1):1], 1); //Instantiate group PG logic, Eq. (11.10).
    N_Bit_Sum_Logic SL1 (Cout, S, G[N], {C,Cin}, P); //Instantiate sum logic, Eqs. (11.7) and (11.11).

endmodule

module N_Bit_Bitwise_PG //This module realizes the bitwise PG logic of Eq (11.5) and FIG 11.12.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (output logic [N:1] P, G, //N-bit Propagate and Generate signals.
    input logic [N:1] A, B); //Two N-bit input words.

    assign G = A&B; //Bitwise AND of inputs A and B, Eq. (11.5).
    assign P = A^B; //Bitwise XOR of inputs A and B, Eq. (11.5).

endmodule

module N_Bit_Group_PG //This module realizes the group PG logic of Eq (11.10) and FIG 11.14.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.
   
   (output logic [(N-1):1] GG, //N-1 group generate signals that are output to sum logic.
    input logic [(N-1):1] G, P, //PG inputs from bitwise PG logic.
    input logic Cin); //1-bit carry in.

	wire GplusC[(N-1):0];
	
	wire Int1G[(N-1):2];
	wire Int2G[(N-1):4];
	wire Int3G[(N-1):8];
	wire Int4G[(N-1):16];
	
	wire Int1P[(N-1):2];
	wire Int2P[(N-1):4];
	wire Int3P[(N-1):8];
	wire Int4P[(N-1):16];
     
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
	
	for (i=2; i<=(N-1); i=i+1) begin : KoggInts1 //Loop saves having to manually assign all ins and outs of many many black cells.
		v2_black_cell Stage1Bs (G[i],G[i-1],P[i],P[i-1],Int1G[i],Int1P[i]); //first stage black cells
	end
	
	for (i=4; i<=(N-1); i=i+1) begin : KoggInts2
		v2_black_cell Stage2Bs (Int1G[i],Int1G[i-1],Int1P[i],Int1P[i-1],Int2G[i],Int2P[i]); //second stage blacks
	end
	
	for (i=8; i<=(N-1); i=i+1) begin : KoggInts3
		v2_black_cell Stage3Bs (Int2G[i],Int2G[i-1],Int2P[i],Int2P[i-1],Int3G[i],Int3P[i]); //third stage blacks
	end
	
	for (i=16; i<=(N-1); i=i+1) begin : KoggInts4
		v2_black_cell Stage4Bs (Int3G[i],Int3G[i-1],Int3P[i],Int3P[i-1],Int4G[i],Int4P[i]); // fourth stage blacks
	end
	
	endgenerate
	
	
endmodule

module N_Bit_Sum_Logic //This module realizes the sum logic of Eq. (11.7) and FIG 11.14.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (output logic Cout, //1-bit carry out.
    output logic [N:1] S, //N-bit sum.
    input logic GN, //Most significant group generate bit.
    input logic [(N-1):0] C, //The carry signals from the group PG logic are also the group gernerate signals
                             //(see pg. 437).
    input logic [N:1] P); //P inputs from bitwise PG logic.

    assign S = P^C; //Eq. (11.7).
    assign Cout = GN | P[N]&C[(N-1)]; //Eq. (11.11).

endmodule

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

module test

  #(parameter N = 32); // The parameter "N" may be edited to change bit count.

  logic [N:1] A, B, S;
  logic Cin, Cout;

  n_bit_pg_Kogge_Stone_S S1 (A,B,Cin,S,Cout);

  initial
    begin
     A = 0; B = 0; Cin = 0;
     #2 A   = 64'd25;
     #2 B   = 64'd75;
     #2 Cin = 1'b1;
     #6 $finish;
    end

endmodule
