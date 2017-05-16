`include "L4_decs.v"

module L4_col16(clk, etch_enb, wi_v, ei_v, rsel_v, csel, top_l, pref_ud, pref_ew,
               pref_ns, cell_cmd, status_in, ret2ue, extend, status_out, xo_v);
    parameter NROWS=16;
    parameter NLAYERS=4;

    input  clk, csel, top_l, pref_ud, pref_ew, pref_ns, etch_enb;
    input  [NROWS-1:0] wi_v, ei_v, rsel_v;
    input  [1:0] cell_cmd;
    input  [3:0] status_in;
	 input 	ret2ue, extend;
    output [3:0] status_out;
    output [NROWS-1:0] xo_v;

    wire [3:0] status_out_15, status_out_14, status_out_13, status_out_12,
	 				status_out_11, status_out_10, status_out_9,  status_out_8,
	 				status_out_7,  status_out_6,  status_out_5,  status_out_4,
	 				status_out_3,  status_out_2,  status_out_1,  status_out_0;

    L4_cell C15 (.clk(clk), .etch_enb(etch_enb), .ni(1'b0), .si(xo_v[14]), .wi(wi_v[15]), .ei(ei_v[15]), 
                .rsel(rsel_v[15]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_15), .xo(xo_v[15]));

    L4_cell C14 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[15]), .si(xo_v[13]), .wi(wi_v[14]), .ei(ei_v[14]), 
                .rsel(rsel_v[14]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_14), .xo(xo_v[14]));

    L4_cell C13 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[14]), .si(xo_v[12]), .wi(wi_v[13]), .ei(ei_v[13]),
                .rsel(rsel_v[13]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_13), .xo(xo_v[13]));

    L4_cell C12 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[13]), .si(xo_v[11]), .wi(wi_v[12]), .ei(ei_v[12]),
                .rsel(rsel_v[12]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_12), .xo(xo_v[12]));


    L4_cell C11 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[12]), .si(xo_v[10]), .wi(wi_v[11]), .ei(ei_v[11]), 
                .rsel(rsel_v[11]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_11), .xo(xo_v[11]));

    L4_cell C10 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[11]), .si(xo_v[9]), .wi(wi_v[10]), .ei(ei_v[10]), 
                .rsel(rsel_v[10]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_10), .xo(xo_v[10]));

    L4_cell C9 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[10]), .si(xo_v[8]), .wi(wi_v[9]), .ei(ei_v[9]),
                .rsel(rsel_v[9]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_9), .xo(xo_v[9]));

    L4_cell C8 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[9]), .si(xo_v[7]), .wi(wi_v[8]), .ei(ei_v[8]),
                .rsel(rsel_v[8]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_8), .xo(xo_v[8]));



    L4_cell C7 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[8]), .si(xo_v[6]), .wi(wi_v[7]), .ei(ei_v[7]), 
                .rsel(rsel_v[7]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_7), .xo(xo_v[7]));

    L4_cell C6 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[7]), .si(xo_v[5]), .wi(wi_v[6]), .ei(ei_v[6]), 
                .rsel(rsel_v[6]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_6), .xo(xo_v[6]));

    L4_cell C5 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[6]), .si(xo_v[4]), .wi(wi_v[5]), .ei(ei_v[5]),
                .rsel(rsel_v[5]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_5), .xo(xo_v[5]));

    L4_cell C4 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[5]), .si(xo_v[3]), .wi(wi_v[4]), .ei(ei_v[4]),
                .rsel(rsel_v[4]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_4), .xo(xo_v[4]));



    L4_cell C3 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[4]), .si(xo_v[2]), .wi(wi_v[3]), .ei(ei_v[3]), 
                .rsel(rsel_v[3]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_3), .xo(xo_v[3]));

    L4_cell C2 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[3]), .si(xo_v[1]), .wi(wi_v[2]), .ei(ei_v[2]), 
                .rsel(rsel_v[2]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_2), .xo(xo_v[2]));

    L4_cell C1 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[2]), .si(xo_v[0]), .wi(wi_v[1]), .ei(ei_v[1]),
                .rsel(rsel_v[1]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_1), .xo(xo_v[1]));

    L4_cell C0 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[1]), .si(1'b0), .wi(wi_v[0]), .ei(ei_v[0]),
                .rsel(rsel_v[0]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_0), .xo(xo_v[0]));



    assign status_out = status_out_15 & status_out_14 & status_out_13 & status_out_12 &
	 							status_out_11 & status_out_10 & status_out_9  & status_out_8  &
	 							status_out_7  & status_out_6  & status_out_5  & status_out_4  &
	 							status_out_3  & status_out_2  & status_out_1  & status_out_0   ;

endmodule
