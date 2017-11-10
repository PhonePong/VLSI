module Toplevel_ALU //This module assembles submodules into ALU

  #(parameter N = 32) // The parameter "N" may be edited to change bit count, bit count of arguments

   (input logic [N-1:0] A, B, //2 input lines
    input logic [2:0] Sel //select line for operations
	input logic Clk //clock signal for iterative operations if necessary
    output logic [(2*N)-1:0] Result,Valid); //Two N-bit input words.

    wire [N-1:0] Sum, Diff, Divd; //sum and difference are size of input arguments, divident might? be
	wire [(2*N)-1:0] Product, ExpProd, NatProd; //product, exponentials are larger size. exponentials will be truncated and overflow flags set
	wire SumValid, DiffValid, ProdValid, EProdValid, NatProdValid, DivValid; //validity signals for all operations
	wire SumOvf, DiffOvf, ProdOvf, EProdOvf, NatProdOvf, DivOvf; //overflow signals
	
	Adder_Name Adder #(.N N) (A,B,Sum,SumOvf,SumValid);
	Sub_Name Sub #(.N N) (A,B,Diff,DiffOvf,DiffValid);
	Mult_Name Mult #(.N N) (A,B,Prod,ProdOvf,ProdValid);
	Div_Name Div #(.N N) (A,B,Div,DivOvf,DivValid);
	Exp_Name Exp #(.N N) (A,B,ExpProd,EProdOvf,EProdValid);
	Nat_Name NatExp #(.N N) (A,B,NatProd,NatProdOvf,NatProdValid);
	
	always_comb
	begin
		case(Sel)
			0: 	Result = { 32{Sum[31]},Sum};
				Valid = SumValid;
			1: 	Result = { 32{Diff[31]},Diff};
				Valid = DiffValid;
			2: 	Result = Mult;
				Valid = ProdValid;
			3: 	Result = { 32{Divd[31]},Divd};
				Valid = DivValid;
			4: 	Result = ExpProd;
				Valid = EProdValid;
			5: 	Result = NatProd;
				Valid = NatProdValid;
		endcase
	end
	
endmodule