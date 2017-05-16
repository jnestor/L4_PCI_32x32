//-----------------------------------------------------------------------------
// Title         : L4_register - simple register with enable
// Project       : L4 - Maze Routing Accelerator
//-----------------------------------------------------------------------------
// File          : L4_register.v
// Author        : John Nestor  <johnnest@localhost>
// Created       : 19.07.2004
// Last modified : 19.07.2004
//-----------------------------------------------------------------------------
// Description :
// Simple parameterized register with active low synchronous reset
// and load enable.
//-----------------------------------------------------------------------------
// Copyright (c) 2004 by Lafayette College This model is the confidential and
// proprietary property of Lafayette College and the possession or use of this
// file requires a written license from Lafayette College.
//------------------------------------------------------------------------------
// Modification history :
// 19.07.2004 : created
//-----------------------------------------------------------------------------

module L4_register(clk, resetn, en, d, q);
    parameter NBITS=8;
    input  clk;
    input  resetn;
    input  en;
    input  [NBITS-1:0] d;
    output [NBITS-1:0] q;

    reg    [NBITS-1:0] q;

    always @(posedge clk)
        if (!resetn) q <= { NBITS{1'b0} };
        else if (en) q <= d;
endmodule

