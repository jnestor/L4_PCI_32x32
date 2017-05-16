//
// L4_cyclecounter - counts the number of elapsed cycles when en is high.
// Used for performance measurements.
//
// 25 April 2006: removed saturation - software now deals with rollovers
//
// John Nestor, Lafayette College        July 2003


module L4_cyclecounter(clk, reset, en, count);
   parameter           NBITS  = 8;
   input 	       clk;
   input 	       reset;
   input 	       en;
   output [NBITS-1:0]  count;
   
   reg [NBITS-1:0]     count;
   
   always @(posedge clk)
     begin
	if (reset) count <= 0;
	else if (en) count <= count + 1;
     end
   
endmodule
