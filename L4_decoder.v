//-----------------------------------------------------------------------------
// Title         : L4_Decoder
// Project       : L4 Maze Routing Accelerator
//-----------------------------------------------------------------------------
// File          : L4_decoder.v
// Author        : John Nestor  <nestorj@lafayette.edu>
// Created       : 16.07.2004
// Last modified : 16.07.2004
//-----------------------------------------------------------------------------
// Description : decoder with four functions based on the value of sel_range
//    000: disabled => 00000
//    001: decoder based on lower only
//    010: decoder based on upper only
//    011: range decoder
//    100: select entire range
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2004 by Lafayette College This model is the confidential and
// proprietary property of Lafayette College and the possession or use of this
// file requires a written license from Lafayette College.
//------------------------------------------------------------------------------
// Modification history :
// 16.07.2004 : created based on L3_decoder.v, but modified with
//    registered outputs to reduce clock period
// 22.07.2004 : changed enable to sel_range
//-----------------------------------------------------------------------------

`include "L4_decs.v"

module L4_decoder(clk, sel_range, lower, upper, decout);
   parameter DEC_INBITS=4;
   parameter DEC_OUTBITS=16;

   input                    clk;
   input [2:0]              sel_range;
   input [DEC_INBITS-1:0]   lower, upper;
   output [DEC_OUTBITS-1:0] decout;
   reg [DEC_OUTBITS-1:0]    decout;
   
   reg [DEC_OUTBITS-1:0]    decout_next;
   
   reg                      carry;
   integer                  i;

   
   always @(sel_range or lower or upper)
     begin
	carry = 1'b0;
        for (i=0; i < DEC_OUTBITS; i=i+1 )
          begin
	     decout_next[i] = 1'b0;  // default
	     case (sel_range)
	       `DECODE_DISABLE:
		 decout_next[i] = 0;
	       `DECODE_LOWER: 
		 if (lower == i) decout_next[i] = 1'b1;
	       `DECODE_UPPER:
		 if (upper == i) decout_next[i] = 1'b1;
	       `DECODE_RANGE:
		 begin
		    if (lower == i || carry)
		      begin
			 decout_next[i] = 1;
			 carry = 1'b1;
		      end
		    if (upper == i) carry = 1'b0;
		 end
	       `DECODE_ALL:
		  begin
		     decout_next[i] = 1'b1;
		  end
	       default:
		 decout_next[i] = 0;
             endcase // case(sel_range)
          end
//	$display("%t L4_decoder sel_range=%d lower=%d upper=%d decout_next=%b", $time, sel_range, lower, upper, decout_next);
     end // always
   
   always @(posedge clk)
     decout <= decout_next;
   
   
endmodule

