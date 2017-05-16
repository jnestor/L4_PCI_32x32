`include "L4_decs.v"


module L4_cell(clk, etch_enb, ni, si, wi, ei, rsel, csel, top_l,
                   pref_ud, pref_ew, pref_ns, cmd, status_in, ret2ue, extend, status_out, xo);
   input          clk, ni, si, wi, ei, rsel, csel, top_l,
                  pref_ud, pref_ew, pref_ns, etch_enb;
   input [1:0] 	  cmd;
   input [3:0] 	  status_in;
	input ret2ue;
	input			extend;
   output [3:0]   status_out;
   output 	  xo;
   reg [3:0] 	  status_next;
   // reg [3:0] 	  status_out;	// move register to L4_array32x32 4/9/06
   parameter      NLAYERS = 8;
   
	
   wire           is_sel;

	// 5-bit contents of layers[i], cs, ns:
	// cs[4] = return-to-unetchable flag for extended routing
	// cs[3] = etched flag
	// cs[2:0] = simple cell state
   reg [4:0] 	  layers [NLAYERS-1:0];
   wire [4:0] 	  cs;                // alias for layers[0]
   assign         cs = layers[0];
   reg [4:0] 	  ns;
   wire           ui;
   reg            di;  // saves expand status of previous layer
   integer        i;     // loop counter for shift reg.
   

	wire cs_dir, cs_traced, cs_etched;
	assign cs_dir = (cs[2:0] ==`XE || cs[2:0] ==`XW ||
			 			  cs[2:0] ==`XN || cs[2:0] ==`XS || 
			 			  cs[2:0] ==`XU || cs[2:0] ==`XD   );
	assign cs_traced = (cs[3:0]==`TRACED);
	assign cs_etched = cs[3];

	// in expanded state
   assign 	  xo  = (cs_dir || (extend && cs_traced) );
   
   assign 	  is_sel = rsel & csel;
   
   assign 	  ui = (layers[1][2:0]==`XE || layers[1][2:0]==`XW ||
                 	layers[1][2:0]==`XN || layers[1][2:0]==`XS || 
                 	layers[1][2:0]==`XU || layers[1][2:0]==`XD ||
						(extend==1 && layers[1][3:0]==`TRACED) ) && (top_l == 1'b1);
   
   
   // clocked always block implements *layers* shift register
   // and *di* flag register
   
   always @(posedge clk)
     begin
        // if we're shifting from one layer to another, latch expand
        // state of current layer as "di" input for next layer up (except at top!)
	
        if (pref_ud)
          begin
            if (top_l != 1'b0) di <= xo;
            else di <= 1'b0;
          end
	
        // now do the shift-register
	
         if (pref_ud)
	    begin
             for(i=0; i <= NLAYERS-2; i=i+1)
               layers[i] <= layers[i+1];
             layers[NLAYERS-1] <= ns;
	    end
         else 
	    begin
             layers[0] <= ns; // recirculate on same layer for horiz-only expansion
	       // $display($time, " layers[0]=%d cs=%d ns=%d", layers[0], cs, ns);
	    end

	//status_out <= status_next;
	
     end
   
   assign status_out = status_next;

   always @(cs or ni or si or wi or ei or ui or di or is_sel or
            cmd or xo or pref_ud or pref_ew or pref_ns or status_in or etch_enb or extend
				or cs_dir or cs_etched or cs_traced or ret2ue)
     begin
        status_next = 4'b1111;
        ns = cs;  // default behavior
        case (cmd)
          `CLEARX:
		  		begin
					if(cs_dir || (cs_traced && !extend))
					begin
						ns[4] = 0;
						if(cs[4])
							ns[3:0] = `UNETCHABLE;
						else if (!cs_etched)
							ns[3:0] = `UNETCHED_EMPTY;
		  				else
							ns[3:0] = `UNETCHED_BLOCKED;
					end
	  	  		end
          `WRITE:
            if (is_sel) begin
					ns[3:0] = status_in;
					ns[4] = ret2ue;
				end
	  
          `EXPAND:
            begin
              if ((cs[3:0] == `UNETCHED_EMPTY)|| (etch_enb&& (cs[3:0]==`UNETCHED_BLOCKED))) // only expnd when empty!
                begin
                    if (ei && pref_ew)      ns[3:0] = {etch_enb, `XE};
                    else if (wi && pref_ew) ns[3:0] = {etch_enb, `XW};
                    else if (ni && pref_ns) ns[3:0] = {etch_enb, `XN};
                    else if (si && pref_ns) ns[3:0] = {etch_enb, `XS};
                    else if (ui && pref_ud) ns[3:0] = {etch_enb, `XU};
                    else if (di && pref_ud) ns[3:0] = {etch_enb, `XD};
                    if ( (ei && pref_ew) || (wi && pref_ew) ||
                         (ni && pref_ns) || (si && pref_ns) ||
                         (ui && pref_ud) || (di && pref_ud) )
                      begin
                         status_next[1] = 1'b0;
                         if (is_sel) status_next[0] = 1'b0;
                      end
                end
               if (xo && is_sel) status_next[0] = 1'b0;
            end
	  
          `READ:
            if (is_sel)
              begin
                 status_next = cs[3:0];
              end
	  
          default:
            begin
               $display($time, " WARNING: case not covered (CMD=%3b)", cmd);
               ns = {2'b0, `EMPTY};
            end
        endcase
     end
   
endmodule
