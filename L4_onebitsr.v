module L4_onebitsr(clk, set, reset, out);

	input clk, set, reset;
	output out;
	reg out;
	always@(posedge clk)
		if(reset) out <= 0;
		else if(set) out <= 1;

endmodule