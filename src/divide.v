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

module test

    #(parameter N = 32);
    reg [N - 1:0] dividend;
    reg [N - 1:0] divisor;
    
    wire [N - 1:0] quotient;
	wire [N - 1:0] remainder;

    divide DIV (dividend, divisor, quotient, remainder);

    initial 
		begin
			dividend = 14;   divisor = 3;  
		#2 dividend = 333; divisor = 1; 
		#2 dividend = 5001; divisor = 5; 
		#2 dividend = 900;  divisor = 9;   
		#2 $finish;
		end
endmodule
