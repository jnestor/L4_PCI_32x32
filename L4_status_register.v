`include "L4_decs.v"

module L4_status_register(clk, resetn, set_empty, lden, d, q);
    parameter NBITS=4;
    input  clk;
    input  resetn;
    input  set_empty;
    input  lden;
    input  [NBITS-1:0] d;
    output [NBITS-1:0] q;

    reg    [NBITS-1:0] q;

    always @(posedge clk)
        if (!resetn) q <= { NBITS{1'b0} };
        else if (set_empty) q <= `EMPTY;
        else if (lden) q <= d;
endmodule

