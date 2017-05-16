//-----------------------------------------------------------------------------
// Title         : L4_array4x4
// Project       : L4 Routing Accelerator
//-----------------------------------------------------------------------------
// File          : L4_array4x4.v
// Author        : John Nestor
// Created       : 07.03.2003
// Last modified : 07.03.2003
//-----------------------------------------------------------------------------
// Description : 4 X 4 array or L4 routing cells
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2003 by John Nestor This model is the confidential and
// proprietary property of John Nestor and the possession or use of this
// file requires a written license from John Nestor.
//------------------------------------------------------------------------------
// Modification history :
// 07.03.2003 : created
//-----------------------------------------------------------------------------

`include "L4_decs.v"

module L4_array16x16(clk, etch_enb, rsel_v, csel_v, top_l, pref_ud,
                   pref_ew, pref_ns, cell_cmd, status_in, ret2ue, extend, status_out);
    parameter          NROWS=16; // use as symbolic constants - dont try to instantiate!
    parameter          NCOLS=16;
    parameter          NLAYERS = 4;
    input              clk, top_l, pref_ud, pref_ew, pref_ns, etch_enb;
    input  [1:0]       cell_cmd;
    input  [3:0]       status_in;
	 input					ret2ue, extend;
    output [3:0]       status_out;
    input  [NROWS-1:0] rsel_v;
    input  [NCOLS-1:0] csel_v;

    wire [NROWS-1:0] xo_15_v ;
    wire [NROWS-1:0] xo_14_v ;
    wire [NROWS-1:0] xo_13_v ;
    wire [NROWS-1:0] xo_12_v ;
    wire [NROWS-1:0] xo_11_v ;
    wire [NROWS-1:0] xo_10_v ;
    wire [NROWS-1:0] xo_9_v ;
    wire [NROWS-1:0] xo_8_v ;
    wire [NROWS-1:0] xo_7_v ;
    wire [NROWS-1:0] xo_6_v ;
    wire [NROWS-1:0] xo_5_v ;
    wire [NROWS-1:0] xo_4_v ;
    wire [NROWS-1:0] xo_3_v ;
    wire [NROWS-1:0] xo_2_v ;
    wire [NROWS-1:0] xo_1_v ;
    wire [NROWS-1:0] xo_0_v ;

    wire [3:0] status_out_15, status_out_14, status_out_13, status_out_12,
	 				status_out_11, status_out_10, status_out_9,  status_out_8,
	 				status_out_7,  status_out_6,  status_out_5,  status_out_4,
	 				status_out_3,  status_out_2,  status_out_1,  status_out_0;


    // columns 0 to 15 run L to R

    L4_col16 COL0( .clk(clk), .etch_enb(etch_enb),.wi_v(16'd0), .ei_v(xo_1_v), .rsel_v(rsel_v), 
                  .csel(csel_v[0]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_0), .xo_v(xo_0_v) );    

    L4_col16 COL1( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_0_v), .ei_v(xo_2_v), .rsel_v(rsel_v), 
                  .csel(csel_v[1]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_1), .xo_v(xo_1_v) );   

    L4_col16 COL2( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_1_v), .ei_v(xo_3_v), .rsel_v(rsel_v), 
                  .csel(csel_v[2]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_2), .xo_v(xo_2_v) );  

    L4_col16 COL3( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_2_v), .ei_v(xo_4_v), .rsel_v(rsel_v), 
                  .csel(csel_v[3]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_3), .xo_v(xo_3_v) );  

    L4_col16 COL4( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_3_v), .ei_v(xo_5_v), .rsel_v(rsel_v), 
                  .csel(csel_v[4]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_4), .xo_v(xo_4_v) );    

    L4_col16 COL5( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_4_v), .ei_v(xo_6_v), .rsel_v(rsel_v), 
                  .csel(csel_v[5]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_5), .xo_v(xo_5_v) );   

    L4_col16 COL6( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_5_v), .ei_v(xo_7_v), .rsel_v(rsel_v), 
                  .csel(csel_v[6]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_6), .xo_v(xo_6_v) );  

    L4_col16 COL7( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_6_v), .ei_v(xo_8_v), .rsel_v(rsel_v), 
                  .csel(csel_v[7]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_7), .xo_v(xo_7_v) );  

    L4_col16 COL8( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_7_v), .ei_v(xo_9_v), .rsel_v(rsel_v), 
                  .csel(csel_v[8]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_8), .xo_v(xo_8_v) );    

    L4_col16 COL9( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_8_v), .ei_v(xo_10_v), .rsel_v(rsel_v), 
                  .csel(csel_v[9]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_9), .xo_v(xo_9_v) );   

    L4_col16 COL10( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_9_v), .ei_v(xo_11_v), .rsel_v(rsel_v), 
                  .csel(csel_v[10]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_10), .xo_v(xo_10_v) );  

    L4_col16 COL11( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_10_v), .ei_v(xo_12_v), .rsel_v(rsel_v), 
                  .csel(csel_v[11]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_11), .xo_v(xo_11_v) );  

    L4_col16 COL12( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_11_v), .ei_v(xo_13_v), .rsel_v(rsel_v), 
                  .csel(csel_v[12]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_12), .xo_v(xo_12_v) );    

    L4_col16 COL13( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_12_v), .ei_v(xo_14_v), .rsel_v(rsel_v), 
                  .csel(csel_v[13]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_13), .xo_v(xo_13_v) );   

    L4_col16 COL14( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_13_v), .ei_v(xo_15_v), .rsel_v(rsel_v), 
                  .csel(csel_v[14]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_14), .xo_v(xo_14_v) );  

    L4_col16 COL15( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_14_v), .ei_v(16'd0), .rsel_v(rsel_v), 
                  .csel(csel_v[15]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_15), .xo_v(xo_15_v) );  



    assign status_out = status_out_0  & status_out_1  & status_out_2  & status_out_3  &
	 							status_out_4  & status_out_5  & status_out_6  & status_out_7  &
	 							status_out_8  & status_out_9  & status_out_10 & status_out_11 &
	 							status_out_12 & status_out_13 & status_out_14 & status_out_15 ;

 endmodule       
                                                    

