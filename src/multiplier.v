module multiplier

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (input logic [N:1] A, B, //Two N-bit input words.
    output logic [N*2:1] P, //N-bit Product.
    output logic O,
    output logic [64:0] Monitor1,
    output logic [64:0] Monitor2,
    output logic [64:0] Monitor3,
    output logic [64:0] Monitor4,
    output logic [64:0] Monitor5,
    output logic [64:0] Monitor6,
    output logic [64:0] Monitor7,
    output logic [64:0] Monitor8,
    output logic [64:0] Monitor9,
    output logic [64:0] Monitor10,
    output logic [64:0] Monitor11,
    output logic [64:0] Monitor12,
    output logic [64:0] Monitor13,
    output logic [64:0] Monitor14,
    output logic [64:0] Monitor15,
    output logic [64:0] Monitor16,
    output logic [64:0] Monitor17,
    output logic [64:0] Monitor18); //1-bit overflow flag
  
  wire [(N+2):0] Xtended;
 
  assign Xtended = {1'b0,1'b0,A,1'b0};
  
  wire [N/2:0] S;//wires for single, double, negative lines for 17 booth encoder/selectors
  wire [N/2:0] D;
  wire [N/2:0] NN;
  
  
  wire [N:0] Partials [16:0]; //array of 17 33 bit wires to assign partial products
  
  
  wire [(N*2):1] PartialES [16:0]; 	//extended partials to 64 columns, 65 to make the loop work. 
  wire [16:0] e; 					//sign bits for each PP
  
  genvar x;
  generate
    for(x = 0; x <= 16; x = x + 1) begin //negative bit XOR with sign bit of Y coming in
      assign e[x] = ^{NN[x],B[N]};
    end
    //assign partial products into 64 bit signals according to figure 11.83
    assign PartialES[0] = {~e[0], e[0], e[0], Partials[0]}; //assign first partial, different from the rest.

    for( x = 1; x <= 14; x = x + 1) begin
      assign PartialES[x] = {1'b1, ~e[x], Partials[x], 1'b0, NN[x], {(x-1)*2{1'b0}}}; //extra 0 to allow for pad column. 
    end
  endgenerate
  
  genvar i;
  
  generate 
    
    for (i=0; i<=N; i=i+2) begin : encoders
      rad4_booth_encoder e1 (Xtended[i], Xtended[i+1], Xtended[i+2], S[i/2], D[i/2], NN[i/2]);
    end
  
    
    for (i=0; i<=N/2; i=i+1) begin : selectors
      booth_selector p1 (Partials[i], A, S[i], D[i], NN[i]);
    end
    
  endgenerate
  
  
  

  
  assign PartialES[15] = {~(e[15]), Partials[15], 1'b0, NN[14], {28{1'b0}}};
  assign PartialES[16] = {{30{1'b0}},1'b0,NN[16]};
   
  wire  intcarry1 [64:0][4:0]; //65 5 bit busses
  wire  intcarry2 [64:0][2:0];
  wire intcarry3 [64:0];
  
  wire [4:1] intC1 [64:0];
  wire [4:1] intS1 [64:0];
  
  wire [2:1] intS2 [64:0];
  wire [2:1] intC2 [64:0];
  wire intS3 [64:0];
  wire intC3 [64:0];
  
  wire [64:1] Treesum;
  wire [64:1] Treecarry;
  
  
  
  assign intcarry1[0][0] = 0;
  assign intcarry1[0][1] = 0;
  assign intcarry1[0][2] = 0;
  assign intcarry1[0][3] = 0;
  assign intcarry1[0][4] = 0;
  
  assign intcarry2[0][1] = 0;//intitialize
  assign intcarry2[0][2] = 0;
  assign intcarry3[0] = 0;
  

  genvar z;
  generate
  for(z=0;z<=64;z=z+1) begin
  
	assign intC1[0][1] = 0;
	assign intC1[0][2] = 0;
	assign intC1[0][3] = 0;
	assign intC1[0][4] = 0;
	
	assign intC2[0][1] = 0;
	assign intC2[0][2] = 0;
	
	assign intC3[0] = 0;
  end
  endgenerate
  
  genvar ii;
  generate
    for(ii=1;ii<=64;ii=ii+1) begin
    genvar k;
      for(k=1; k<=4; k=k+1) begin
        compressor_5_3 Comps1 (PartialES[0+((k-1)*4)][ii],PartialES[1+((k-1)*4)][ii],PartialES[2+((k-1)*4)][ii],PartialES[3+((k-1)*4)][ii],intcarry1[ii-1][k],intC1[ii][k],intcarry1[ii][k],intS1[ii][k]);//YOU WERE RIGHT THE FIRST TIME YOU DUMB SHIT
      end
      for(k=1; k<=2; k=k+1) begin
        compressor_5_3 Comps2 (intS1[ii][k],intC1[ii-1][k],intS1[ii][k+1],intC1[ii-1][k+1],intcarry2[ii-1][k],intC2[ii][k],intcarry2[ii][k],intS2[ii][k]);//AAAAAAAAAAAAAAAAAAAA FIX THE FUCKIN CARRIES YOU SHITHEAD
      end
      compressor_5_3 Comp3 (intS2[ii][1],intC2[ii-1][1],intS2[ii][2],intC2[ii-1][2],intcarry3[ii-1],intC3[ii],intcarry3[ii],intS3[ii]);
      
	  full_adder finals (intS3[ii],intC3[ii-1],PartialES[16][ii],Treecarry[ii],Treesum[ii]);
    end
  endgenerate
  
  wire midcarry; //carry between two final KS adders
  wire NC[1:0];
  n_bit_pg_Kogge_Stone_A A1 (Treesum[32:1],Treecarry[32:1],1'b0,P[32:1],midcarry);
  n_bit_pg_Kogge_Stone_A A2 (Treesum[64:33],Treecarry[64:33],midcarry,P[64:33],O);
  
  
  assign Monitor1 = {1'bZ,PartialES[0]};
  assign Monitor2 = {1'bZ,PartialES[1]};
  assign Monitor3 = {1'bZ,PartialES[2]};
  assign Monitor4 = {1'bZ,PartialES[0][1]};
  assign Monitor5 = {1'bZ,PartialES[1][1]};
  assign Monitor6 = {1'bZ,PartialES[2][1]};
  assign Monitor7 = {1'bZ,PartialES[3][1]};
  assign Monitor8 = {1'bZ,intC1[1][1]};
  assign Monitor9 = {1'bZ,intcarry1[1][1]};
  assign Monitor10 = {1'bZ,intS1[1][1]};
  assign Monitor11 = {1'bZ,intcarry1[0][1]};
  assign Monitor12 = {1'bZ,intS1[6]};
  assign Monitor13 = {1'bZ,intS1[7]};
  assign Monitor14 = {1'bZ,intS1[8]};
  assign Monitor15 = {1'bZ,intS1[9]};
  assign Monitor16 = {1'bZ,e};
  assign Monitor17 = {1'bZ,Treecarry};
  assign Monitor18 = {1'bZ,Treesum};
  
endmodule

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

module compressor_5_3 //see diagram in report/gitHub

  #(parameter N = 32)

  (input logic A, B, C, D, Cin, 
   output logic Cout, intCout, S); //intermediare carry, carry, sum
  
  wire i1,i2,x1,x2;
  
  xnorish xn1 (A,B,i1,x1);
  xnorish xn2 (C,D,i2,x2);
  
  wire o1,o2,na1;
  
  assign o1 = i1 | i2;
  assign o2 = x1 | x2;
  
  assign na1 = ~&{o1,o2};
  
  wire xo1,a1;
  
  assign xo1 = x1 ^ x2;
  
  assign a1 = xo1 & Cin;
  
  assign intCout =  ~& {i1,i2};
  assign Cout = a1 | na1;
  assign S =  xo1 ^ Cin;
    
endmodule

module xnorish
  (input logic A,B,
   output logic I,O);
  
  wire w;
  assign I = ~& {A,B};
  assign w = A | B;
  assign O = ~& {I,w};
  
endmodule

module	rad4_booth_encoder 
	// From pg. 482,
	// 	x3 = x(2i-1)
	// 	x2 = x(2i)
	// 	x1 = x(2i+1)
	// 	si = SINGLE(i)
	// 	di = DOUBLE(i)
	// 	ni = NEGATIVE(i)
	(input logic x3, x2, x1,
	 output logic si, di, ni);

	wire w1, w2, w3, w4, w5;

	assign si = x3 ^ x2;
	assign w1 = ~x1;
	assign w2 = ~x3;
	assign w3 = ~x2;
	assign w4 = ~(x3 & x2 & w1);
	assign w5 = ~(w2 & w3 & x1);
	assign di = ~w4 | ~w5;
	assign ni = x1;
endmodule

module booth_selector

  #(parameter N = 32)

   (output logic [N:0] PPi,	// output is 33 bits  
    input logic [(N-1):0] Y,	// input is 32 bits
    input logic Single,		// These are from the encoder
    input logic Double,
    input logic Negative);

    wire [N:0] newWord, w2, w3, w4, w5;
    
    //assign monitorShift = w2;
    //assign monitorSingle = {33{Single}};
    assign newWord = {1'b0, Y};    
    assign w2 = {Y, 1'b0};
    assign w3 = {33{Double}} & w2;
    assign w4 = {33{Single}} & newWord;
    assign w5 = ~(w3 | w4);
    assign PPi = {33{Negative}} ^ (~w5);
endmodule

// Code your design here
module n_bit_pg_Kogge_Stone_A //Top level module for N-bit Carry Ripple Adder (See Fig. 11.14). //note: modified for Kogg-Stone, NOT expandable.

  #(parameter N = 32) // The parameter "N" may be edited to change bit count.

   (input logic [N:1] A, B, //Two N-bit input words.
    input logic Cin, //1-bit carry in.
    output logic [N:1] S, //N-bit sum.
    output logic Cout); //1-bit carry out.

  wire [N:1] P, G; //Wires for the N bitwise PG signals. 
  wire [(N-1):1] C; //Wires for the N-1 carry signals.

    N_Bit_Bitwise_PG BPG1 (P, G, A, B); //Instantiate bitwise PG logic, Eq. (11.5).
    N_Bit_Group_PG GPG1 (C, G[(N-1):1], P[(N-1):1], Cin); //Instantiate group PG logic, Eq. (11.10).
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
   
   (output logic [(N):1] GG, //N-1 group generate signals that are output to sum logic.
    input logic [(N):1] G, P, //PG inputs from bitwise PG logic.
    input logic Cin); //1-bit carry in.
	
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
	
	for (i=17; i<=32; i=i+1) begin : KoggGreys5 //Loop saves having to manually assign all ins and outs of many many grey cells.
		v2_gray_cell Stage4Gs (Int4G[i],GG[i-16],Int4P[i],GG[i]); //fifth stage grey cells
	end
	
	for (i=2; i<=(N); i=i+1) begin : KoggInts1 //Loop saves having to manually assign all ins and outs of many many black cells.
		v2_black_cell Stage1Bs (G[i],G[i-1],P[i],P[i-1],Int1G[i],Int1P[i]); //first stage black cells
	end
	
	for (i=4; i<=(N); i=i+1) begin : KoggInts2
		v2_black_cell Stage2Bs (Int1G[i],Int1G[i-1],Int1P[i],Int1P[i-1],Int2G[i],Int2P[i]); //second stage blacks
	end
	
	for (i=8; i<=(N); i=i+1) begin : KoggInts3
		v2_black_cell Stage3Bs (Int2G[i],Int2G[i-1],Int2P[i],Int2P[i-1],Int3G[i],Int3P[i]); //third stage blacks
	end
	
	for (i=16; i<=(N); i=i+1) begin : KoggInts4
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
	
  #(parameter N= 32);
	//#(parameter N = 31);
  logic [N:1] A, B; //Two N-bit input words.
  logic [N*2:1] P; //N-bit Product.
  logic O; //1-bit overflow flag
  logic [64:0] Monitor1;
  logic [64:0] Monitor2;
  logic [64:0] Monitor3;
  logic [64:0] Monitor4;
  logic [64:0] Monitor5;
  logic [64:0] Monitor6;
  logic [64:0] Monitor7;
  logic [64:0] Monitor8;
  logic [64:0] Monitor9;
  logic [64:0] Monitor10;
  logic [64:0] Monitor11;
  logic [64:0] Monitor12;
  logic [64:0] Monitor13;
  logic [64:0] Monitor14;
  logic [64:0] Monitor15;
  logic [64:0] Monitor16;
  logic [64:0] Monitor17;
  logic [64:0] Monitor18;

  multiplier M (A,B,P,o,Monitor1,Monitor2,Monitor3,Monitor4,Monitor5,Monitor6,Monitor7,Monitor8,Monitor9,Monitor10,Monitor11,Monitor12,Monitor13,Monitor14,Monitor15,Monitor16,Monitor17,Monitor18);

	initial
		begin
		  A=10;
          B=10;
		#2 
          $display("P should be 100. Value = %d", P);
	
	//	#2 B=1000;
          $display("P should be 10000. Value = %d", P);

	//	#2 A=-25;
          $display("P should be -25000. Value = %d", P);

	//	#2 B=-25;
          $display("P should be 525. Value = %d", P);

		#2 $finish;
		end
endmodule 