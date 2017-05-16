module L4_mux8(sel, in0, in1, in2, in3, in4, in5, in6, in7, y);
    parameter NBITS=8;
    input  [2:0] sel;
    input  [NBITS-1:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output [NBITS-1:0] y;

    reg    [NBITS-1:0] y;

    always @(sel or in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7)
        case (sel)
          3'd0 : y = in0;
          3'd1 : y = in1;
          3'd2 : y = in2;
          3'd3 : y = in3;
          3'd4 : y = in4;
          3'd5 : y = in5;
          3'd6 : y = in6;
          3'd7 : y = in7;
          default : y = { NBITS{1'b0} };
        endcase
endmodule

