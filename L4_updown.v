//-----------------------------------------------------------------------------
// Title         : L4_updown - Up/Down counter
// Project       : L4 - Maze Routing Accelerator
//-----------------------------------------------------------------------------
// File          : L4_updown.v
// Author        : John Nestor  <johnnest@localhost>
// Created       : 19.07.2004
// Last modified : 19.07.2004
//-----------------------------------------------------------------------------
// Description :
// Simple up/down counter used during backtrace.
//-----------------------------------------------------------------------------
// Copyright (c) 2004 by Lafayette College This model is the confidential and
// proprietary property of Lafayette College and the possession or use of this
// file requires a written license from Lafayette College.
//------------------------------------------------------------------------------
// Modification history :
// 19.07.2004 : created
//-----------------------------------------------------------------------------


module L4_updown(clk, resetn, lden, upen, dnen, d, q);
    parameter NBITS=8;
    input  clk;
    input  resetn;
    input  lden;
    input  upen;
    input  dnen;
    input  [NBITS-1:0] d;
    output [NBITS-1:0] q;

    reg    [NBITS-1:0] q;

    always @(posedge clk)
        if (!resetn) q <= { NBITS{1'b0} };
        else if (lden) q <= d;
        else if (upen) q <= q + 1;
        else if (dnen) q <= q - 1;
endmodule

