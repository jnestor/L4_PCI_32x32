`include "L4_decs.v"

module L4_bench32x32(clk, ctl_state, status_reg, cur_layer);
   output       clk;
   reg          clk;
   output [5:0] ctl_state;
   output [3:0] status_reg;
	output [1:0] cur_layer;
   
   reg          resetn;
   reg          cmd_empty;
   reg [31:0] 	cmd_in;
   wire 	cmd_rd;
   reg 		result_full;
   wire [31:0] 	result_out;
   wire 	result_wr;
   
   L4_all32x32 DUV(.clk(clk), .resetn(resetn), .cmd_empty(cmd_empty), 
                 .cmd_in(cmd_in), .cmd_rd(cmd_rd), .result_full(result_full), 
                 .result_out(result_out), .result_wr(result_wr), .ctl_state(ctl_state), .status_reg(status_reg), .cur_layer(cur_layer));  
   always
     begin : CLKOSC
	clk = 1'b0; #10;
	clk = 1'b1; #10;
     end
    
   task init;
      begin
	 resetn = 1'b1;
	 cmd_empty = 1'b1;
	 cmd_in = 32'd0;
	 result_full = 1'b0;
      end
   endtask // init

   task reset;
      begin
	 @(posedge clk) # 1;
	 resetn = 1'b0;
	 @(posedge clk) # 1;
	 resetn = 1'b1;
	 cmd_in = { `C_EXTENDED , `CF_CLEAR_ARRAY, `C_EXTEND_FILL };
//	 $display("%t reset: cmd_in=%h",$time, cmd_in);
	 cmd_empty = 1'b0;
	 @(posedge clk) # 1;
	 cmd_empty = 1'b1;
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask // reset

   task clearx;
		begin
	 cmd_in = { `C_EXTENDED , `CF_CLEARX, `C_EXTEND_FILL};
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask 
   
   task select;
      input [4:0] x1, y1, z1, x2, y2, z2;
      begin
	 cmd_in = { `C_SELECT , x1, y1, z1, x2, y2, z2 };
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask // select
   
	task read_cell;
		input [4:0] x, y, z;
		begin
			select(x,y,z,x,y,z);
			cmd_in = {`C_EXTENDED, `CF_READ, `C_EXTEND_FILL};
    		cmd_empty = 1'b0;
	 		@(posedge clk) #1;
	 		cmd_empty = 1'b1;
	 		while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   	@(posedge clk) #1;     // wait for it to finish up!
      end
	endtask

	task write_cell;
		input [4:0] x, y, z;
		input [3:0] cs;
		begin
			select(x,y,z,x,y,z);
			cmd_in = {`C_EXTENDED, `CF_WRITE, `C_WRITE_FILL, cs};
    		cmd_empty = 1'b0;
	 		@(posedge clk) #1;
	 		cmd_empty = 1'b1;
	 		while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   	@(posedge clk) #1;     // wait for it to finish up!
      end
	endtask


   task route;
      input [4:0] x1, y1, z1, x2, y2, z2;
      begin
	 cmd_in = { `C_ROUTE , x1, y1, z1, x2, y2, z2 };
	 $display("%t route: cmd_in=%h",$time, cmd_in);
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask // route



   task route_extend_init;
      input [4:0] x1, y1, z1, x2, y2, z2;
      begin
	 cmd_in = { `C_ROUTE_EXTEND_INIT , x1, y1, z1, x2, y2, z2 };
	 $display("%t route: cmd_in=%h",$time, cmd_in);
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask

    task get_xcount;
	  begin
	    cmd_in = {`C_EXTENDED, `CF_GET_XCOUNT, 26'd0 };
	 $display("%t get_xcount: cmd_in=%h",$time, cmd_in);
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;	
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask // get_xcount

	task get_tcount;
	  begin
	    cmd_in = {`C_EXTENDED, `CF_GET_TCOUNT, 26'd0 };
	 $display("%t get_tcount: cmd_in=%h",$time, cmd_in);
	 cmd_empty = 1'b0;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;
	 @(posedge clk) #1;
	 cmd_empty = 1'b1;	
	 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   @(posedge clk) #1;     // wait for it to finish up!
      end
   endtask // get_tcount
	
		
	task set_unetchable;
		input [4:0] x, y, z;
		begin
			cmd_in = {`C_SELECT, x,y,z, x,y,z};
			cmd_empty = 0;
			@(posedge clk) #1;
			cmd_empty = 1;
			while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   		@(posedge clk) #1;     // wait for it to finish up!

			cmd_in = {`C_EXTENDED, `CF_WRITE, 22'd0, `UNETCHABLE};   
			cmd_empty = 0;
			@(posedge clk) #1;
			cmd_empty = 1;

			while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   		@(posedge clk) #1;     // wait for it to finish up!
       end
	endtask

   task command;
      input [7:0] cmdval;
      
      begin
	 cmd_empty = 1'b1;
      end
   endtask // command
  
   
	task route_extended;
		input [4:0] x, y, z;
		input continue;
		begin
		 $display("ROUTE EXTENDED: x=%d y=%d z=%d   continue=%b", x, y, z, continue);
		 cmd_in = {`C_EXTENDED, `CF_ROUTE_EXTEND, continue, 10'b0, x,y,z};
		 cmd_empty = 0;
		 @(posedge clk) #1;
		 cmd_empty = 1;
		 while (DUV.CONTROL.cs != DUV.CONTROL.ST_WAIT_CMD)
	   	@(posedge clk) #1;     // wait for it to finish up!
      end
	endtask


   
   function [7:0] state2pr;
      input [3:0] state;
		begin
      case(state[2:0])
		`EMPTY : state2pr = "_";
		`BLOCKED : state2pr = "X";
		`XE : state2pr = ">";
		`XW : state2pr = "<";
		`XN : state2pr = "^";
		`XS : state2pr = "v";
		`XU : state2pr = "u";
		`XD : state2pr = "d";
		default : state2pr = "?";
      endcase // case(state)
		if(state == `UNETCHABLE)
			state2pr = "#";
		if(state == `TRACED)
			state2pr = "T";
      end
   endfunction // state2pr


	always@(posedge clk)
		if(DUV.cell_cmd==`WRITE)
			$display("writing cell: ret2ue=%b", DUV.ret2ue);


	wire [2:0] result_type;
	wire [4:0] result_x, result_y, result_z;
	wire [13:0] result_count1, result_count2;	// size modified 3/6/06 JN
	wire [3:0] result_status;
	assign result_type = result_out[31:29];
	assign result_x = result_out[14:10];
	assign result_y = result_out[9:5];
	assign result_z =	result_out[4:0];
	assign result_count1 = result_out[27:14];
	assign result_count2 = result_out[13:0];
	assign result_status = result_out[3:0];



	always @(posedge clk)
	  if(result_wr)
		 case(result_type)
		   `RESULT_ETCH: $display("RESULT_ETCH: x=%d y=%d z=%d", result_x, result_y, result_z);
			`RESULT_SUCCESS: $display("RESULT_SUCCESS: xcount=%d tcount=%d", result_count1, result_count2);
			`RESULT_XFAIL: $display("RESULT_XFAIL: xcount=%d", result_count2);
			`RESULT_TFAIL: $display("RESULT_TFAIL: tcount=%d", result_count2);
			`RESULT_TRACE: $display("RESULT_TRACE: x=%d y=%d z=%d", result_x, result_y, result_z);
			`RESULT_XCOUNT: $display("RESULT_XCOUNT: xcount=%d", result_count2);
			`RESULT_TCOUNT: $display("RESULT_TCOUNT: tcount=%d", result_count2);
			`RESULT_STATUS: $display("RESULT_STATUS: status=%b", result_status);
			default: $display("RESULT UNRECOGNIZED");
		 endcase
		


   // state snooper
   always @(posedge clk)
     begin
	# 1;
	$display("----- time=%5t ----- L=%1d -----", $time, DUV.CONTROL.cur_layer);
	/*	$display("-- row_en=%d row_l=%d row_h=%d rsel=%b col_en=%d, col_l=%d col_h=%d csel=%b --",
	 DUV.TOP.row_en, DUV.TOP.row_l_v, DUV.TOP.row_u_v, DUV.TOP.ARRAY.rsel_v,
	 DUV.TOP.col_en, DUV.TOP.col_l_v, DUV.TOP.col_u_v, DUV.TOP.csel_v,
	 
	 );
	 $display("row decoder: en=%d lower=%d upper=%d out=%b",
	 DUV.TOP.RDEC.enable, DUV.TOP.RDEC.lower, DUV.TOP.RDEC.upper, DUV.TOP.RDEC.decout); */	
	$display("S %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
		DUV.TOP.ARRAY.csel_v[0], DUV.TOP.ARRAY.csel_v[1],
		DUV.TOP.ARRAY.csel_v[2], DUV.TOP.ARRAY.csel_v[3],
		DUV.TOP.ARRAY.csel_v[4], DUV.TOP.ARRAY.csel_v[5],
		DUV.TOP.ARRAY.csel_v[6], DUV.TOP.ARRAY.csel_v[7],
		DUV.TOP.ARRAY.csel_v[8], DUV.TOP.ARRAY.csel_v[9],
		DUV.TOP.ARRAY.csel_v[10], DUV.TOP.ARRAY.csel_v[11],
		DUV.TOP.ARRAY.csel_v[12], DUV.TOP.ARRAY.csel_v[13],
		DUV.TOP.ARRAY.csel_v[14], DUV.TOP.ARRAY.csel_v[15],
		DUV.TOP.ARRAY.csel_v[16], DUV.TOP.ARRAY.csel_v[17],
		DUV.TOP.ARRAY.csel_v[18], DUV.TOP.ARRAY.csel_v[19],
		DUV.TOP.ARRAY.csel_v[20], DUV.TOP.ARRAY.csel_v[21],
		DUV.TOP.ARRAY.csel_v[22], DUV.TOP.ARRAY.csel_v[23],
		DUV.TOP.ARRAY.csel_v[24], DUV.TOP.ARRAY.csel_v[25],
		DUV.TOP.ARRAY.csel_v[26], DUV.TOP.ARRAY.csel_v[27],
		DUV.TOP.ARRAY.csel_v[28], DUV.TOP.ARRAY.csel_v[29],
		DUV.TOP.ARRAY.csel_v[30], DUV.TOP.ARRAY.csel_v[31]);
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[31], 
		 state2pr(DUV.TOP.ARRAY.COL0.C31.cs), state2pr(DUV.TOP.ARRAY.COL1.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C31.cs), state2pr(DUV.TOP.ARRAY.COL3.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C31.cs), state2pr(DUV.TOP.ARRAY.COL5.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C31.cs), state2pr(DUV.TOP.ARRAY.COL7.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C31.cs), state2pr(DUV.TOP.ARRAY.COL9.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C31.cs), state2pr(DUV.TOP.ARRAY.COL11.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C31.cs), state2pr(DUV.TOP.ARRAY.COL13.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C31.cs), state2pr(DUV.TOP.ARRAY.COL15.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C31.cs), state2pr(DUV.TOP.ARRAY.COL17.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C31.cs), state2pr(DUV.TOP.ARRAY.COL19.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C31.cs), state2pr(DUV.TOP.ARRAY.COL21.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C31.cs), state2pr(DUV.TOP.ARRAY.COL23.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C31.cs), state2pr(DUV.TOP.ARRAY.COL25.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C31.cs), state2pr(DUV.TOP.ARRAY.COL27.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C31.cs), state2pr(DUV.TOP.ARRAY.COL29.C31.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C31.cs), state2pr(DUV.TOP.ARRAY.COL31.C31.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[30], 
		 state2pr(DUV.TOP.ARRAY.COL0.C30.cs), state2pr(DUV.TOP.ARRAY.COL1.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C30.cs), state2pr(DUV.TOP.ARRAY.COL3.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C30.cs), state2pr(DUV.TOP.ARRAY.COL5.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C30.cs), state2pr(DUV.TOP.ARRAY.COL7.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C30.cs), state2pr(DUV.TOP.ARRAY.COL9.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C30.cs), state2pr(DUV.TOP.ARRAY.COL11.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C30.cs), state2pr(DUV.TOP.ARRAY.COL13.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C30.cs), state2pr(DUV.TOP.ARRAY.COL15.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C30.cs), state2pr(DUV.TOP.ARRAY.COL17.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C30.cs), state2pr(DUV.TOP.ARRAY.COL19.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C30.cs), state2pr(DUV.TOP.ARRAY.COL21.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C30.cs), state2pr(DUV.TOP.ARRAY.COL23.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C30.cs), state2pr(DUV.TOP.ARRAY.COL25.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C30.cs), state2pr(DUV.TOP.ARRAY.COL27.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C30.cs), state2pr(DUV.TOP.ARRAY.COL29.C30.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C30.cs), state2pr(DUV.TOP.ARRAY.COL31.C30.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[29], 
		 state2pr(DUV.TOP.ARRAY.COL0.C29.cs), state2pr(DUV.TOP.ARRAY.COL1.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C29.cs), state2pr(DUV.TOP.ARRAY.COL3.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C29.cs), state2pr(DUV.TOP.ARRAY.COL5.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C29.cs), state2pr(DUV.TOP.ARRAY.COL7.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C29.cs), state2pr(DUV.TOP.ARRAY.COL9.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C29.cs), state2pr(DUV.TOP.ARRAY.COL11.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C29.cs), state2pr(DUV.TOP.ARRAY.COL13.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C29.cs), state2pr(DUV.TOP.ARRAY.COL15.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C29.cs), state2pr(DUV.TOP.ARRAY.COL17.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C29.cs), state2pr(DUV.TOP.ARRAY.COL19.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C29.cs), state2pr(DUV.TOP.ARRAY.COL21.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C29.cs), state2pr(DUV.TOP.ARRAY.COL23.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C29.cs), state2pr(DUV.TOP.ARRAY.COL25.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C29.cs), state2pr(DUV.TOP.ARRAY.COL27.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C29.cs), state2pr(DUV.TOP.ARRAY.COL29.C29.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C29.cs), state2pr(DUV.TOP.ARRAY.COL31.C29.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[28], 
		 state2pr(DUV.TOP.ARRAY.COL0.C28.cs), state2pr(DUV.TOP.ARRAY.COL1.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C28.cs), state2pr(DUV.TOP.ARRAY.COL3.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C28.cs), state2pr(DUV.TOP.ARRAY.COL5.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C28.cs), state2pr(DUV.TOP.ARRAY.COL7.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C28.cs), state2pr(DUV.TOP.ARRAY.COL9.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C28.cs), state2pr(DUV.TOP.ARRAY.COL11.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C28.cs), state2pr(DUV.TOP.ARRAY.COL13.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C28.cs), state2pr(DUV.TOP.ARRAY.COL15.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C28.cs), state2pr(DUV.TOP.ARRAY.COL17.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C28.cs), state2pr(DUV.TOP.ARRAY.COL19.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C28.cs), state2pr(DUV.TOP.ARRAY.COL21.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C28.cs), state2pr(DUV.TOP.ARRAY.COL23.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C28.cs), state2pr(DUV.TOP.ARRAY.COL25.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C28.cs), state2pr(DUV.TOP.ARRAY.COL27.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C28.cs), state2pr(DUV.TOP.ARRAY.COL29.C28.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C28.cs), state2pr(DUV.TOP.ARRAY.COL31.C28.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[27], 
		 state2pr(DUV.TOP.ARRAY.COL0.C27.cs), state2pr(DUV.TOP.ARRAY.COL1.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C27.cs), state2pr(DUV.TOP.ARRAY.COL3.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C27.cs), state2pr(DUV.TOP.ARRAY.COL5.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C27.cs), state2pr(DUV.TOP.ARRAY.COL7.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C27.cs), state2pr(DUV.TOP.ARRAY.COL9.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C27.cs), state2pr(DUV.TOP.ARRAY.COL11.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C27.cs), state2pr(DUV.TOP.ARRAY.COL13.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C27.cs), state2pr(DUV.TOP.ARRAY.COL15.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C27.cs), state2pr(DUV.TOP.ARRAY.COL17.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C27.cs), state2pr(DUV.TOP.ARRAY.COL19.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C27.cs), state2pr(DUV.TOP.ARRAY.COL21.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C27.cs), state2pr(DUV.TOP.ARRAY.COL23.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C27.cs), state2pr(DUV.TOP.ARRAY.COL25.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C27.cs), state2pr(DUV.TOP.ARRAY.COL27.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C27.cs), state2pr(DUV.TOP.ARRAY.COL29.C27.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C27.cs), state2pr(DUV.TOP.ARRAY.COL31.C27.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[26], 
		 state2pr(DUV.TOP.ARRAY.COL0.C26.cs), state2pr(DUV.TOP.ARRAY.COL1.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C26.cs), state2pr(DUV.TOP.ARRAY.COL3.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C26.cs), state2pr(DUV.TOP.ARRAY.COL5.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C26.cs), state2pr(DUV.TOP.ARRAY.COL7.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C26.cs), state2pr(DUV.TOP.ARRAY.COL9.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C26.cs), state2pr(DUV.TOP.ARRAY.COL11.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C26.cs), state2pr(DUV.TOP.ARRAY.COL13.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C26.cs), state2pr(DUV.TOP.ARRAY.COL15.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C26.cs), state2pr(DUV.TOP.ARRAY.COL17.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C26.cs), state2pr(DUV.TOP.ARRAY.COL19.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C26.cs), state2pr(DUV.TOP.ARRAY.COL21.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C26.cs), state2pr(DUV.TOP.ARRAY.COL23.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C26.cs), state2pr(DUV.TOP.ARRAY.COL25.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C26.cs), state2pr(DUV.TOP.ARRAY.COL27.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C26.cs), state2pr(DUV.TOP.ARRAY.COL29.C26.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C26.cs), state2pr(DUV.TOP.ARRAY.COL31.C26.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[25], 
		 state2pr(DUV.TOP.ARRAY.COL0.C25.cs), state2pr(DUV.TOP.ARRAY.COL1.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C25.cs), state2pr(DUV.TOP.ARRAY.COL3.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C25.cs), state2pr(DUV.TOP.ARRAY.COL5.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C25.cs), state2pr(DUV.TOP.ARRAY.COL7.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C25.cs), state2pr(DUV.TOP.ARRAY.COL9.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C25.cs), state2pr(DUV.TOP.ARRAY.COL11.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C25.cs), state2pr(DUV.TOP.ARRAY.COL13.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C25.cs), state2pr(DUV.TOP.ARRAY.COL15.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C25.cs), state2pr(DUV.TOP.ARRAY.COL17.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C25.cs), state2pr(DUV.TOP.ARRAY.COL19.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C25.cs), state2pr(DUV.TOP.ARRAY.COL21.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C25.cs), state2pr(DUV.TOP.ARRAY.COL23.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C25.cs), state2pr(DUV.TOP.ARRAY.COL25.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C25.cs), state2pr(DUV.TOP.ARRAY.COL27.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C25.cs), state2pr(DUV.TOP.ARRAY.COL29.C25.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C25.cs), state2pr(DUV.TOP.ARRAY.COL31.C25.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[24], 
		 state2pr(DUV.TOP.ARRAY.COL0.C24.cs), state2pr(DUV.TOP.ARRAY.COL1.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C24.cs), state2pr(DUV.TOP.ARRAY.COL3.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C24.cs), state2pr(DUV.TOP.ARRAY.COL5.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C24.cs), state2pr(DUV.TOP.ARRAY.COL7.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C24.cs), state2pr(DUV.TOP.ARRAY.COL9.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C24.cs), state2pr(DUV.TOP.ARRAY.COL11.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C24.cs), state2pr(DUV.TOP.ARRAY.COL13.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C24.cs), state2pr(DUV.TOP.ARRAY.COL15.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C24.cs), state2pr(DUV.TOP.ARRAY.COL17.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C24.cs), state2pr(DUV.TOP.ARRAY.COL19.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C24.cs), state2pr(DUV.TOP.ARRAY.COL21.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C24.cs), state2pr(DUV.TOP.ARRAY.COL23.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C24.cs), state2pr(DUV.TOP.ARRAY.COL25.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C24.cs), state2pr(DUV.TOP.ARRAY.COL27.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C24.cs), state2pr(DUV.TOP.ARRAY.COL29.C24.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C24.cs), state2pr(DUV.TOP.ARRAY.COL31.C24.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[23], 
		 state2pr(DUV.TOP.ARRAY.COL0.C23.cs), state2pr(DUV.TOP.ARRAY.COL1.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C23.cs), state2pr(DUV.TOP.ARRAY.COL3.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C23.cs), state2pr(DUV.TOP.ARRAY.COL5.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C23.cs), state2pr(DUV.TOP.ARRAY.COL7.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C23.cs), state2pr(DUV.TOP.ARRAY.COL9.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C23.cs), state2pr(DUV.TOP.ARRAY.COL11.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C23.cs), state2pr(DUV.TOP.ARRAY.COL13.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C23.cs), state2pr(DUV.TOP.ARRAY.COL15.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C23.cs), state2pr(DUV.TOP.ARRAY.COL17.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C23.cs), state2pr(DUV.TOP.ARRAY.COL19.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C23.cs), state2pr(DUV.TOP.ARRAY.COL21.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C23.cs), state2pr(DUV.TOP.ARRAY.COL23.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C23.cs), state2pr(DUV.TOP.ARRAY.COL25.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C23.cs), state2pr(DUV.TOP.ARRAY.COL27.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C23.cs), state2pr(DUV.TOP.ARRAY.COL29.C23.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C23.cs), state2pr(DUV.TOP.ARRAY.COL31.C23.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[22], 
		 state2pr(DUV.TOP.ARRAY.COL0.C22.cs), state2pr(DUV.TOP.ARRAY.COL1.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C22.cs), state2pr(DUV.TOP.ARRAY.COL3.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C22.cs), state2pr(DUV.TOP.ARRAY.COL5.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C22.cs), state2pr(DUV.TOP.ARRAY.COL7.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C22.cs), state2pr(DUV.TOP.ARRAY.COL9.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C22.cs), state2pr(DUV.TOP.ARRAY.COL11.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C22.cs), state2pr(DUV.TOP.ARRAY.COL13.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C22.cs), state2pr(DUV.TOP.ARRAY.COL15.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C22.cs), state2pr(DUV.TOP.ARRAY.COL17.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C22.cs), state2pr(DUV.TOP.ARRAY.COL19.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C22.cs), state2pr(DUV.TOP.ARRAY.COL21.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C22.cs), state2pr(DUV.TOP.ARRAY.COL23.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C22.cs), state2pr(DUV.TOP.ARRAY.COL25.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C22.cs), state2pr(DUV.TOP.ARRAY.COL27.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C22.cs), state2pr(DUV.TOP.ARRAY.COL29.C22.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C22.cs), state2pr(DUV.TOP.ARRAY.COL31.C22.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[21], 
		 state2pr(DUV.TOP.ARRAY.COL0.C21.cs), state2pr(DUV.TOP.ARRAY.COL1.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C21.cs), state2pr(DUV.TOP.ARRAY.COL3.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C21.cs), state2pr(DUV.TOP.ARRAY.COL5.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C21.cs), state2pr(DUV.TOP.ARRAY.COL7.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C21.cs), state2pr(DUV.TOP.ARRAY.COL9.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C21.cs), state2pr(DUV.TOP.ARRAY.COL11.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C21.cs), state2pr(DUV.TOP.ARRAY.COL13.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C21.cs), state2pr(DUV.TOP.ARRAY.COL15.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C21.cs), state2pr(DUV.TOP.ARRAY.COL17.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C21.cs), state2pr(DUV.TOP.ARRAY.COL19.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C21.cs), state2pr(DUV.TOP.ARRAY.COL21.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C21.cs), state2pr(DUV.TOP.ARRAY.COL23.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C21.cs), state2pr(DUV.TOP.ARRAY.COL25.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C21.cs), state2pr(DUV.TOP.ARRAY.COL27.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C21.cs), state2pr(DUV.TOP.ARRAY.COL29.C21.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C21.cs), state2pr(DUV.TOP.ARRAY.COL31.C21.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[20], 
		 state2pr(DUV.TOP.ARRAY.COL0.C20.cs), state2pr(DUV.TOP.ARRAY.COL1.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C20.cs), state2pr(DUV.TOP.ARRAY.COL3.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C20.cs), state2pr(DUV.TOP.ARRAY.COL5.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C20.cs), state2pr(DUV.TOP.ARRAY.COL7.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C20.cs), state2pr(DUV.TOP.ARRAY.COL9.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C20.cs), state2pr(DUV.TOP.ARRAY.COL11.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C20.cs), state2pr(DUV.TOP.ARRAY.COL13.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C20.cs), state2pr(DUV.TOP.ARRAY.COL15.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C20.cs), state2pr(DUV.TOP.ARRAY.COL17.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C20.cs), state2pr(DUV.TOP.ARRAY.COL19.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C20.cs), state2pr(DUV.TOP.ARRAY.COL21.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C20.cs), state2pr(DUV.TOP.ARRAY.COL23.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C20.cs), state2pr(DUV.TOP.ARRAY.COL25.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C20.cs), state2pr(DUV.TOP.ARRAY.COL27.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C20.cs), state2pr(DUV.TOP.ARRAY.COL29.C20.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C20.cs), state2pr(DUV.TOP.ARRAY.COL31.C20.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[19], 
		 state2pr(DUV.TOP.ARRAY.COL0.C19.cs), state2pr(DUV.TOP.ARRAY.COL1.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C19.cs), state2pr(DUV.TOP.ARRAY.COL3.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C19.cs), state2pr(DUV.TOP.ARRAY.COL5.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C19.cs), state2pr(DUV.TOP.ARRAY.COL7.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C19.cs), state2pr(DUV.TOP.ARRAY.COL9.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C19.cs), state2pr(DUV.TOP.ARRAY.COL11.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C19.cs), state2pr(DUV.TOP.ARRAY.COL13.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C19.cs), state2pr(DUV.TOP.ARRAY.COL15.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C19.cs), state2pr(DUV.TOP.ARRAY.COL17.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C19.cs), state2pr(DUV.TOP.ARRAY.COL19.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C19.cs), state2pr(DUV.TOP.ARRAY.COL21.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C19.cs), state2pr(DUV.TOP.ARRAY.COL23.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C19.cs), state2pr(DUV.TOP.ARRAY.COL25.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C19.cs), state2pr(DUV.TOP.ARRAY.COL27.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C19.cs), state2pr(DUV.TOP.ARRAY.COL29.C19.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C19.cs), state2pr(DUV.TOP.ARRAY.COL31.C19.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[18], 
		 state2pr(DUV.TOP.ARRAY.COL0.C18.cs), state2pr(DUV.TOP.ARRAY.COL1.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C18.cs), state2pr(DUV.TOP.ARRAY.COL3.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C18.cs), state2pr(DUV.TOP.ARRAY.COL5.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C18.cs), state2pr(DUV.TOP.ARRAY.COL7.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C18.cs), state2pr(DUV.TOP.ARRAY.COL9.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C18.cs), state2pr(DUV.TOP.ARRAY.COL11.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C18.cs), state2pr(DUV.TOP.ARRAY.COL13.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C18.cs), state2pr(DUV.TOP.ARRAY.COL15.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C18.cs), state2pr(DUV.TOP.ARRAY.COL17.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C18.cs), state2pr(DUV.TOP.ARRAY.COL19.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C18.cs), state2pr(DUV.TOP.ARRAY.COL21.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C18.cs), state2pr(DUV.TOP.ARRAY.COL23.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C18.cs), state2pr(DUV.TOP.ARRAY.COL25.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C18.cs), state2pr(DUV.TOP.ARRAY.COL27.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C18.cs), state2pr(DUV.TOP.ARRAY.COL29.C18.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C18.cs), state2pr(DUV.TOP.ARRAY.COL31.C18.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[17], 
		 state2pr(DUV.TOP.ARRAY.COL0.C17.cs), state2pr(DUV.TOP.ARRAY.COL1.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C17.cs), state2pr(DUV.TOP.ARRAY.COL3.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C17.cs), state2pr(DUV.TOP.ARRAY.COL5.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C17.cs), state2pr(DUV.TOP.ARRAY.COL7.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C17.cs), state2pr(DUV.TOP.ARRAY.COL9.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C17.cs), state2pr(DUV.TOP.ARRAY.COL11.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C17.cs), state2pr(DUV.TOP.ARRAY.COL13.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C17.cs), state2pr(DUV.TOP.ARRAY.COL15.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C17.cs), state2pr(DUV.TOP.ARRAY.COL17.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C17.cs), state2pr(DUV.TOP.ARRAY.COL19.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C17.cs), state2pr(DUV.TOP.ARRAY.COL21.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C17.cs), state2pr(DUV.TOP.ARRAY.COL23.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C17.cs), state2pr(DUV.TOP.ARRAY.COL25.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C17.cs), state2pr(DUV.TOP.ARRAY.COL27.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C17.cs), state2pr(DUV.TOP.ARRAY.COL29.C17.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C17.cs), state2pr(DUV.TOP.ARRAY.COL31.C17.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[16], 
		 state2pr(DUV.TOP.ARRAY.COL0.C16.cs), state2pr(DUV.TOP.ARRAY.COL1.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C16.cs), state2pr(DUV.TOP.ARRAY.COL3.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C16.cs), state2pr(DUV.TOP.ARRAY.COL5.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C16.cs), state2pr(DUV.TOP.ARRAY.COL7.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C16.cs), state2pr(DUV.TOP.ARRAY.COL9.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C16.cs), state2pr(DUV.TOP.ARRAY.COL11.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C16.cs), state2pr(DUV.TOP.ARRAY.COL13.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C16.cs), state2pr(DUV.TOP.ARRAY.COL15.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C16.cs), state2pr(DUV.TOP.ARRAY.COL17.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C16.cs), state2pr(DUV.TOP.ARRAY.COL19.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C16.cs), state2pr(DUV.TOP.ARRAY.COL21.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C16.cs), state2pr(DUV.TOP.ARRAY.COL23.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C16.cs), state2pr(DUV.TOP.ARRAY.COL25.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C16.cs), state2pr(DUV.TOP.ARRAY.COL27.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C16.cs), state2pr(DUV.TOP.ARRAY.COL29.C16.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C16.cs), state2pr(DUV.TOP.ARRAY.COL31.C16.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[15], 
		 state2pr(DUV.TOP.ARRAY.COL0.C15.cs), state2pr(DUV.TOP.ARRAY.COL1.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C15.cs), state2pr(DUV.TOP.ARRAY.COL3.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C15.cs), state2pr(DUV.TOP.ARRAY.COL5.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C15.cs), state2pr(DUV.TOP.ARRAY.COL7.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C15.cs), state2pr(DUV.TOP.ARRAY.COL9.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C15.cs), state2pr(DUV.TOP.ARRAY.COL11.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C15.cs), state2pr(DUV.TOP.ARRAY.COL13.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C15.cs), state2pr(DUV.TOP.ARRAY.COL15.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C15.cs), state2pr(DUV.TOP.ARRAY.COL17.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C15.cs), state2pr(DUV.TOP.ARRAY.COL19.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C15.cs), state2pr(DUV.TOP.ARRAY.COL21.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C15.cs), state2pr(DUV.TOP.ARRAY.COL23.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C15.cs), state2pr(DUV.TOP.ARRAY.COL25.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C15.cs), state2pr(DUV.TOP.ARRAY.COL27.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C15.cs), state2pr(DUV.TOP.ARRAY.COL29.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C15.cs), state2pr(DUV.TOP.ARRAY.COL31.C15.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[14], 
		 state2pr(DUV.TOP.ARRAY.COL0.C14.cs), state2pr(DUV.TOP.ARRAY.COL1.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C14.cs), state2pr(DUV.TOP.ARRAY.COL3.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C14.cs), state2pr(DUV.TOP.ARRAY.COL5.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C14.cs), state2pr(DUV.TOP.ARRAY.COL7.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C14.cs), state2pr(DUV.TOP.ARRAY.COL9.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C14.cs), state2pr(DUV.TOP.ARRAY.COL11.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C14.cs), state2pr(DUV.TOP.ARRAY.COL13.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C14.cs), state2pr(DUV.TOP.ARRAY.COL15.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C14.cs), state2pr(DUV.TOP.ARRAY.COL17.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C14.cs), state2pr(DUV.TOP.ARRAY.COL19.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C14.cs), state2pr(DUV.TOP.ARRAY.COL21.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C14.cs), state2pr(DUV.TOP.ARRAY.COL23.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C14.cs), state2pr(DUV.TOP.ARRAY.COL25.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C14.cs), state2pr(DUV.TOP.ARRAY.COL27.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C14.cs), state2pr(DUV.TOP.ARRAY.COL29.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C14.cs), state2pr(DUV.TOP.ARRAY.COL31.C14.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[13], 
		 state2pr(DUV.TOP.ARRAY.COL0.C13.cs), state2pr(DUV.TOP.ARRAY.COL1.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C13.cs), state2pr(DUV.TOP.ARRAY.COL3.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C13.cs), state2pr(DUV.TOP.ARRAY.COL5.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C13.cs), state2pr(DUV.TOP.ARRAY.COL7.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C13.cs), state2pr(DUV.TOP.ARRAY.COL9.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C13.cs), state2pr(DUV.TOP.ARRAY.COL11.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C13.cs), state2pr(DUV.TOP.ARRAY.COL13.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C13.cs), state2pr(DUV.TOP.ARRAY.COL15.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C13.cs), state2pr(DUV.TOP.ARRAY.COL17.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C13.cs), state2pr(DUV.TOP.ARRAY.COL19.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C13.cs), state2pr(DUV.TOP.ARRAY.COL21.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C13.cs), state2pr(DUV.TOP.ARRAY.COL23.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C13.cs), state2pr(DUV.TOP.ARRAY.COL25.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C13.cs), state2pr(DUV.TOP.ARRAY.COL27.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C13.cs), state2pr(DUV.TOP.ARRAY.COL29.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C13.cs), state2pr(DUV.TOP.ARRAY.COL31.C13.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[12], 
		 state2pr(DUV.TOP.ARRAY.COL0.C12.cs), state2pr(DUV.TOP.ARRAY.COL1.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C12.cs), state2pr(DUV.TOP.ARRAY.COL3.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C12.cs), state2pr(DUV.TOP.ARRAY.COL5.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C12.cs), state2pr(DUV.TOP.ARRAY.COL7.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C12.cs), state2pr(DUV.TOP.ARRAY.COL9.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C12.cs), state2pr(DUV.TOP.ARRAY.COL11.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C12.cs), state2pr(DUV.TOP.ARRAY.COL13.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C12.cs), state2pr(DUV.TOP.ARRAY.COL15.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C12.cs), state2pr(DUV.TOP.ARRAY.COL17.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C12.cs), state2pr(DUV.TOP.ARRAY.COL19.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C12.cs), state2pr(DUV.TOP.ARRAY.COL21.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C12.cs), state2pr(DUV.TOP.ARRAY.COL23.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C12.cs), state2pr(DUV.TOP.ARRAY.COL25.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C12.cs), state2pr(DUV.TOP.ARRAY.COL27.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C12.cs), state2pr(DUV.TOP.ARRAY.COL29.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C12.cs), state2pr(DUV.TOP.ARRAY.COL31.C12.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[11], 
		 state2pr(DUV.TOP.ARRAY.COL0.C11.cs), state2pr(DUV.TOP.ARRAY.COL1.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C11.cs), state2pr(DUV.TOP.ARRAY.COL3.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C11.cs), state2pr(DUV.TOP.ARRAY.COL5.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C11.cs), state2pr(DUV.TOP.ARRAY.COL7.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C11.cs), state2pr(DUV.TOP.ARRAY.COL9.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C11.cs), state2pr(DUV.TOP.ARRAY.COL11.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C11.cs), state2pr(DUV.TOP.ARRAY.COL13.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C11.cs), state2pr(DUV.TOP.ARRAY.COL15.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C11.cs), state2pr(DUV.TOP.ARRAY.COL17.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C11.cs), state2pr(DUV.TOP.ARRAY.COL19.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C11.cs), state2pr(DUV.TOP.ARRAY.COL21.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C11.cs), state2pr(DUV.TOP.ARRAY.COL23.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C11.cs), state2pr(DUV.TOP.ARRAY.COL25.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C11.cs), state2pr(DUV.TOP.ARRAY.COL27.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C11.cs), state2pr(DUV.TOP.ARRAY.COL29.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C11.cs), state2pr(DUV.TOP.ARRAY.COL31.C11.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[10], 
		 state2pr(DUV.TOP.ARRAY.COL0.C10.cs), state2pr(DUV.TOP.ARRAY.COL1.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C10.cs), state2pr(DUV.TOP.ARRAY.COL3.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C10.cs), state2pr(DUV.TOP.ARRAY.COL5.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C10.cs), state2pr(DUV.TOP.ARRAY.COL7.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C10.cs), state2pr(DUV.TOP.ARRAY.COL9.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C10.cs), state2pr(DUV.TOP.ARRAY.COL11.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C10.cs), state2pr(DUV.TOP.ARRAY.COL13.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C10.cs), state2pr(DUV.TOP.ARRAY.COL15.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C10.cs), state2pr(DUV.TOP.ARRAY.COL17.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C10.cs), state2pr(DUV.TOP.ARRAY.COL19.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C10.cs), state2pr(DUV.TOP.ARRAY.COL21.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C10.cs), state2pr(DUV.TOP.ARRAY.COL23.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C10.cs), state2pr(DUV.TOP.ARRAY.COL25.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C10.cs), state2pr(DUV.TOP.ARRAY.COL27.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C10.cs), state2pr(DUV.TOP.ARRAY.COL29.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C10.cs), state2pr(DUV.TOP.ARRAY.COL31.C10.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[9], 
		 state2pr(DUV.TOP.ARRAY.COL0.C9.cs), state2pr(DUV.TOP.ARRAY.COL1.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C9.cs), state2pr(DUV.TOP.ARRAY.COL3.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C9.cs), state2pr(DUV.TOP.ARRAY.COL5.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C9.cs), state2pr(DUV.TOP.ARRAY.COL7.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C9.cs), state2pr(DUV.TOP.ARRAY.COL9.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C9.cs), state2pr(DUV.TOP.ARRAY.COL11.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C9.cs), state2pr(DUV.TOP.ARRAY.COL13.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C9.cs), state2pr(DUV.TOP.ARRAY.COL15.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C9.cs), state2pr(DUV.TOP.ARRAY.COL17.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C9.cs), state2pr(DUV.TOP.ARRAY.COL19.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C9.cs), state2pr(DUV.TOP.ARRAY.COL21.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C9.cs), state2pr(DUV.TOP.ARRAY.COL23.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C9.cs), state2pr(DUV.TOP.ARRAY.COL25.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C9.cs), state2pr(DUV.TOP.ARRAY.COL27.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C9.cs), state2pr(DUV.TOP.ARRAY.COL29.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C9.cs), state2pr(DUV.TOP.ARRAY.COL31.C9.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[8], 
		 state2pr(DUV.TOP.ARRAY.COL0.C8.cs), state2pr(DUV.TOP.ARRAY.COL1.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C8.cs), state2pr(DUV.TOP.ARRAY.COL3.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C8.cs), state2pr(DUV.TOP.ARRAY.COL5.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C8.cs), state2pr(DUV.TOP.ARRAY.COL7.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C8.cs), state2pr(DUV.TOP.ARRAY.COL9.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C8.cs), state2pr(DUV.TOP.ARRAY.COL11.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C8.cs), state2pr(DUV.TOP.ARRAY.COL13.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C8.cs), state2pr(DUV.TOP.ARRAY.COL15.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C8.cs), state2pr(DUV.TOP.ARRAY.COL17.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C8.cs), state2pr(DUV.TOP.ARRAY.COL19.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C8.cs), state2pr(DUV.TOP.ARRAY.COL21.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C8.cs), state2pr(DUV.TOP.ARRAY.COL23.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C8.cs), state2pr(DUV.TOP.ARRAY.COL25.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C8.cs), state2pr(DUV.TOP.ARRAY.COL27.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C8.cs), state2pr(DUV.TOP.ARRAY.COL29.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C8.cs), state2pr(DUV.TOP.ARRAY.COL31.C8.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[7], 
		 state2pr(DUV.TOP.ARRAY.COL0.C7.cs), state2pr(DUV.TOP.ARRAY.COL1.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C7.cs), state2pr(DUV.TOP.ARRAY.COL3.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C7.cs), state2pr(DUV.TOP.ARRAY.COL5.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C7.cs), state2pr(DUV.TOP.ARRAY.COL7.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C7.cs), state2pr(DUV.TOP.ARRAY.COL9.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C7.cs), state2pr(DUV.TOP.ARRAY.COL11.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C7.cs), state2pr(DUV.TOP.ARRAY.COL13.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C7.cs), state2pr(DUV.TOP.ARRAY.COL15.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C7.cs), state2pr(DUV.TOP.ARRAY.COL17.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C7.cs), state2pr(DUV.TOP.ARRAY.COL19.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C7.cs), state2pr(DUV.TOP.ARRAY.COL21.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C7.cs), state2pr(DUV.TOP.ARRAY.COL23.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C7.cs), state2pr(DUV.TOP.ARRAY.COL25.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C7.cs), state2pr(DUV.TOP.ARRAY.COL27.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C7.cs), state2pr(DUV.TOP.ARRAY.COL29.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C7.cs), state2pr(DUV.TOP.ARRAY.COL31.C7.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[6], 
		 state2pr(DUV.TOP.ARRAY.COL0.C6.cs), state2pr(DUV.TOP.ARRAY.COL1.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C6.cs), state2pr(DUV.TOP.ARRAY.COL3.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C6.cs), state2pr(DUV.TOP.ARRAY.COL5.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C6.cs), state2pr(DUV.TOP.ARRAY.COL7.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C6.cs), state2pr(DUV.TOP.ARRAY.COL9.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C6.cs), state2pr(DUV.TOP.ARRAY.COL11.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C6.cs), state2pr(DUV.TOP.ARRAY.COL13.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C6.cs), state2pr(DUV.TOP.ARRAY.COL15.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C6.cs), state2pr(DUV.TOP.ARRAY.COL17.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C6.cs), state2pr(DUV.TOP.ARRAY.COL19.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C6.cs), state2pr(DUV.TOP.ARRAY.COL21.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C6.cs), state2pr(DUV.TOP.ARRAY.COL23.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C6.cs), state2pr(DUV.TOP.ARRAY.COL25.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C6.cs), state2pr(DUV.TOP.ARRAY.COL27.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C6.cs), state2pr(DUV.TOP.ARRAY.COL29.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C6.cs), state2pr(DUV.TOP.ARRAY.COL31.C6.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[5], 
		 state2pr(DUV.TOP.ARRAY.COL0.C5.cs), state2pr(DUV.TOP.ARRAY.COL1.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C5.cs), state2pr(DUV.TOP.ARRAY.COL3.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C5.cs), state2pr(DUV.TOP.ARRAY.COL5.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C5.cs), state2pr(DUV.TOP.ARRAY.COL7.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C5.cs), state2pr(DUV.TOP.ARRAY.COL9.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C5.cs), state2pr(DUV.TOP.ARRAY.COL11.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C5.cs), state2pr(DUV.TOP.ARRAY.COL13.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C5.cs), state2pr(DUV.TOP.ARRAY.COL15.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C5.cs), state2pr(DUV.TOP.ARRAY.COL17.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C5.cs), state2pr(DUV.TOP.ARRAY.COL19.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C5.cs), state2pr(DUV.TOP.ARRAY.COL21.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C5.cs), state2pr(DUV.TOP.ARRAY.COL23.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C5.cs), state2pr(DUV.TOP.ARRAY.COL25.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C5.cs), state2pr(DUV.TOP.ARRAY.COL27.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C5.cs), state2pr(DUV.TOP.ARRAY.COL29.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C5.cs), state2pr(DUV.TOP.ARRAY.COL31.C5.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[4], 
		 state2pr(DUV.TOP.ARRAY.COL0.C4.cs), state2pr(DUV.TOP.ARRAY.COL1.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C4.cs), state2pr(DUV.TOP.ARRAY.COL3.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C4.cs), state2pr(DUV.TOP.ARRAY.COL5.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C4.cs), state2pr(DUV.TOP.ARRAY.COL7.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C4.cs), state2pr(DUV.TOP.ARRAY.COL9.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C4.cs), state2pr(DUV.TOP.ARRAY.COL11.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C4.cs), state2pr(DUV.TOP.ARRAY.COL13.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C4.cs), state2pr(DUV.TOP.ARRAY.COL15.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C4.cs), state2pr(DUV.TOP.ARRAY.COL17.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C4.cs), state2pr(DUV.TOP.ARRAY.COL19.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C4.cs), state2pr(DUV.TOP.ARRAY.COL21.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C4.cs), state2pr(DUV.TOP.ARRAY.COL23.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C4.cs), state2pr(DUV.TOP.ARRAY.COL25.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C4.cs), state2pr(DUV.TOP.ARRAY.COL27.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C4.cs), state2pr(DUV.TOP.ARRAY.COL29.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C4.cs), state2pr(DUV.TOP.ARRAY.COL31.C4.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[3], 
		 state2pr(DUV.TOP.ARRAY.COL0.C3.cs), state2pr(DUV.TOP.ARRAY.COL1.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C3.cs), state2pr(DUV.TOP.ARRAY.COL3.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C3.cs), state2pr(DUV.TOP.ARRAY.COL5.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C3.cs), state2pr(DUV.TOP.ARRAY.COL7.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C3.cs), state2pr(DUV.TOP.ARRAY.COL9.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C3.cs), state2pr(DUV.TOP.ARRAY.COL11.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C3.cs), state2pr(DUV.TOP.ARRAY.COL13.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C3.cs), state2pr(DUV.TOP.ARRAY.COL15.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C3.cs), state2pr(DUV.TOP.ARRAY.COL17.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C3.cs), state2pr(DUV.TOP.ARRAY.COL19.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C3.cs), state2pr(DUV.TOP.ARRAY.COL21.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C3.cs), state2pr(DUV.TOP.ARRAY.COL23.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C3.cs), state2pr(DUV.TOP.ARRAY.COL25.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C3.cs), state2pr(DUV.TOP.ARRAY.COL27.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C3.cs), state2pr(DUV.TOP.ARRAY.COL29.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C3.cs), state2pr(DUV.TOP.ARRAY.COL31.C3.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[2], 
		 state2pr(DUV.TOP.ARRAY.COL0.C2.cs), state2pr(DUV.TOP.ARRAY.COL1.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C2.cs), state2pr(DUV.TOP.ARRAY.COL3.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C2.cs), state2pr(DUV.TOP.ARRAY.COL5.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C2.cs), state2pr(DUV.TOP.ARRAY.COL7.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C2.cs), state2pr(DUV.TOP.ARRAY.COL9.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C2.cs), state2pr(DUV.TOP.ARRAY.COL11.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C2.cs), state2pr(DUV.TOP.ARRAY.COL13.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C2.cs), state2pr(DUV.TOP.ARRAY.COL15.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C2.cs), state2pr(DUV.TOP.ARRAY.COL17.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C2.cs), state2pr(DUV.TOP.ARRAY.COL19.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C2.cs), state2pr(DUV.TOP.ARRAY.COL21.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C2.cs), state2pr(DUV.TOP.ARRAY.COL23.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C2.cs), state2pr(DUV.TOP.ARRAY.COL25.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C2.cs), state2pr(DUV.TOP.ARRAY.COL27.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C2.cs), state2pr(DUV.TOP.ARRAY.COL29.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C2.cs), state2pr(DUV.TOP.ARRAY.COL31.C2.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[1], 
		 state2pr(DUV.TOP.ARRAY.COL0.C1.cs), state2pr(DUV.TOP.ARRAY.COL1.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C1.cs), state2pr(DUV.TOP.ARRAY.COL3.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C1.cs), state2pr(DUV.TOP.ARRAY.COL5.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C1.cs), state2pr(DUV.TOP.ARRAY.COL7.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C1.cs), state2pr(DUV.TOP.ARRAY.COL9.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C1.cs), state2pr(DUV.TOP.ARRAY.COL11.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C1.cs), state2pr(DUV.TOP.ARRAY.COL13.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C1.cs), state2pr(DUV.TOP.ARRAY.COL15.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C1.cs), state2pr(DUV.TOP.ARRAY.COL17.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C1.cs), state2pr(DUV.TOP.ARRAY.COL19.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C1.cs), state2pr(DUV.TOP.ARRAY.COL21.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C1.cs), state2pr(DUV.TOP.ARRAY.COL23.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C1.cs), state2pr(DUV.TOP.ARRAY.COL25.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C1.cs), state2pr(DUV.TOP.ARRAY.COL27.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C1.cs), state2pr(DUV.TOP.ARRAY.COL29.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C1.cs), state2pr(DUV.TOP.ARRAY.COL31.C1.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[0], 
		 state2pr(DUV.TOP.ARRAY.COL0.C0.cs), state2pr(DUV.TOP.ARRAY.COL1.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C0.cs), state2pr(DUV.TOP.ARRAY.COL3.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C0.cs), state2pr(DUV.TOP.ARRAY.COL5.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C0.cs), state2pr(DUV.TOP.ARRAY.COL7.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C0.cs), state2pr(DUV.TOP.ARRAY.COL9.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C0.cs), state2pr(DUV.TOP.ARRAY.COL11.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C0.cs), state2pr(DUV.TOP.ARRAY.COL13.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C0.cs), state2pr(DUV.TOP.ARRAY.COL15.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL16.C0.cs), state2pr(DUV.TOP.ARRAY.COL17.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL18.C0.cs), state2pr(DUV.TOP.ARRAY.COL19.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL20.C0.cs), state2pr(DUV.TOP.ARRAY.COL21.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL22.C0.cs), state2pr(DUV.TOP.ARRAY.COL23.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL24.C0.cs), state2pr(DUV.TOP.ARRAY.COL25.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL26.C0.cs), state2pr(DUV.TOP.ARRAY.COL27.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL28.C0.cs), state2pr(DUV.TOP.ARRAY.COL29.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL30.C0.cs), state2pr(DUV.TOP.ARRAY.COL31.C0.cs));


	$display("-------------------");
     end // always @ (posedge clk)



   initial
     begin
	   //  $monitor("status=%b status_p=%b", DUV.TOP.status, DUV.TOP.status_p);
        $monitor("time=%5t cs=%d ns=%d cell_cmd=%d cmd_in=%h result_out=%d status=%b s_r=%b L=%d x1=%d y1=%d z1=%d x2=%d y2=%d z2=%d START=%d LAST=%d t_ch=%b t_dn=%b WF=%b extend=%b ext_cont=%b",
		 $time, ctl_state,	DUV.CONTROL.ns, DUV.CONTROL.cell_cmd,
		 cmd_in, result_out, DUV.status_out, status_reg, DUV.CONTROL.cur_layer,
		 DUV.CONTROL.x1_v, DUV.CONTROL.y1_v, DUV.CONTROL.z1_v, 
		 DUV.CONTROL.x2_v, DUV.CONTROL.y2_v, DUV.CONTROL.z2_v, 
		 DUV.CONTROL.layer_range_start,  DUV.CONTROL.layer_range_last, DUV.CONTROL.trace_change, DUV.CONTROL.trace_done,
		 DUV.CONTROL.watch_fail,
		 DUV.CONTROL.extend, DUV.CONTROL.extend_continue); 
	init;
	reset;
/*        route(8,0,3,8,31,3);  // test etching here!
	route(8,0,2,8,31,2);
	route(8,0,1,8,31,1);
	route(8,0,0,8,31,0);   */
	route_extend_init(5,0,0,0,0,0);
	route_extended(5,5,0,1);
	route_extended(8,3,0,0);
	route(2,2,0,10,2,0);
/*
	write_cell(3, 3, 3, 0);
	read_cell(3, 3, 3);
	write_cell(2, 2, 2, 1);
	read_cell(2, 2, 2);
	write_cell(1, 1, 1, 2);
	read_cell(1, 1, 1);
	write_cell(0, 0, 0, 3);
	read_cell(0, 0, 0);

 */
 
/*	
	set_unetchable(0,0,0);
	set_unetchable(3,0,0);
	set_unetchable(1,3,0);
*/

  //get_xcount;
  //get_tcount;

  /*

	route_extended(0,0,0, 1);
	route_extended(3,0,0, 1);
	route_extended(1,3,0, 0); 	  */
//	read_xcount;
//	read_tcount;

//	route(1,0,1,3,3,1);
	
 /*
 // etch test
	set_unetchable(1,0,2);
	set_unetchable(1,3,2);
	set_unetchable(0,0,1);
	set_unetchable(0,3,1);
	set_unetchable(0,0,3);
	set_unetchable(0,3,3);
	set_unetchable(2,0,2);
	set_unetchable(0,0,2);


     route(1,0,2,1,3,2);
	  route(0,0,1,0,3,1);
	  route(0,0,3,0,3,3);
	  route(2,0,2,0,0,2); 
 */
     
	 clearx;

     $stop;

  end // initial begin
	      
endmodule


