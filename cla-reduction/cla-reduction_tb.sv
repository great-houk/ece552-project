module reduction_unit_tb();
logic [15:0] rs;
logic [15:0] rt;
logic [15:0] rd;


reduction_unit red(.rs(rs), .rt(rt), .rd(rd));


initial begin
	rs = 16'b1010110000000000;
	rt = 16'b0111001100000000;
	#5;
	if (rd != 16'b1111111111100000) begin	// 32 if ignore overflow
		$display("test 1 failed");
		$stop;
	end
	#5;
	rs = 16'b0011110001000000;
	rt = 16'b0000001000100010;
	if (rd != 16'b0000000000011001) begin  //Replace 0's with 1 if overflow ignored
		$display("Test 2 failed");
		$stop;
	end
	#5;
	rs = 16'b1;
	rt = 16'b1;
	if (rd != 16'hFFF8) begin	//Assuming we sign extend the number and don't limit bits
		$display("Test 3 failed");
		$stop;
	end
	#200 $display("Tests Passed");
	$stop;
end




endmodule