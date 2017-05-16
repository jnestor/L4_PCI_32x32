`include "L4_decs.v"

module L4_bench16x16(clk, ctl_state, status_reg);
   output       clk;
   reg          clk;
   output [4:0] ctl_state;
   output [3:0] status_reg;
   
   reg          resetn;
   reg          cmd_empty;
   reg [31:0] 	cmd_in;
   wire 	cmd_rd;
   reg 		result_full;
   wire [31:0] 	result_out;
   wire 	result_wr;
   
   L4_all16x16 DUV(.clk(clk), .resetn(resetn), .cmd_empty(cmd_empty), 
                 .cmd_in(cmd_in), .cmd_rd(cmd_rd), .result_full(result_full), 
                 .result_out(result_out), .result_wr(result_wr), .ctl_state(ctl_state), .status_reg(status_reg));  
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
	wire [7:0] result_count1, result_count2;
	wire [3:0] result_status;
	assign result_type = result_out[31:29];
	assign result_x = result_out[14:10];
	assign result_y = result_out[9:5];
	assign result_z =	result_out[4:0];
	assign result_count1 = result_out[15:8];
	assign result_count2 = result_out[7:0];
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
	$display("S %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
		DUV.TOP.ARRAY.csel_v[0], DUV.TOP.ARRAY.csel_v[1],
		DUV.TOP.ARRAY.csel_v[2], DUV.TOP.ARRAY.csel_v[3],
		DUV.TOP.ARRAY.csel_v[4], DUV.TOP.ARRAY.csel_v[5],
		DUV.TOP.ARRAY.csel_v[6], DUV.TOP.ARRAY.csel_v[7],
		DUV.TOP.ARRAY.csel_v[8], DUV.TOP.ARRAY.csel_v[9],
		DUV.TOP.ARRAY.csel_v[10], DUV.TOP.ARRAY.csel_v[11],
		DUV.TOP.ARRAY.csel_v[12], DUV.TOP.ARRAY.csel_v[13],
		DUV.TOP.ARRAY.csel_v[14], DUV.TOP.ARRAY.csel_v[15]);
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[15], 
		 state2pr(DUV.TOP.ARRAY.COL0.C15.cs), state2pr(DUV.TOP.ARRAY.COL1.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C15.cs), state2pr(DUV.TOP.ARRAY.COL3.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C15.cs), state2pr(DUV.TOP.ARRAY.COL5.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C15.cs), state2pr(DUV.TOP.ARRAY.COL7.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C15.cs), state2pr(DUV.TOP.ARRAY.COL9.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C15.cs), state2pr(DUV.TOP.ARRAY.COL11.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C15.cs), state2pr(DUV.TOP.ARRAY.COL13.C15.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C15.cs), state2pr(DUV.TOP.ARRAY.COL15.C15.cs));
	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[14], 
		 state2pr(DUV.TOP.ARRAY.COL0.C14.cs), state2pr(DUV.TOP.ARRAY.COL1.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C14.cs), state2pr(DUV.TOP.ARRAY.COL3.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C14.cs), state2pr(DUV.TOP.ARRAY.COL5.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C14.cs), state2pr(DUV.TOP.ARRAY.COL7.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C14.cs), state2pr(DUV.TOP.ARRAY.COL9.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C14.cs), state2pr(DUV.TOP.ARRAY.COL11.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C14.cs), state2pr(DUV.TOP.ARRAY.COL13.C14.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C14.cs), state2pr(DUV.TOP.ARRAY.COL15.C14.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[13], 
		 state2pr(DUV.TOP.ARRAY.COL0.C13.cs), state2pr(DUV.TOP.ARRAY.COL1.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C13.cs), state2pr(DUV.TOP.ARRAY.COL3.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C13.cs), state2pr(DUV.TOP.ARRAY.COL5.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C13.cs), state2pr(DUV.TOP.ARRAY.COL7.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C13.cs), state2pr(DUV.TOP.ARRAY.COL9.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C13.cs), state2pr(DUV.TOP.ARRAY.COL11.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C13.cs), state2pr(DUV.TOP.ARRAY.COL13.C13.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C13.cs), state2pr(DUV.TOP.ARRAY.COL15.C13.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[12], 
		 state2pr(DUV.TOP.ARRAY.COL0.C12.cs), state2pr(DUV.TOP.ARRAY.COL1.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C12.cs), state2pr(DUV.TOP.ARRAY.COL3.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C12.cs), state2pr(DUV.TOP.ARRAY.COL5.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C12.cs), state2pr(DUV.TOP.ARRAY.COL7.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C12.cs), state2pr(DUV.TOP.ARRAY.COL9.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C12.cs), state2pr(DUV.TOP.ARRAY.COL11.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C12.cs), state2pr(DUV.TOP.ARRAY.COL13.C12.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C12.cs), state2pr(DUV.TOP.ARRAY.COL15.C12.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[11], 
		 state2pr(DUV.TOP.ARRAY.COL0.C11.cs), state2pr(DUV.TOP.ARRAY.COL1.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C11.cs), state2pr(DUV.TOP.ARRAY.COL3.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C11.cs), state2pr(DUV.TOP.ARRAY.COL5.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C11.cs), state2pr(DUV.TOP.ARRAY.COL7.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C11.cs), state2pr(DUV.TOP.ARRAY.COL9.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C11.cs), state2pr(DUV.TOP.ARRAY.COL11.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C11.cs), state2pr(DUV.TOP.ARRAY.COL13.C11.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C11.cs), state2pr(DUV.TOP.ARRAY.COL15.C11.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[10], 
		 state2pr(DUV.TOP.ARRAY.COL0.C10.cs), state2pr(DUV.TOP.ARRAY.COL1.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C10.cs), state2pr(DUV.TOP.ARRAY.COL3.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C10.cs), state2pr(DUV.TOP.ARRAY.COL5.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C10.cs), state2pr(DUV.TOP.ARRAY.COL7.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C10.cs), state2pr(DUV.TOP.ARRAY.COL9.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C10.cs), state2pr(DUV.TOP.ARRAY.COL11.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C10.cs), state2pr(DUV.TOP.ARRAY.COL13.C10.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C10.cs), state2pr(DUV.TOP.ARRAY.COL15.C10.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[9], 
		 state2pr(DUV.TOP.ARRAY.COL0.C9.cs), state2pr(DUV.TOP.ARRAY.COL1.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C9.cs), state2pr(DUV.TOP.ARRAY.COL3.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C9.cs), state2pr(DUV.TOP.ARRAY.COL5.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C9.cs), state2pr(DUV.TOP.ARRAY.COL7.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C9.cs), state2pr(DUV.TOP.ARRAY.COL9.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C9.cs), state2pr(DUV.TOP.ARRAY.COL11.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C9.cs), state2pr(DUV.TOP.ARRAY.COL13.C9.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C9.cs), state2pr(DUV.TOP.ARRAY.COL15.C9.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[8], 
		 state2pr(DUV.TOP.ARRAY.COL0.C8.cs), state2pr(DUV.TOP.ARRAY.COL1.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C8.cs), state2pr(DUV.TOP.ARRAY.COL3.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C8.cs), state2pr(DUV.TOP.ARRAY.COL5.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C8.cs), state2pr(DUV.TOP.ARRAY.COL7.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C8.cs), state2pr(DUV.TOP.ARRAY.COL9.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C8.cs), state2pr(DUV.TOP.ARRAY.COL11.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C8.cs), state2pr(DUV.TOP.ARRAY.COL13.C8.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C8.cs), state2pr(DUV.TOP.ARRAY.COL15.C8.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[7], 
		 state2pr(DUV.TOP.ARRAY.COL0.C7.cs), state2pr(DUV.TOP.ARRAY.COL1.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C7.cs), state2pr(DUV.TOP.ARRAY.COL3.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C7.cs), state2pr(DUV.TOP.ARRAY.COL5.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C7.cs), state2pr(DUV.TOP.ARRAY.COL7.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C7.cs), state2pr(DUV.TOP.ARRAY.COL9.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C7.cs), state2pr(DUV.TOP.ARRAY.COL11.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C7.cs), state2pr(DUV.TOP.ARRAY.COL13.C7.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C7.cs), state2pr(DUV.TOP.ARRAY.COL15.C7.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[6], 
		 state2pr(DUV.TOP.ARRAY.COL0.C6.cs), state2pr(DUV.TOP.ARRAY.COL1.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C6.cs), state2pr(DUV.TOP.ARRAY.COL3.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C6.cs), state2pr(DUV.TOP.ARRAY.COL5.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C6.cs), state2pr(DUV.TOP.ARRAY.COL7.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C6.cs), state2pr(DUV.TOP.ARRAY.COL9.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C6.cs), state2pr(DUV.TOP.ARRAY.COL11.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C6.cs), state2pr(DUV.TOP.ARRAY.COL13.C6.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C6.cs), state2pr(DUV.TOP.ARRAY.COL15.C6.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[5], 
		 state2pr(DUV.TOP.ARRAY.COL0.C5.cs), state2pr(DUV.TOP.ARRAY.COL1.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C5.cs), state2pr(DUV.TOP.ARRAY.COL3.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C5.cs), state2pr(DUV.TOP.ARRAY.COL5.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C5.cs), state2pr(DUV.TOP.ARRAY.COL7.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C5.cs), state2pr(DUV.TOP.ARRAY.COL9.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C5.cs), state2pr(DUV.TOP.ARRAY.COL11.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C5.cs), state2pr(DUV.TOP.ARRAY.COL13.C5.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C5.cs), state2pr(DUV.TOP.ARRAY.COL15.C5.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[4], 
		 state2pr(DUV.TOP.ARRAY.COL0.C4.cs), state2pr(DUV.TOP.ARRAY.COL1.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C4.cs), state2pr(DUV.TOP.ARRAY.COL3.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C4.cs), state2pr(DUV.TOP.ARRAY.COL5.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C4.cs), state2pr(DUV.TOP.ARRAY.COL7.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C4.cs), state2pr(DUV.TOP.ARRAY.COL9.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C4.cs), state2pr(DUV.TOP.ARRAY.COL11.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C4.cs), state2pr(DUV.TOP.ARRAY.COL13.C4.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C4.cs), state2pr(DUV.TOP.ARRAY.COL15.C4.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[3], 
		 state2pr(DUV.TOP.ARRAY.COL0.C3.cs), state2pr(DUV.TOP.ARRAY.COL1.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C3.cs), state2pr(DUV.TOP.ARRAY.COL3.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C3.cs), state2pr(DUV.TOP.ARRAY.COL5.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C3.cs), state2pr(DUV.TOP.ARRAY.COL7.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C3.cs), state2pr(DUV.TOP.ARRAY.COL9.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C3.cs), state2pr(DUV.TOP.ARRAY.COL11.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C3.cs), state2pr(DUV.TOP.ARRAY.COL13.C3.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C3.cs), state2pr(DUV.TOP.ARRAY.COL15.C3.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[2], 
		 state2pr(DUV.TOP.ARRAY.COL0.C2.cs), state2pr(DUV.TOP.ARRAY.COL1.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C2.cs), state2pr(DUV.TOP.ARRAY.COL3.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C2.cs), state2pr(DUV.TOP.ARRAY.COL5.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C2.cs), state2pr(DUV.TOP.ARRAY.COL7.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C2.cs), state2pr(DUV.TOP.ARRAY.COL9.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C2.cs), state2pr(DUV.TOP.ARRAY.COL11.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C2.cs), state2pr(DUV.TOP.ARRAY.COL13.C2.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C2.cs), state2pr(DUV.TOP.ARRAY.COL15.C2.cs));

	$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[1], 
		 state2pr(DUV.TOP.ARRAY.COL0.C1.cs), state2pr(DUV.TOP.ARRAY.COL1.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C1.cs), state2pr(DUV.TOP.ARRAY.COL3.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C1.cs), state2pr(DUV.TOP.ARRAY.COL5.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C1.cs), state2pr(DUV.TOP.ARRAY.COL7.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C1.cs), state2pr(DUV.TOP.ARRAY.COL9.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C1.cs), state2pr(DUV.TOP.ARRAY.COL11.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C1.cs), state2pr(DUV.TOP.ARRAY.COL13.C1.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C1.cs), state2pr(DUV.TOP.ARRAY.COL15.C1.cs));

		$display("%d %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c",
		 DUV.TOP.ARRAY.rsel_v[0], 
		 state2pr(DUV.TOP.ARRAY.COL0.C0.cs), state2pr(DUV.TOP.ARRAY.COL1.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL2.C0.cs), state2pr(DUV.TOP.ARRAY.COL3.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL4.C0.cs), state2pr(DUV.TOP.ARRAY.COL5.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL6.C0.cs), state2pr(DUV.TOP.ARRAY.COL7.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL8.C0.cs), state2pr(DUV.TOP.ARRAY.COL9.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL10.C0.cs), state2pr(DUV.TOP.ARRAY.COL11.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL12.C0.cs), state2pr(DUV.TOP.ARRAY.COL13.C0.cs),
		 state2pr(DUV.TOP.ARRAY.COL14.C0.cs), state2pr(DUV.TOP.ARRAY.COL15.C0.cs));


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

	route_extended(0,0,0, 1);
	route_extended(3,0,0, 1);
	route_extended(1,3,0, 0); 

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


