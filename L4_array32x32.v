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

module L4_array32x32(clk, etch_enb, rsel_v, csel_v, top_l, pref_ud,
                   pref_ew, pref_ns, cell_cmd, status_in, ret2ue, extend, status_out);
    parameter          NROWS=32; // use as symbolic constants - dont try to instantiate!
    parameter          NCOLS=32;
    parameter          NLAYERS = 8;
    input              clk, top_l, pref_ud, pref_ew, pref_ns, etch_enb;
    input  [1:0]       cell_cmd;
    input  [3:0]       status_in;
	 input					ret2ue, extend;
    output [3:0]       status_out;
    input  [NROWS-1:0] rsel_v;
    input  [NCOLS-1:0] csel_v;

	 reg    [3:0]       status_out;
	 wire   [3:0]       status_out_next;

    wire [NROWS-1:0] xo_0_v,  xo_1_v,  xo_2_v,  xo_3_v,  xo_4_v,  xo_5_v,  xo_6_v,  xo_7_v, 
                     xo_8_v,  xo_9_v,  xo_10_v, xo_11_v, xo_12_v, xo_13_v, xo_14_v, xo_15_v, 
                     xo_16_v, xo_17_v, xo_18_v, xo_19_v, xo_20_v, xo_21_v, xo_22_v, xo_23_v, 
                     xo_24_v, xo_25_v, xo_26_v, xo_27_v, xo_28_v, xo_29_v, xo_30_v, xo_31_v; 


    wire [3:0] status_out_31, status_out_30, status_out_29, status_out_28,
               status_out_27, status_out_26, status_out_25, status_out_24,
               status_out_23, status_out_22, status_out_21, status_out_20,
               status_out_19, status_out_18, status_out_17, status_out_16,
               status_out_15, status_out_14, status_out_13, status_out_12,
               status_out_11, status_out_10, status_out_9,  status_out_8,
               status_out_7,  status_out_6,  status_out_5,  status_out_4,
               status_out_3,  status_out_2,  status_out_1,  status_out_0;


    // columns 0 to 31 run L to R

    L4_col32 COL0( .clk(clk), .etch_enb(etch_enb),.wi_v(32'd0), .ei_v(xo_1_v), .rsel_v(rsel_v), 
                  .csel(csel_v[0]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_0), .xo_v(xo_0_v) );
    // synthesis attribute RLOC of COL0 is x0y0
						    

    L4_col32 COL1( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_0_v), .ei_v(xo_2_v), .rsel_v(rsel_v), 
                  .csel(csel_v[1]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_1), .xo_v(xo_1_v) );   
    // synthesis attribute RLOC of COL1 is x1y0

    L4_col32 COL2( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_1_v), .ei_v(xo_3_v), .rsel_v(rsel_v), 
                  .csel(csel_v[2]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_2), .xo_v(xo_2_v) );  
    // synthesis attribute RLOC of COL2 is x2y0

    L4_col32 COL3( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_2_v), .ei_v(xo_4_v), .rsel_v(rsel_v), 
                  .csel(csel_v[3]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_3), .xo_v(xo_3_v) );  
    // synthesis attribute RLOC of COL3 is x3y0

    L4_col32 COL4( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_3_v), .ei_v(xo_5_v), .rsel_v(rsel_v), 
                  .csel(csel_v[4]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_4), .xo_v(xo_4_v) );    
    // synthesis attribute RLOC of COL4 is x4y0

    L4_col32 COL5( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_4_v), .ei_v(xo_6_v), .rsel_v(rsel_v), 
                  .csel(csel_v[5]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_5), .xo_v(xo_5_v) );   
    // synthesis attribute RLOC of COL5 is x5y0

    L4_col32 COL6( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_5_v), .ei_v(xo_7_v), .rsel_v(rsel_v), 
                  .csel(csel_v[6]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_6), .xo_v(xo_6_v) );  
    // synthesis attribute RLOC of COL6 is x6y0

    L4_col32 COL7( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_6_v), .ei_v(xo_8_v), .rsel_v(rsel_v), 
                  .csel(csel_v[7]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_7), .xo_v(xo_7_v) );  
    // synthesis attribute RLOC of COL7 is x7y0

    L4_col32 COL8( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_7_v), .ei_v(xo_9_v), .rsel_v(rsel_v), 
                  .csel(csel_v[8]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_8), .xo_v(xo_8_v) );    
    // synthesis attribute RLOC of COL8 is x8y0

    L4_col32 COL9( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_8_v), .ei_v(xo_10_v), .rsel_v(rsel_v), 
                  .csel(csel_v[9]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_9), .xo_v(xo_9_v) );   
    // synthesis attribute RLOC of COL9 is x9y0

    L4_col32 COL10( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_9_v), .ei_v(xo_11_v), .rsel_v(rsel_v), 
                  .csel(csel_v[10]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_10), .xo_v(xo_10_v) );  
    // synthesis attribute RLOC of COL10 is x10y0

    L4_col32 COL11( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_10_v), .ei_v(xo_12_v), .rsel_v(rsel_v), 
                  .csel(csel_v[11]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_11), .xo_v(xo_11_v) );  
    // synthesis attribute RLOC of COL11 is x11y0

    L4_col32 COL12( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_11_v), .ei_v(xo_13_v), .rsel_v(rsel_v), 
                  .csel(csel_v[12]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_12), .xo_v(xo_12_v) );    
    // synthesis attribute RLOC of COL12 is x12y0

    L4_col32 COL13( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_12_v), .ei_v(xo_14_v), .rsel_v(rsel_v), 
                  .csel(csel_v[13]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_13), .xo_v(xo_13_v) );   
    // synthesis attribute RLOC of COL13 is x13y0

    L4_col32 COL14( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_13_v), .ei_v(xo_15_v), .rsel_v(rsel_v), 
                  .csel(csel_v[14]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_14), .xo_v(xo_14_v) );  
    // synthesis attribute RLOC of COL14 is x14y0

    L4_col32 COL15( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_14_v), .ei_v(xo_16_v), .rsel_v(rsel_v), 
                  .csel(csel_v[15]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_15), .xo_v(xo_15_v) );  
    // synthesis attribute RLOC of COL15 is x15y0

    L4_col32 COL16( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_15_v), .ei_v(xo_17_v), .rsel_v(rsel_v), 
                  .csel(csel_v[16]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_16), .xo_v(xo_16_v) );    
    // synthesis attribute RLOC of COL16 is x16y0

    L4_col32 COL17( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_16_v), .ei_v(xo_18_v), .rsel_v(rsel_v), 
                  .csel(csel_v[17]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_17), .xo_v(xo_17_v) );   
    // synthesis attribute RLOC of COL17 is x17y0

    L4_col32 COL18( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_17_v), .ei_v(xo_19_v), .rsel_v(rsel_v), 
                  .csel(csel_v[18]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_18), .xo_v(xo_18_v) );  
    // synthesis attribute RLOC of COL18 is x18y0

    L4_col32 COL19( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_18_v), .ei_v(xo_20_v), .rsel_v(rsel_v), 
                  .csel(csel_v[19]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_19), .xo_v(xo_19_v) );  
    // synthesis attribute RLOC of COL19 is x19y0

    L4_col32 COL20( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_19_v), .ei_v(xo_21_v), .rsel_v(rsel_v), 
                  .csel(csel_v[20]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_20), .xo_v(xo_20_v) );    
    // synthesis attribute RLOC of COL20 is x20y0

    L4_col32 COL21( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_20_v), .ei_v(xo_22_v), .rsel_v(rsel_v), 
                  .csel(csel_v[21]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_21), .xo_v(xo_21_v) );   
    // synthesis attribute RLOC of COL21 is x21y0

    L4_col32 COL22( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_21_v), .ei_v(xo_23_v), .rsel_v(rsel_v), 
                  .csel(csel_v[22]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_22), .xo_v(xo_22_v) );  
    // synthesis attribute RLOC of COL22 is x22y0

    L4_col32 COL23( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_22_v), .ei_v(xo_24_v), .rsel_v(rsel_v), 
                  .csel(csel_v[23]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_23), .xo_v(xo_23_v) );  
    // synthesis attribute RLOC of COL23 is x23y0

    L4_col32 COL24( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_23_v), .ei_v(xo_25_v), .rsel_v(rsel_v), 
                  .csel(csel_v[24]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_24), .xo_v(xo_24_v) );    
    // synthesis attribute RLOC of COL24 is x24y0

    L4_col32 COL25( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_24_v), .ei_v(xo_26_v), .rsel_v(rsel_v), 
                  .csel(csel_v[25]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_25), .xo_v(xo_25_v) );   
    // synthesis attribute RLOC of COL25 is x25y0

    L4_col32 COL26( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_25_v), .ei_v(xo_27_v), .rsel_v(rsel_v), 
                  .csel(csel_v[26]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_26), .xo_v(xo_26_v) );  
    // synthesis attribute RLOC of COL26 is x26y0

    L4_col32 COL27( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_26_v), .ei_v(xo_28_v), .rsel_v(rsel_v), 
                  .csel(csel_v[27]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_27), .xo_v(xo_27_v) );  
    // synthesis attribute RLOC of COL27 is x27y0

    L4_col32 COL28( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_27_v), .ei_v(xo_29_v), .rsel_v(rsel_v), 
                  .csel(csel_v[28]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_28), .xo_v(xo_28_v) );    
    // synthesis attribute RLOC of COL28 is x28y0

    L4_col32 COL29( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_28_v), .ei_v(xo_30_v), .rsel_v(rsel_v), 
                  .csel(csel_v[29]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_29), .xo_v(xo_29_v) );   
    // synthesis attribute RLOC of COL29 is x29y0

    L4_col32 COL30( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_29_v), .ei_v(xo_31_v), .rsel_v(rsel_v), 
                  .csel(csel_v[30]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_30), .xo_v(xo_30_v) );  
    // synthesis attribute RLOC of COL30 is x30y0

    L4_col32 COL31( .clk(clk), .etch_enb(etch_enb),.wi_v(xo_30_v), .ei_v(32'd0), .rsel_v(rsel_v), 
                  .csel(csel_v[31]), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew),
                  .pref_ns(pref_ns), .cell_cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), 
						.extend(extend), .status_out(status_out_31), .xo_v(xo_31_v) );  
    // synthesis attribute RLOC of COL31 is x31y0


    assign status_out_next = status_out_0  & status_out_1  & status_out_2  & status_out_3  &
                        status_out_4  & status_out_5  & status_out_6  & status_out_7  &
                        status_out_8  & status_out_9  & status_out_10 & status_out_11 &
                        status_out_12 & status_out_13 & status_out_14 & status_out_15 &
                        status_out_16 & status_out_17 & status_out_18 & status_out_19 &
                        status_out_20 & status_out_21 & status_out_22 & status_out_23 &
                        status_out_24 & status_out_25 & status_out_26 & status_out_27 &
                        status_out_28 & status_out_29 & status_out_30 & status_out_31 ;

    always @(posedge clk)
	     status_out = status_out_next;  /* register status here instead of L4_cell 4/9/06 */
 endmodule       
                                                    

