///////////////////////////////////////////////////
// FA.sv  This design will take in 3 bits       //
// and add them to produce a sum and carry out //
////////////////////////////////////////////////
module FA(
  input 	A,B,Cin,	// three input bits to be added
  output	S,Cout		// Sum and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic XOR1, XOR2;
	logic AND1, AND2;
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	xor XOR(XOR1,A,B);
	and AND(AND1, A, B);
	xor XORACin(S, XOR1, Cin);
	and ANDXC(AND2, XOR1, Cin);
	or ORXA(Cout, AND2, AND1);

	
	
endmodule