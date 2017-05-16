`include "L4_decs.v"

// main controller FSM
// Controller talks to host interface through a FIFO
// Here are the commands the controller understands
//
//    SELECT x1 y1 z1 x2 y2 (z2?) - load selection registers for decoders
//    ROUTE sx sy sz tx ty tz - find a 2-terminal connection from S (x1,y1)
//	 to T (x2,y2)
//
//    Low-level command:
//    WRITE              - apply a state value to selected cells
//    READ               - read a state value from selected cells
//                         (AND result together for multiple cells)
//    WRITE-ARRAY        - write a state into every cell in array
//    READ-ARRAY         - read state values from every cell in array
//    CLEARX             - clear ALL cells in expanded state; leave obstacles
//					  unchanged
//    EXPAND             - apply expansion until selected target reached or 
//					  failure  and return success/failure
//    BACKTRACE          - apply backtrace until source reached and return list
//					  of segment endpoints
//    GET_XCOUNT         - get cycle count of expansion
//    GET_TCOUNT         - get cycle count of backtrace
//

module L4_control(clk, resetn, etch_enb,
		  	   cmd_empty, cmd_in, cmd_rd,          //interface to command queue
		        result_full, result_out, result_wr, //interface to result queue
                  row_range_sel, row_l_v, row_u_v,    //Interface to array top
                  col_range_sel, col_l_v, col_u_v, 
                  pref_ud, pref_ns, pref_ew,
                  cell_cmd, extend, status_rd, status_wr, ret2ue,
                  cur_layer, top_l,
                  ctl_state, status_reg);   // For debugging
  
    parameter           NRBITS=4;
    parameter           NROWS=16;
    parameter           NCBITS=4;
    parameter           NCOLS=16;
    parameter           NLBITS=2;
    parameter           NLAYERS=4;

    input               clk;
    input               resetn;

	// Command Queue Interface
   input 			cmd_empty;      
   input [31:0] 	cmd_in;
   output 		cmd_rd;

	// Result Queue Interface
   input 			result_full;    
   output [31:0] 	result_out;
   output 		result_wr;
   

	// L4_top4x4 interface

	// interface with L4_decoder
   output [2:0]		row_range_sel;         
   output [NRBITS-1:0] 	row_l_v, row_u_v;	   	
   output [2:0]		col_range_sel;			     
   output [NCBITS-1:0] 	col_l_v, col_u_v;
		  
   // interface with L4_cell's in cell array
	output 			pref_ud, pref_ew, pref_ns;	   
   output                etch_enb;
   output [1:0] 		cell_cmd;
	output				extend;
   input [3:0] 		status_rd;   // status value from array
   output [3:0] 		status_wr;   // output - value to write into array
	output ret2ue;
   output 		top_l;

	// debugging signals
	output [NLBITS-1:0] 	cur_layer;	
   output [4:0] 	ctl_state;    
   output [3:0] 	status_reg;





	// Command register
   reg 			cmd_rd;
   reg 			cmdreg_lden;
   wire [31:0] 	cmdreg_out;
   
   L4_register #(32) CMDREG( .clk(clk), .resetn(resetn), .en(cmdreg_lden),
			    .d(cmd_in), .q(cmdreg_out));
   
   // Command subfields
   wire [1:0] 		cmd_opcode;
   assign 		cmd_opcode = cmdreg_out[31:30];
   wire [3:0] 		cmd_fcn;
   assign 		cmd_fcn = cmdreg_out[29:26];
   wire [3:0] 		cmd_status_in;
   assign 		cmd_status_in = cmdreg_out[3:0];
	wire		cmd_extend_continue;
	assign 		cmd_extend_continue = cmdreg_out[25];
   wire [4:0] 		cmd_x1, cmd_y1, cmd_z1, cmd_x2, cmd_y2, cmd_z2;
	wire extend_sel;
	assign extend_sel = (cmd_opcode==`C_EXTENDED && cmd_fcn==`CF_ROUTE_EXTEND);
   assign 		cmd_x1[4:0] = extend_sel ? cmdreg_out[14:10] : cmdreg_out[29:25];
   assign 		cmd_y1[4:0] = extend_sel ? cmdreg_out[9:5]   : cmdreg_out[24:20];
   assign 		cmd_z1[4:0] = extend_sel ? cmdreg_out[4:0]   : cmdreg_out[19:15];
   assign 		cmd_x2[4:0] = cmdreg_out[14:10];
   assign 		cmd_y2[4:0] = cmdreg_out[9:5];
   assign 		cmd_z2[4:0] = cmdreg_out[4:0];
 

	// output registers
   reg 			result_wr;
   reg         etch_enb;
   reg 			pref_ud;
   reg [2:0] 	row_range_sel, col_range_sel;
   reg [1:0] 	cell_cmd;

	// points p1 (x1, y1, z1)
	//    and p2 (x2, y2, z2)
   wire [NCBITS-1:0] 	x1_v, x2_v;
   wire [NRBITS-1:0] 	y1_v, y2_v;
   wire [NLBITS-1:0] 	z1_v, z2_v; //no z2_v since no parallel action between layers!
   
	// output p1 and p2's x,y coordinates to
	// upper and lower col & row select lines
	// (x1, y1) => (lower_col, lower_row)
	// (x2, y2)	=> (upper_col, upper_row)
   assign 		col_l_v = x1_v;  // x1 => lower col sel
   assign 		col_u_v = x2_v;  // x2 => upper col sel
   assign 		row_l_v = y1_v;  // y1 => lower row sel
   assign 		row_u_v = y2_v;  // y2 => upper row sel
   

	// select p1 or p2's z coordinate
	// by rotating until current layer
	// matches desired z coordinate 
	//   layer_range_start = at correct layer for p1
	//   layer_range_last = at correct layer for p2
   wire [NLBITS-1:0] 	cur_layer;
   wire 		    layer_range_start;
   assign 		layer_range_start = (cur_layer == z1_v);
   reg 			layer_range_start_d; //use since status read is delayed one
   								 // clock cycle
   always @(posedge clk)
     layer_range_start_d <=  layer_range_start;

   wire 			layer_range_last;
   assign 		layer_range_last = (cur_layer == z2_v);
   wire 			layer_range_active;
   assign 		layer_range_active = (cur_layer >= z1_v && cur_layer <= z2_v);
   



   reg 			p1_lden, p2_lden,  // load enable control signals 
				x1_incr, x1_decr,
				y1_incr, y1_decr,
				z1_incr, z1_decr,
				status_reg_lden, status_reg_setempty;
   
   reg  [1:0]		sel_status_wr;  // select which status value to WRITE to selected cells


	// fourlayer_counter
	// used for going through all (four) layers
   reg [1:0] fourlayer_counter;
   reg fourlayer_cnt_reset, fourlayer_cnt_dec;

   always @(posedge clk)begin
	 if(fourlayer_cnt_reset) fourlayer_counter = 2'b11;
	 else if(fourlayer_cnt_dec) fourlayer_counter = fourlayer_counter -1;
   end
   
	// trace_target_flag	(held in one-bit reg)
	// indicates when target is being traced and 
	// UNETCHABLE must be written instead of UNETCHED_BLOCKED
	wire trace_target_flag;
	reg trace_target_clear, trace_target_set;
	L4_onebitsr trace_target_sr(.clk(clk), .reset(trace_target_clear), 
					.set(trace_target_set), .out(trace_target_flag));



	// extend_continue:
	// Read from extended route command
	// Indicates continuation of extended routing
	//  for the next command
	// Should be high for all extended route commands
	//  except last one in a group
	wire extend_continue;
	reg extend_cont_lden;
	L4_register #(1) extend_cont_reg( .clk(clk), .resetn(resetn),
													.en(extend_cont_lden), 
													.d(cmd_extend_continue), 
													.q(extend_continue)	);
	
	// extend  (held in one-bit reg)
	//   indicates extended routing 
	//   (for more than two route endpoints)
	// extend_cont_transfer transfers extend_continue's
	//  value to extend (if we're in the extended routing state)
	wire extend, extend_reset;
	reg extend_set, extend_cont_transfer;
	assign extend_reset = (!resetn) || 
		(extend_cont_transfer && extend && !extend_continue);
	L4_onebitsr extend_sr(.clk(clk), .reset(extend_reset),
					.set(extend_set), .out(extend) );
	


   // Work with preferences more later!
   assign 		pref_ew = 1'b1;
   assign 		pref_ns = 1'b1;
   
   // layer counter
   L4_layercounter #(NLBITS, NLAYERS) LC ( .clk(clk), .resetn(resetn), .en(pref_ud), 
                                           .layer(cur_layer), .top_l(top_l) );

	
	// p1 (x1, y1, z1) held in up/down counters
	//   [this facilitates backtrace]
	// p2 (x2, y2, z2) held in registers
   L4_updown   #(NCBITS) RX1( .clk(clk), .resetn(resetn), .lden(p1_lden), 
                              .upen(x1_incr), .dnen(x1_decr),
                               .d(cmd_x1[NCBITS-1:0]), .q(x1_v) );
   
   L4_updown   #(NRBITS) RY1( .clk(clk), .resetn(resetn), .lden(p1_lden), 
                              .upen(y1_incr), .dnen(y1_decr),
                              .d(cmd_y1[NCBITS-1:0]), .q(y1_v) );
   
   L4_updown   #(NLBITS) RZ1( .clk(clk), .resetn(resetn), .lden(p1_lden), 
                              .upen(z1_incr), .dnen(z1_decr),
                              .d(cmd_z1[NLBITS-1:0]), .q(z1_v) );
   
   L4_register #(NCBITS) RX2( .clk(clk), .resetn(resetn), .en(p2_lden),
                              .d(cmd_x2[NCBITS-1:0]), .q(x2_v) );
   
   L4_register #(NRBITS) RY2( .clk(clk), .resetn(resetn), .en(p2_lden),
                              .d(cmd_y2[NCBITS-1:0]), .q(y2_v) );
  
   L4_register #(NLBITS) RZ2( .clk(clk), .resetn(resetn), .en(p2_lden),
                              .d(cmd_z2[NLBITS-1:0]), .q(z2_v) );

   // status_in_mux: selects one of several possible status values
	//                to write to selected cells in the cell array
   L4_mux4     #(4) STATUS_IN_MUX( .sel(sel_status_wr), .in0(cmd_status_in),
				   .in1(`UNETCHED_XE), .in2(`TRACED), .in3(`UNETCHED_EMPTY), .y(status_wr) );
	
	// return-to-unetchable flag:
	// set to high when writing to a cell that should
	// return to the unetchable state upon clearing
	reg ret2ue;
      
   // externally observable status register (for debugging)
   L4_status_register #(4) STATUS_REG( .clk(clk), .resetn(resetn), 
                                        .set_empty(status_reg_setempty),
                                        .lden(status_reg_lden), 
                                        .d(status_rd), .q(status_reg) );
   
   wire [7:0] 		xcount, tcount;

   // Result signal layouts
   //               3               5      5     5
   //             +----+----------+-----+-----+-----+
   //  Backtrace: |T/E |          |  x  |  y  |  z  |    
   //   and Etch  +----+----------+-----+-----+-----+
   //
   //               3                         8
   //             +----+-+----------------+---------+
   //  Other      | RC | |                | count   |
   //             +----+-+----------------|---------+

   reg [2:0] 		result_sel;

   wire [4:0] 		result_x, result_y, result_z;
   
   wire [31:0] 	result_etch, result_trace, result_success, result_xfail,
   				result_tfail, result_xcount, result_tcount, result_status;

   assign 		result_x = x1_v;  // note implict padding here so we can 
   							   // change array size, NCBITS, and NRBITS
   assign 		result_y = y1_v;
   assign 		result_z = z1_v;

   assign 		result_etch = {`RESULT_ETCH, 14'b0,  result_x, result_y, result_z};
   assign 		result_trace = { `RESULT_TRACE, 14'b0, result_x, result_y,
   						      result_z };
   assign 		result_success = { `RESULT_SUCCESS, 13'd0, xcount, tcount };
   assign 		result_xfail = { `RESULT_XFAIL, 21'd0, xcount };
   assign 		result_tfail = { `RESULT_TFAIL, 21'd0, tcount };
   assign 		result_xcount = { `RESULT_XCOUNT, 21'd0, xcount };
   assign 		result_tcount = { `RESULT_TCOUNT, 21'd0, tcount };
   assign 		result_status = { `RESULT_STATUS, 25'd0, status_rd };

   L4_mux8 #(32) RESULT_MUX ( .sel(result_sel),
			      .in0(result_etch), 
				   .in1(result_success),
			      .in2(result_xfail),
				   .in3(result_tfail), 
    			   .in4(result_trace),
			      .in5(result_xcount),
			      .in6(result_tcount),
			      .in7(result_status),
			      .y(result_out) );
   
   // logic used during backtrace
   wire 			trace_done, trace_error, trace_change, trace_etched;
   
   assign 		trace_done = ( status_rd==`TRACED );
      
   assign 		trace_error = ( (~trace_done) && 
					(
					 (status_rd[2:0] == `EMPTY) ||
					 (status_rd[2:0] == `XN && status_reg[2:0] == `XS) ||
					 (status_rd[2:0] == `XS && status_reg[2:0] == `XN) ||
					 (status_rd[2:0] == `XW && status_reg[2:0] == `XE) ||
					 (status_rd[2:0] == `XU && status_reg[2:0] == `XD) ||
					 (status_rd[2:0] == `XD && status_reg[2:0] == `XU)
					 )  		  
					);
   
   assign 		trace_change = (!trace_error) && (status_rd[2:0] != status_reg[2:0]);

	assign 		trace_etched = ( (status_rd[3] == 1) && 
										  (status_rd != `UNETCHABLE) &&
										  (status_rd != `TRACED) );

   
   // Watchdog logic - status[1] must be high for every layer in order to 
   // declare an expansion failure.  We implement this by loading a '1'
   // into a FF when top_l is asserted low at the top of the layer.
   // Then on each layer from 0 to L-1 we clear the FF if status[1] is '0'
   
   reg 			watch_hist;

   wire 			watch_hist_next, watch_fail;
   
   always @(posedge clk)
     if (!top_l) watch_hist <= 1'b1;
     else watch_hist <= watch_hist_next;
   
   assign 		watch_hist_next = watch_hist & (status_rd[1] != 0);
   
   assign 		watch_fail = watch_hist & ~top_l & (status_rd[1] != 0);

   // --------------------------------------------------------------------
   //     Cycle Counters
   // --------------------------------------------------------------------


   //reg  		cycle_reset;/////////////////////////////////////////
   reg xcount_en, tcount_en;

   
   L4_cyclecounter XCOUNTER (.clk(clk), .reset(!resetn/*cycle_reset*/), .en(xcount_en),
			      	    .count(xcount));
   
   L4_cyclecounter TCOUNTER (.clk(clk), .reset(!resetn/*cycle_reset*/), .en(tcount_en),
			              .count(tcount));
   
   // --------------------------------------------------------------------
   //     State Machine
   // --------------------------------------------------------------------
   
   parameter [4:0] 	ST_WAIT_CMD=5'd0, ST_LD_CMD=5'd1, ST_DECODE_CMD=5'd2, 
   				ST_SELECT=5'd3, ST_WRITE=5'd4, ST_WRITE2=5'd5, ST_READ=5'd6,
			     ST_READ2=5'd7, ST_CLEARX=5'd8, ST_ROUTE=5'd9, ST_ROUTE2=5'd10, 
				ST_SETSRC=5'd11, ST_EXP_INIT=5'd12, ST_EXPAND=5'd13, 
				ST_BLKSRC=5'd14, ST_TRACE=5'd15, ST_TRACE_RD=5'd16, 
				ST_TRACE_DECODE=5'd17, ST_TRACE_CHANGE=5'd18, ST_XFAIL=5'd19, 
				ST_TFAIL=5'd20, ST_SUCCESS=5'd21, ST_CLEARALL=5'd22,
				ST_CLEARALL2=5'd23, ST_KAVON=5'd24, ST_EXPAND_ETCH=5'd25,
				ST_CLEARX2=5'd26, ST_TRACE_ETCHCHECK=5'd27, ST_EMPTY_TARGET = 5'd28,
				ST_EXTEND=5'd29, ST_EXTEND2=5'd30, ST_BEGIN_EXTEND=5'd31;
      
   reg [4:0] 		cs, ns;
   
   assign 		ctl_state = cs;  // make state observable as output port
   
   always @(posedge clk) 
     if (!resetn) cs <= ST_WAIT_CMD;
     else cs <= ns;
   
   always @(cs  or status_reg or cmd_empty or cmd_in or result_full
	       or trace_error or trace_done or trace_change or layer_range_start 
		  or layer_range_last or watch_fail or cmdreg_out or top_l or status_rd 
		  or layer_range_start_d or cmd_opcode or cmd_fcn or fourlayer_counter
		  or trace_target_flag or extend or extend_continue or trace_etched)
     begin
        // default values
        row_range_sel  = `DECODE_DISABLE;
        col_range_sel  = `DECODE_DISABLE;
        p1_lden = 1'b0;
	p2_lden = 1'b0;
        x1_incr = 1'b0;
        x1_decr = 1'b0;
        y1_incr = 1'b0;
        y1_decr = 1'b0;
        z1_incr = 1'b0;
        z1_decr = 1'b0;
	cmdreg_lden = 1'b0;
        sel_status_wr = 1'b0;
		  ret2ue = 1'b0;
        status_reg_lden = 1'b0;
        status_reg_setempty = 1'b0;
        cmd_rd  = 1'b0;
        result_sel = `RESULT_ETCH;
        result_wr   = 1'b0;
        ns = ST_WAIT_CMD;
        cell_cmd = `READ;    // READ with row & col disabled == NOP
//	cycle_reset = 1'b0;
	pref_ud = 1'b0;
	xcount_en = 1'b0;
	tcount_en = 1'b0;

	etch_enb = 1'b0;
     fourlayer_cnt_reset = 1'b0;
     fourlayer_cnt_dec = 1'b0; 
	
			trace_target_clear = 0; trace_target_set = 0;
			extend_cont_lden = 0;
			extend_set = 0;
			extend_cont_transfer = 0;

        case (cs)
          ST_WAIT_CMD:
            begin
               if (cmd_empty) ns = ST_WAIT_CMD; //spin while waiting for new command
               else 
					  begin
                   cmd_rd = 1'b1;  // FIFO provides cmd result AFTER clock edge!
					    ns = ST_LD_CMD;
                 end
            end
          ST_LD_CMD:
            begin
              cmdreg_lden = 1'b1; // load command register with cmd read from FIFO last cycle
              ns = ST_DECODE_CMD;
            end
	  ST_DECODE_CMD:
	    case (cmd_opcode)
	      `C_NOP:
		if (cmd_empty) ns = ST_WAIT_CMD;
		else ns = ST_LD_CMD;
	      `C_ROUTE:
		ns = ST_ROUTE;
	      `C_SELECT: ns = ST_SELECT;
	      `C_EXTENDED:
		case (cmd_fcn)
		  `CF_WRITE:begin
		     ns = ST_WRITE;
			row_range_sel = `DECODE_RANGE;
			col_range_sel = `DECODE_RANGE;
			end
		  `CF_READ:begin
		       ns = ST_READ;
			  row_range_sel = `DECODE_LOWER;
			  col_range_sel = `DECODE_LOWER;
              end
		  `CF_CLEAR_ARRAY: ns =  ST_CLEARALL;//ST_ROUTE; //ST_CLEARALL;
		  `CF_CLEARX:  ns = ST_CLEARX;
		  `CF_ROUTE_EXTEND:	ns = ST_EXTEND;
		  default:    ns = ST_WAIT_CMD;
		endcase
	    endcase

	  ST_SELECT:
	     begin
		p1_lden = 1;
		p2_lden = 1;
		ns = ST_WAIT_CMD;
	     end
	  ST_WRITE:
	     begin
		pref_ud = 1'b1;
		row_range_sel = `DECODE_RANGE;
		col_range_sel = `DECODE_RANGE;
		sel_status_wr = 2'd0;  // from command reg
		if (layer_range_start)
		   begin
		      cell_cmd = `WRITE;
		      if (layer_range_last) ns = ST_WAIT_CMD;
		      else ns = ST_WRITE2;  // do the whole range!
		   end
		else
		   begin
		      cell_cmd = `READ;  // use READ as no-op
		      ns = ST_WRITE;     // spin till on the proper level
		   end
	     end
	  ST_WRITE2:
	     begin                   // write the remaining selected layers
		pref_ud = 1'b1;
		row_range_sel = `DECODE_RANGE;
		col_range_sel = `DECODE_RANGE;
		sel_status_wr = 2'd0;   // from command
		cell_cmd = `WRITE;
		if (layer_range_last) ns = ST_WAIT_CMD;
		else ns = ST_WRITE2;
	     end
	  ST_READ:
	     begin
		row_range_sel = `DECODE_LOWER;
		col_range_sel = `DECODE_LOWER;
		if (!layer_range_start) begin
			pref_ud = 1;
			ns = ST_READ;
		end
		else if(result_full) begin
			ns = ST_READ;
		end
		else begin
			ns = ST_READ2;
		end
			end
	  ST_READ2:
	     begin
		row_range_sel = `DECODE_LOWER;
		col_range_sel = `DECODE_LOWER;
		cell_cmd = `READ;
		result_sel = `RESULT_STATUS;
		result_wr = 1;  		      // return status value
		ns = ST_WAIT_CMD;
	     end

	  ST_CLEARX:
	   begin
			fourlayer_cnt_reset = 1;
			ns = ST_CLEARX2;
	  	end

	  ST_CLEARX2:
	   begin
		  pref_ud = 1'b1;
		  cell_cmd = `CLEARX;
		  if(fourlayer_counter == 0) begin
		  	ns = ST_WAIT_CMD;
        end
		  else
		   begin
		   	ns = ST_CLEARX2;
				fourlayer_cnt_dec = 1;
         end
      end

	 	// have to load p1 before
		// setting row & col select lines for decoder
		// since L4_decoder is latched
	  ST_EXTEND:
	  begin
			p1_lden = 1;
			extend_cont_lden = 1;
			ns = ST_EXTEND2;
	  end
	  ST_EXTEND2:
	  	begin
			row_range_sel = `DECODE_LOWER;	// select p1
			col_range_sel = `DECODE_LOWER;
			extend_set = 1;			
			// go to ST_BEGIN_EXTEND if this is the first extend cmd
			// otherwise, go to ST_EMPTY_TARGET to proceed with expansion
			ns = extend ? ST_EMPTY_TARGET : ST_BEGIN_EXTEND;
		end

		// ST_BEGIN_EXTEND:
		// for first point in extended route
		//   just set given cell to `TRACED and
		//   go back to ST_WAIT_CMD
	  ST_BEGIN_EXTEND:
	   begin
			row_range_sel = `DECODE_LOWER;
			col_range_sel = `DECODE_LOWER;
			if(layer_range_start)
				begin
					sel_status_wr = 2; //selects `TRACED
					ret2ue = 1; // endpoint - return to unetchable state
									//  after routing
					cell_cmd = `WRITE;
					ns = ST_WAIT_CMD;
				end
			else
			 begin
				pref_ud = 1;
				ns = ST_BEGIN_EXTEND;
			 end
		end


	  ST_ROUTE:
	    begin
	       p1_lden = 1;
	       p2_lden = 1;
	       ns = ST_ROUTE2;
	     end
	  ST_ROUTE2:
	     begin
		pref_ud = 1'b1;
		row_range_sel = `DECODE_UPPER;   // prime the decoder for the next 
								   // state since it's registered
		col_range_sel = `DECODE_UPPER;   // can't do this in previous cycle
								   // because p2 not loaded yet
		if (top_l == 0) ns = ST_SETSRC;
		else ns = ST_ROUTE2;
	     end
	  ST_SETSRC:
	     begin
		pref_ud = 1'b1;
		row_range_sel = `DECODE_UPPER; // continue to select source
		col_range_sel = `DECODE_UPPER;
		if (layer_range_last)
		  begin
		      sel_status_wr = 1;  // selects `UNETCHED_XE
		      cell_cmd = `WRITE;
				row_range_sel = `DECODE_LOWER;  // select target for next state
				col_range_sel = `DECODE_LOWER;
		      ns = ST_EMPTY_TARGET;
		   end
		else
		  begin
		     ns = ST_SETSRC;
		  end
	     end
	  

	  ST_EMPTY_TARGET:
	  		begin
				row_range_sel = `DECODE_LOWER;
				col_range_sel = `DECODE_LOWER;
				pref_ud = 1;
				if(layer_range_start)
					begin
						sel_status_wr = 3; // selects `UNETCHED_EMPTY
						cell_cmd = `WRITE;
						ns = ST_EXP_INIT;
						if(top_l == 0) ns = ST_EXPAND;
						else ns = ST_EXP_INIT;
 					end
				else ns = ST_EMPTY_TARGET;
			end


	  ST_EXP_INIT:
	     begin
		  	xcount_en = 1;
			pref_ud = 1'b1;
			row_range_sel = `DECODE_LOWER; // select target for next expansion step
			col_range_sel = `DECODE_LOWER;
			
			if (top_l == 1'b0) ns = ST_EXPAND;  // wait until top layer so expansion 
									 						// starts in Layer 0
			else ns = ST_EXP_INIT;
	     end
	  ST_EXPAND:
	    begin
		 	 xcount_en = 1;
	       pref_ud = 1'b1;
	       row_range_sel = `DECODE_LOWER;    // select target for next expansion step
	       col_range_sel = `DECODE_LOWER;    // note current status was from last layer
	       cell_cmd = `EXPAND;
	       if (layer_range_start_d && (status_rd[0] == 1'b0))
		 begin
		 	 if(extend) begin
			 	status_reg_setempty = 1'b1;
			 	trace_target_set = 1;
			 	ns = ST_TRACE;
			 end
			 else begin
		    	row_range_sel = `DECODE_UPPER; // continue src for next cycle
		    	col_range_sel = `DECODE_UPPER;
		    	ns = ST_BLKSRC;   // found it!
          end
		 end
	       else if (watch_fail)begin
		  	ns = ST_EXPAND_ETCH;
			fourlayer_cnt_reset = 1'b1;
		   end 
	       else ns = ST_EXPAND;                       // otherwise keep on truckin'
	    end

	   ST_EXPAND_ETCH:
	    begin
		 	xcount_en = 1;
	       pref_ud = 1'b1;
		  fourlayer_cnt_dec	= 1'b1; 
		  etch_enb = 1'b1;
	       row_range_sel = `DECODE_LOWER;    // select target for next expansion step
	       col_range_sel = `DECODE_LOWER;    // note current status was from last layer
	       cell_cmd = `EXPAND;
	       if (layer_range_start_d && (status_rd[0] == 1'b0))
		 begin
		 	 if(extend) begin
			 	status_reg_setempty = 1'b1;
			 	trace_target_set = 1;
			 	ns = ST_TRACE;
			 end
			 else begin
		    	row_range_sel = `DECODE_UPPER; // continue src for next cycle
		    	col_range_sel = `DECODE_UPPER;
		    	ns = ST_BLKSRC;   // found it!
			 end
		 end
	       else if (watch_fail)begin
		   ns = ST_XFAIL;        // search failed
		   fourlayer_cnt_reset = 1'b1;
		   end
	       else if(fourlayer_counter==2'b00) ns = ST_EXPAND;
		  else ns = ST_EXPAND_ETCH;                       // otherwise keep on truckin'
	    end
	  
	  ST_XFAIL:
	     begin
		extend_cont_transfer = 1;
		result_sel = `RESULT_XFAIL;
		result_wr = 1'b1;
	     ns = ST_WAIT_CMD;
	     end
 	  ST_BLKSRC:     // start backtrace by setting the src to the unetchable state
	     begin       // assumes src was selected in previous cycle, too!
		pref_ud = 1'b1;
		row_range_sel = `DECODE_UPPER; // continue to select source
		col_range_sel = `DECODE_UPPER;
		if (layer_range_last)
		  begin
		     if (layer_range_start) pref_ud = 1'b0;
		      sel_status_wr = 2;  // selects `TRACED
				ret2ue = 1;
		      cell_cmd = `WRITE;
			   status_reg_setempty = 1'b1;
			  	row_range_sel = `DECODE_LOWER;
	         col_range_sel = `DECODE_LOWER;
				trace_target_set = 1;
	         ns = ST_TRACE;
		   end
		else
		  begin
		     ns = ST_BLKSRC;
		  end
	     end

	  ST_TRACE:
	    begin
	       tcount_en = 1'b1;
	       cell_cmd = `READ;
	       row_range_sel = `DECODE_LOWER;
	       col_range_sel = `DECODE_LOWER;
	       if (layer_range_start)
		 begin
		    pref_ud = 1'b0;  // got hold still for next step
		    ns = ST_TRACE_ETCHCHECK;
		  end
	       else
		 begin
		    pref_ud = 1'b1;  // wait for layer to come around
		    ns = ST_TRACE;
		 end
	    end


	  // check if currently traced cell has been etched over
	  //  and if it is write RESULT_ETCH
	  ST_TRACE_ETCHCHECK:
	  	begin
			tcount_en = 1'b1;
			cell_cmd = `READ;
			row_range_sel = `DECODE_LOWER;
			col_range_sel = `DECODE_LOWER;
			ns = ST_TRACE_RD;
			if(trace_etched) //etched over
			  begin
			   if(result_full)
				  ns = ST_TRACE_ETCHCHECK;
				else		  // write etch result
				  begin
			 		result_sel = `RESULT_ETCH;
			 		result_wr = 1;
			 	  end
			  end   
		end
	
	  ST_TRACE_RD:
	  // + write RESULT_TRACE at endpoints and turning points
	  //   (indicated by trace_change and trace_done)
	  // + go to ST_SUCCESS if trace is done,
	  //         ST_TFAIL if trace has failed
	  // + advance p1 in the direction indicated by the cell status
	    begin
	       tcount_en = 1'b1;
			row_range_sel = `DECODE_LOWER;
			col_range_sel = `DECODE_LOWER;
	       status_reg_lden = 1'b1;
	       if (trace_error) ns = ST_TFAIL;

			  // if we have to write RESULT_TRACE,
			  //   wait until the result queue is ready before continuing
	       else if ((trace_change || trace_done) && result_full)
			   begin
				 cell_cmd = `READ;
				 ns = ST_TRACE_RD;
				end

          else
				 begin
				 	if(trace_change || trace_done) begin
						result_sel = `RESULT_TRACE;
		      		result_wr = 1'b1;
      		 	end

					if(trace_done) begin
					 	ns = ST_SUCCESS;
               end

					else begin
			 		 ns = ST_TRACE_DECODE;
					 cell_cmd = `WRITE;
					
						sel_status_wr = 2; // select TRACED
						ret2ue = trace_target_flag; // return target to unetchable after
															 // routing is done		
					 	trace_target_clear = 1;	// next cell traced won't be target

	 			    case (status_rd[2:0]) 
						`XN: y1_incr = 1'b1;
						`XS: y1_decr = 1'b1;
						`XE: x1_incr = 1'b1;
						`XW: x1_decr = 1'b1;
						`XU: begin 
							z1_incr = 1'b1;
				  			pref_ud = 1'b1;
				 		end
						`XD: begin
						    	z1_decr = 1'b1;
				    			pref_ud = 1'b1;
				    		end

		      		default: ;  // shouldn't happen since this will be covered by
					  					// trace_error
		  			endcase
				  end
 				end
	    end

	  ST_TRACE_DECODE:
	  // wait for one cycle
	  // (backtrace won't work if this state is removed)
	     begin
		tcount_en = 1'b1;
		row_range_sel = `DECODE_LOWER;
		col_range_sel = `DECODE_LOWER;
		if (!layer_range_start) pref_ud = 1'b1;  // go ahead and shift layers if
										 // we need to
		ns = ST_TRACE;
	     end

	  ST_TFAIL:
	     begin
		extend_cont_transfer = 1;
		result_sel = `RESULT_TFAIL;
		result_wr = 1'b1;
		ns = ST_WAIT_CMD;
	     end
	  ST_SUCCESS:
	     begin
		extend_cont_transfer = 1;
		result_sel = `RESULT_SUCCESS;
		result_wr = 1'b1;
		ns = ST_CLEARX;
	     end
	  ST_CLEARALL:
	    begin
	       pref_ud = 1'b1;
	       row_range_sel = `DECODE_ALL;
	       col_range_sel = `DECODE_ALL;
	       if (top_l != 0)  ns = ST_CLEARALL;
	       else ns = ST_CLEARALL2;
	     end
	  ST_CLEARALL2:
	     begin
		pref_ud = 1'b1;
		row_range_sel = `DECODE_ALL;
		col_range_sel = `DECODE_ALL;
		sel_status_wr = 2'd3;  // selects `EMPTY
		cell_cmd = `WRITE;
		if (top_l != 0) ns = ST_CLEARALL2;
		else ns = ST_WAIT_CMD;
	     end
          default:
            ns = ST_WAIT_CMD; // just in case
        endcase
     end // always
endmodule



