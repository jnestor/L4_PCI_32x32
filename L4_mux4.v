module L4_mux4(sel, in0, in1, in2, in3, y);
    parameter NBITS=8;
    input  [1:0] sel;
    input  [NBITS-1:0] in0, in1, in2, in3;
    output [NBITS-1:0] y;

    reg    [NBITS-1:0] y;

    always @(sel or in0 or in1 or in2 or in3)
        case (sel)
          3'd0 : y = in0;
          3'd1 : y = in1;
          3'd2 : y = in2;
	     3'd3 : y = in3;
	  default : y = { NBITS{1'b0} };
        endcase
endmodule

