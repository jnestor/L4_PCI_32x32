`include "L4_decs.v"

module L4_col32(clk, etch_enb, wi_v, ei_v, rsel_v, csel, top_l, pref_ud, pref_ew,
               pref_ns, cell_cmd, status_in, ret2ue, extend, status_out, xo_v);
    parameter NROWS=32;
    parameter NLAYERS=8;

    input  clk, csel, top_l, pref_ud, pref_ew, pref_ns, etch_enb;
    input  [NROWS-1:0] wi_v, ei_v, rsel_v;
    input  [1:0] cell_cmd;
    input  [3:0] status_in;
	 input 	ret2ue, extend;
    output [3:0] status_out;
    output [NROWS-1:0] xo_v;

    wire [3:0] status_out_31, status_out_30, status_out_29, status_out_28,
	 				status_out_27, status_out_26, status_out_25, status_out_24,
	 				status_out_23, status_out_22, status_out_21, status_out_20,
	 				status_out_19, status_out_18, status_out_17, status_out_16,
					status_out_15, status_out_14, status_out_13, status_out_12,
	 				status_out_11, status_out_10, status_out_9,  status_out_8,
	 				status_out_7,  status_out_6,  status_out_5,  status_out_4,
	 				status_out_3,  status_out_2,  status_out_1,  status_out_0;

    L4_cell C31 (.clk(clk), .etch_enb(etch_enb), .ni(1'b0), .si(xo_v[30]), .wi(wi_v[31]), .ei(ei_v[31]), 
                .rsel(rsel_v[31]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_31), .xo(xo_v[31]));
    // synthesis attribute RLOC of C31 is x0y31


    L4_cell C30 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[31]), .si(xo_v[29]), .wi(wi_v[30]), .ei(ei_v[30]), 
                .rsel(rsel_v[30]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_30), .xo(xo_v[30]));
    // synthesis attribute RLOC of C30 is x0y30

    L4_cell C29 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[30]), .si(xo_v[28]), .wi(wi_v[29]), .ei(ei_v[29]),
                .rsel(rsel_v[29]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_29), .xo(xo_v[29]));
    // synthesis attribute RLOC of C29 is x0y29

    L4_cell C28 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[29]), .si(xo_v[27]), .wi(wi_v[28]), .ei(ei_v[28]),
                .rsel(rsel_v[28]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_28), .xo(xo_v[28]));
    // synthesis attribute RLOC of C28 is x0y28


    L4_cell C27 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[28]), .si(xo_v[26]), .wi(wi_v[27]), .ei(ei_v[27]), 
                .rsel(rsel_v[27]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_27), .xo(xo_v[27]));
    // synthesis attribute RLOC of C27 is x0y27

    L4_cell C26 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[27]), .si(xo_v[25]), .wi(wi_v[26]), .ei(ei_v[26]), 
                .rsel(rsel_v[26]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_26), .xo(xo_v[26]));
    // synthesis attribute RLOC of C26 is x0y26

    L4_cell C25 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[26]), .si(xo_v[24]), .wi(wi_v[25]), .ei(ei_v[25]),
                .rsel(rsel_v[25]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_25), .xo(xo_v[25]));
    // synthesis attribute RLOC of C25 is x0y25

    L4_cell C24 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[25]), .si(xo_v[23]), .wi(wi_v[24]), .ei(ei_v[24]),
                .rsel(rsel_v[24]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_24), .xo(xo_v[24]));
    // synthesis attribute RLOC of C24 is x0y24

    L4_cell C23 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[24]), .si(xo_v[22]), .wi(wi_v[23]), .ei(ei_v[23]), 
                .rsel(rsel_v[23]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_23), .xo(xo_v[23]));
    // synthesis attribute RLOC of C23 is x0y23

    L4_cell C22 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[23]), .si(xo_v[21]), .wi(wi_v[22]), .ei(ei_v[22]), 
                .rsel(rsel_v[22]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_22), .xo(xo_v[22]));
    // synthesis attribute RLOC of C22 is x0y22

    L4_cell C21 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[22]), .si(xo_v[20]), .wi(wi_v[21]), .ei(ei_v[21]),
                .rsel(rsel_v[21]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_21), .xo(xo_v[21]));
    // synthesis attribute RLOC of C21 is x0y21

    L4_cell C20 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[21]), .si(xo_v[19]), .wi(wi_v[20]), .ei(ei_v[20]),
                .rsel(rsel_v[20]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_20), .xo(xo_v[20]));
    // synthesis attribute RLOC of C20 is x0y20

    L4_cell C19 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[20]), .si(xo_v[18]), .wi(wi_v[19]), .ei(ei_v[19]), 
                .rsel(rsel_v[19]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_19), .xo(xo_v[19]));
    // synthesis attribute RLOC of C19 is x0y19

    L4_cell C18 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[19]), .si(xo_v[17]), .wi(wi_v[18]), .ei(ei_v[18]), 
                .rsel(rsel_v[18]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_18), .xo(xo_v[18]));
    // synthesis attribute RLOC of C18 is x0y18

    L4_cell C17 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[18]), .si(xo_v[16]), .wi(wi_v[17]), .ei(ei_v[17]),
                .rsel(rsel_v[17]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_17), .xo(xo_v[17]));
    // synthesis attribute RLOC of C17 is x0y17

    L4_cell C16 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[17]), .si(xo_v[15]), .wi(wi_v[16]), .ei(ei_v[16]),
                .rsel(rsel_v[16]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_16), .xo(xo_v[16]));
    // synthesis attribute RLOC of C16 is x0y16


    L4_cell C15 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[16]), .si(xo_v[14]), .wi(wi_v[15]), .ei(ei_v[15]), 
                .rsel(rsel_v[15]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_15), .xo(xo_v[15]));
    // synthesis attribute RLOC of C15 is x0y15

    L4_cell C14 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[15]), .si(xo_v[13]), .wi(wi_v[14]), .ei(ei_v[14]), 
                .rsel(rsel_v[14]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_14), .xo(xo_v[14]));
    // synthesis attribute RLOC of C14 is x0y14

    L4_cell C13 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[14]), .si(xo_v[12]), .wi(wi_v[13]), .ei(ei_v[13]),
                .rsel(rsel_v[13]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_13), .xo(xo_v[13]));
    // synthesis attribute RLOC of C13 is x0y13

    L4_cell C12 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[13]), .si(xo_v[11]), .wi(wi_v[12]), .ei(ei_v[12]),
                .rsel(rsel_v[12]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_12), .xo(xo_v[12]));
    // synthesis attribute RLOC of C12 is x0y12


    L4_cell C11 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[12]), .si(xo_v[10]), .wi(wi_v[11]), .ei(ei_v[11]), 
                .rsel(rsel_v[11]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_11), .xo(xo_v[11]));
    // synthesis attribute RLOC of C11 is x0y11

    L4_cell C10 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[11]), .si(xo_v[9]), .wi(wi_v[10]), .ei(ei_v[10]), 
                .rsel(rsel_v[10]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_10), .xo(xo_v[10]));
    // synthesis attribute RLOC of C10 is x0y10

    L4_cell C9 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[10]), .si(xo_v[8]), .wi(wi_v[9]), .ei(ei_v[9]),
                .rsel(rsel_v[9]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_9), .xo(xo_v[9]));
    // synthesis attribute RLOC of C9 is x0y9

    L4_cell C8 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[9]), .si(xo_v[7]), .wi(wi_v[8]), .ei(ei_v[8]),
                .rsel(rsel_v[8]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_8), .xo(xo_v[8]));
    // synthesis attribute RLOC of C8 is x0y8

    L4_cell C7 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[8]), .si(xo_v[6]), .wi(wi_v[7]), .ei(ei_v[7]), 
                .rsel(rsel_v[7]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_7), .xo(xo_v[7]));
    // synthesis attribute RLOC of C7 is x0y7

    L4_cell C6 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[7]), .si(xo_v[5]), .wi(wi_v[6]), .ei(ei_v[6]), 
                .rsel(rsel_v[6]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_6), .xo(xo_v[6]));
    // synthesis attribute RLOC of C6 is x0y6

    L4_cell C5 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[6]), .si(xo_v[4]), .wi(wi_v[5]), .ei(ei_v[5]),
                .rsel(rsel_v[5]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_5), .xo(xo_v[5]));
    // synthesis attribute RLOC of C5 is x0y5

    L4_cell C4 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[5]), .si(xo_v[3]), .wi(wi_v[4]), .ei(ei_v[4]),
                .rsel(rsel_v[4]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_4), .xo(xo_v[4]));
    // synthesis attribute RLOC of C4 is x0y4

    L4_cell C3 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[4]), .si(xo_v[2]), .wi(wi_v[3]), .ei(ei_v[3]), 
                .rsel(rsel_v[3]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend), 
					 .status_out(status_out_3), .xo(xo_v[3]));
    // synthesis attribute RLOC of C3 is x0y3

    L4_cell C2 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[3]), .si(xo_v[1]), .wi(wi_v[2]), .ei(ei_v[2]), 
                .rsel(rsel_v[2]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_2), .xo(xo_v[2]));
    // synthesis attribute RLOC of C2 is x0y2

    L4_cell C1 (.clk(clk),.etch_enb(etch_enb), .ni(xo_v[2]), .si(xo_v[0]), .wi(wi_v[1]), .ei(ei_v[1]),
                .rsel(rsel_v[1]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_1), .xo(xo_v[1]));
    // synthesis attribute RLOC of C1 is x0y1

    L4_cell C0 (.clk(clk), .etch_enb(etch_enb), .ni(xo_v[1]), .si(1'b0), .wi(wi_v[0]), .ei(ei_v[0]),
                .rsel(rsel_v[0]), .csel(csel), .top_l(top_l), .pref_ud(pref_ud), .pref_ew(pref_ew), 
                .pref_ns(pref_ns), .cmd(cell_cmd), .status_in(status_in), .ret2ue(ret2ue), .extend(extend),
					 .status_out(status_out_0), .xo(xo_v[0]));
    // synthesis attribute RLOC of C0 is x0y0



    assign status_out = status_out_31 & status_out_30 & status_out_29 & status_out_28 &
	 							status_out_27 & status_out_26 & status_out_25 & status_out_24 &
	 							status_out_23 & status_out_22 & status_out_21 & status_out_20 &
	 							status_out_19 & status_out_18 & status_out_17 & status_out_16 &
								status_out_15 & status_out_14 & status_out_13 & status_out_12 &
	 							status_out_11 & status_out_10 & status_out_9  & status_out_8  &
	 							status_out_7  & status_out_6  & status_out_5  & status_out_4  &
	 							status_out_3  & status_out_2  & status_out_1  & status_out_0  ;

endmodule
