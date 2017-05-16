`include "L4_decs.v"

module L4_top16x16( clk, resetn, etch_enb,  
               row_range_sel, row_l_v, row_u_v, 
               col_range_sel, col_l_v, col_u_v, 
               pref_ud, pref_ns, pref_ew,
               cell_cmd, status_in, ret2ue, extend, status_out,
	       top_l );
   parameter NLBITS=2;
   parameter NLAYERS=4;
   parameter NRBITS=4;
   parameter NROWS=16;
   parameter NCBITS=4;
   parameter NCOLS=16;
   
   input               clk;
   input etch_enb;
   input 	       resetn;
   input [2:0]	       row_range_sel;
   input [NRBITS-1:0]  row_l_v, row_u_v;
   input [2:0]	       col_range_sel;
   input [NCBITS-1:0]  col_l_v, col_u_v;
   input 	       pref_ud, pref_ns, pref_ew;
   input [1:0] 	       cell_cmd;
   input [3:0] 	       status_in;
	input					ret2ue, extend;
   output [3:0]        status_out;
   input              top_l;
   
   
   wire [NROWS-1:0]    rsel_v;  // connect decoder outputs to array
   wire [NCOLS-1:0]    csel_v;
   
   
   // row decoder
   L4_decoder #(NRBITS, NROWS) RDEC ( .clk(clk), .sel_range(row_range_sel), .lower(row_l_v), 
                                      .upper(row_u_v), .decout(rsel_v) );
   
   // col decoder
   L4_decoder #(NCBITS, NCOLS) CDEC ( .clk(clk), .sel_range(col_range_sel), .lower(col_l_v), 
                                      .upper(col_u_v), .decout(csel_v) );
   
   // array
   L4_array16x16 ARRAY ( .clk(clk), .etch_enb(etch_enb), .rsel_v(rsel_v), .csel_v(csel_v), 
                       .top_l(top_l), .pref_ud(pref_ud), 
                       .pref_ew(pref_ew), .pref_ns(pref_ns),
                       .cell_cmd(cell_cmd),
		       .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
		       .status_out(status_out) );



   
endmodule
