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
  
  #(parameter N = 32);
  
  logic Cout,intCout,S;
  logic [4:0] total;
  
  compressor_5_3 C1 (total[4],total[3],total[2],total[1],total[0],Cout,intCout,S);
  
  initial
    begin
     total = 5'd0;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd1;
     #2$display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd2;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd3;
     #2$display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd4;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd5;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd6;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd7;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd8;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd9;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd10;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd11;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd12;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd13;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd14;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd15;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd16;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd17;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd18;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd19;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd20;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd21;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd22;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd23;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd24;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd25;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd26;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd27;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd28;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd29;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd30;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd31;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
     total = 5'd0;
     #2 $display("%b %b %b %b", total, intCout, Cout, S);
    end

endmodule