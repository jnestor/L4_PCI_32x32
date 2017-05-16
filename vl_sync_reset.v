`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    16:39:33 03/02/06
// Design Name:    
// Module Name:    sync_reset
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:  Given a reset input that is only one fast clock period long, 
//               generate a reset output that is synchronized to a slower clock.
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module sync_reset(fast_clk, slow_clk, clr, reset_in, reset_out);
    input fast_clk;
    input slow_clk;
    input clr;
    input reset_in;
    output reset_out;

	 reg reset_out;
	 reg reset_presync;
	 reg cs, ns;

	 parameter WAITF1=1'b0, WAITS1=1'b1;

	 always @(posedge fast_clk)
	   if (clr) cs <= WAITF1;
          else cs <= ns;

    always @(posedge slow_clk)
	   reset_out <= reset_presync;

    always @(reset_in or cs or reset_out)
	   begin
		  reset_presync = 1'b0;
		  case (cs)
		    WAITF1:	// wait for reset_input to go high
			   begin
				  if (reset_in) ns = WAITS1;
				  else ns = WAITF1;
            end
          WAITS1: // wait for slow clock to change reset_out
			   begin
				  reset_presync = 1'b1;
				  if (reset_out) ns = WAITF1;
				  else ns = WAITS1;
				end
        endcase
      end // always


endmodule
