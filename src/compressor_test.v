module compressor_test

	#(parameter N = 32)
	
	(input logic [16:0] Y,
	input logic [7:1] icins,
	input logic [7:1] cins,
	output logic [7:1] icouts,
    output logic [7:1] couts, //N-bit sum.
	output logic C,
    output logic S);
	

  
  wire [4:1] intS1;
  wire [2:1] intS2;
  wire intS3;
  

  generate

	  genvar k;
	  for(k=1; k<=4; k=k+1) begin
		compressor_5_3 Comps1 (Y[0+((k-1)*4)],Y[1+((k-1)*4)],Y[2+((k-1)*4)],Y[3+((k-1)*4)],icins[k],couts[k],icouts[k],intS1[k]);//YOU WERE RIGHT THE FIRST TIME YOU DUMB SHIT
	  end
	  for(k=0; k<=1; k=k+1) begin
		compressor_5_3 Comps2 (intS1[1+(2*k)],cins[1+(2*k)],intS1[2+(2*k)],cins[1+(2*k)],icins[k+5],couts[k+5],icouts[k+5],intS2[k+1]);//AAAAAAAAAAAAAAAAAAAA FIX THE FUCKIN CARRIES YOU SHITHEAD
	  end
	  compressor_5_3 Comp3 (intS2[1],cins[5],intS2[2],cins[6],icins[7],couts[7],icouts[7],intS3);
	  
	  full_adder finals (intS3,cins[7],Y[16],C,S);
  endgenerate
	
	
	
	
	
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

module test

  #(parameter N = 32); // The parameter "N" may be edited to change bit count.

	logic [16:0] Y;
	logic [7:1] icins;
	logic [7:1] cins;
	logic [7:1] icouts;
    logic [7:1] couts; //N-bit sum.
	logic C;
    logic S;

	logic [30:0] number;
	
  compressor_test CT (Y,icins,cins,icouts,couts,C,S);

int i;
  initial begin
		number = 0;
		Y = number [16:0];
		icins = number[23:17];
		cins = number[30:18];
    
	for(i=0;i<=1000;i=i+1) begin
     #2 number   = i;
	 Y= number [16:0];
	 icins = number[23:17];
	 cins = number[30:18];
	end
     #6 $finish;
    end

endmodule