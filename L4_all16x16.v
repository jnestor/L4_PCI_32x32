//-----------------------------------------------------------------------------
// Title         : L4_all
// Project       : L4 Routing Accelerator
//-----------------------------------------------------------------------------
// File          : L4_all4x4.v
// Author        : John Nestor  <johnnest@localhost>
// Created       : 16.07.2004
// Last modified : 16.07.2004
//-----------------------------------------------------------------------------
// Description :
// Top-level file for a 4 X 4 accelerator.  Includes all datapath elements and
// a control FSM.
//-----------------------------------------------------------------------------
// Copyright (c) 2004 by Lafayette College This model is the confidential and
// proprietary property of Lafayette College and the possession or use of this
// file requires a written license from Lafayette College.
//------------------------------------------------------------------------------
// Modification history :
// 16.07.2004 : created; based on L3 design
//-----------------------------------------------------------------------------

`include "L4_decs.v"

module L4_allx16(clk, resetn, cmd_empty, cmd_in, cmd_rd, result_full, result_out, result_wr, ctl_state, status_reg, cur_layer);
   parameter           NRBITS=4;
   parameter           NROWS=16;
   parameter           NCBITS=4;
   parameter           NCOLS=16;
   parameter           NLBITS=2;
   parameter           NLAYERS=4;
   input 	       clk;
   input 	       resetn;
   input 	       cmd_empty;
   input [31:0]        cmd_in;
   output 	       cmd_rd;
   input 	       result_full;
   output [31:0]        result_out;
   output 	       result_wr;
   output [4:0]        ctl_state;
   output [3:0]        status_reg;
   output [NLBITS-1:0] cur_layer;
   wire [2:0] 	       col_range_sel;
   wire [NRBITS-1:0]   row_l_v, row_u_v;
   wire [2:0] 	       row_range_sel;
   wire [NCBITS-1:0]   col_l_v, col_u_v;
   wire 	       pref_ud, pref_ew, pref_ns;
   wire [1:0] 	       cell_cmd;
   wire [3:0] 	       status_in;
	wire				ret2ue;
	wire						extend; 
	wire [3:0]			 status_out;
   wire 	       top_l;


   

   L4_top16x16 TOP( .clk(clk), .resetn(resetn), .etch_enb(etch_enb), .row_range_sel(row_range_sel), 
		      .row_l_v(row_l_v), .row_u_v(row_u_v),
		      .col_range_sel(col_range_sel), .col_l_v(col_l_v), .col_u_v(col_u_v), 
		      .pref_ud(pref_ud), .pref_ns(pref_ns), .pref_ew(pref_ew),
		      .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
		      .status_out(status_out), 
		      .top_l(top_l) );

   L4_control CONTROL (.clk(clk), .resetn(resetn),  .etch_enb(etch_enb),
                   .cmd_empty(cmd_empty), .cmd_in(cmd_in), .cmd_rd(cmd_rd), // interface to input queue
                   .result_full(result_full), .result_out(result_out), .result_wr(result_wr), // interface to output queue
                   .row_range_sel(row_range_sel), .row_l_v(row_l_v), .row_u_v(row_u_v), // Interface to array top
                   .col_range_sel(col_range_sel), .col_l_v(col_l_v), .col_u_v(col_u_v), 
                   .pref_ud(pref_ud), .pref_ns(pref_ns), .pref_ew(pref_ew),
                   .cell_cmd(cell_cmd), .status_rd(status_out), .status_wr(status_in),	.ret2ue(ret2ue),
                   .cur_layer(cur_layer), .top_l(top_l),	.extend(extend),
                   .ctl_state(ctl_state), .status_reg(status_reg));   // For debugging


endmodule // L4_all16x16


