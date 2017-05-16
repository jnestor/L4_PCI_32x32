// **************************************************************************
// $Header: //Dosequis/D/rcs_proj/dn3k10s/fpgacode/rcs/fpga.v 1.36 2002/07/31 20:45:00Z mperry Exp mperry $
// **************************************************************************
// 06/28/01 MWP: initial revision based on DN2000K10 test design
// 08/15/01 MWP: added clock domain transfer in each memory controller
//		 pci_tar now accepts trdy from memory controllers
// 10/18/01 MWP: added Digital Clock Managers to improve timing
// 10/23/01 MWP: added multipliers
// 10/27/01 MWP: added EEPROM reader to read SDRAM specifications
// 11/09/01 MWP: added board test from microprocessor
// 11/28/01 MWP: rearranged memory map, made BAR0 smaller
// 03/27/02 MWP: finished debugging timing for microprocessor test
// 05/03/02 MWP: replaced old PCI core with OpenCore
// 05/07/02 MWP: registered addr/data coming out of OpenCore; timing fixes
// 06/24/02 MWP: added DMA core and simulated, fixed minor bugs
// 07/31/02 MWP: moved clock domain change from sramctrl.v to this file
// **************************************************************************

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 * File Name: fpga.v                                                       *
 *                                                                         *
 * Description: Top-level file from Dini                                                           *
 *                                                                         *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */




module fpga (
    rst_n, // pci_reset_l
    pci_clk,
    ad, // [31:0] was [63:0]
    c_be_n, // [3:0] was [7:0]
    idsel, frame_n, irdy_n, trdy_n, devsel_n, stop_n, par,
	// unused PCI io signals
    //req64_l, ack64_l, par64
   // inta_l, //intb_l, intc_l, intd_l, sbo_l, sdone,
   // req_l,
   // gnt_l,
    perr_l,
    serr_l,
    //lock_l,

    //uP signals
   // Din, DIND0F, csb_n, FWRTSM_n, INITF_n, DOUTBSYF,

    /* aclk, bclk,*/ cclk, // dclk, eclk, fclk,// mbck,
 /*   P0N, // [77:0]
    P1N, // [77:0]
    P2N, // [93:0]
    P3N, // [91:0]
    P4N, // [29:0]
    P5N, // [26:0]
    P6N, // [93:0]
    P7N, // [93:0]
    P0NX, // [13:0]
    P1NX, // [13:0]
    P2NX, // [11:0]
    P3NX, // [11:0]
    P4NX, // [13:0]
    P5NX, // [13:0]
    P6NX, // [11:0]
    P7NX // [11:0]	 */

  );

input  rst_n;                // PCI master reset
input  pci_clk;               // pci clock
//input  [7:0] c_be_n;         // command/byte enable
input  [3:0] c_be_n;         // command/byte enable
//inout  [63:0]  ad;           // multiplexed address/data
inout [31:0] ad;
input  idsel;                // ID select
input  frame_n;              // transfer frame
input  irdy_n;               // initiator ready
output  trdy_n;               // target ready
output  devsel_n;             // device select
output  stop_n;               // stop request
inout  par;                  // parity
    // unused IO
//inout req64_l; inout ack64_l; inout par64;
//inout inta_l;
//inout intb_l; inout intc_l; inout intd_l; inout sbo_l; inout sdone;
//output req_l;
//input gnt_l;
output perr_l;
output serr_l;
//inout lock_l;

//inout [7:1] Din;
//inout DIND0F;
//input csb_n, FWRTSM_n, INITF_n, DOUTBSYF;

/*
input  aclk;               // OSC1
input  bclk;               // CPLD reference clock
*/
input  cclk;               // clock
/*
input  dclk;               // fpga/SDram clock
input  eclk;               // clock
input  fclk;               // fpga/SSram clock			 */
/*inout [8:0] mbck;          // daughtercard clocks

inout [77:0] P0N;
inout [77:0] P1N;
inout [93:0] P2N;
inout [91:0] P3N;
inout [29:0] P4N;
inout [26:0] P5N;
inout [93:0] P6N;
inout [93:0] P7N;
inout [13:0] P0NX;
inout [13:0] P1NX;
inout [11:0] P2NX;
inout [11:0] P3NX;
inout [13:0] P4NX;
inout [13:0] P5NX;
inout [11:0] P6NX;
inout [11:0] P7NX;
*/
// ************************************************************************

  wire L4_clk = cclk; // change to independent connection for larger arrays
  wire rst = !rst_n;

  // signals to and from backend slave
  wire wr_n, rd_n;
  wire [26:0] addr_offset;
  wire [31:0] data_wr;
  wire [3:0] byte_enable;
  reg [31:0] data_rd;
  wire trdy_done;

 

// ************************************************************************

  pci_tar TOP (
	  .pci_clk(pci_clk), .ad(ad), .c_be_n(c_be_n), .par(par), .perr_l(perr_l),
	  .serr_l(serr_l), .frame_n(frame_n), .irdy_n(irdy_n), .trdy_input(trdy_done),
	  .trdy_n(trdy_n), .devsel_n(devsel_n), .idsel(idsel), .rst_n(rst_n), .stop_n(stop_n),
	  .addr_offset(addr_offset), .data_wr(data_wr), .data_rd(data_rd), .wr_n(wr_n), .rd_n(rd_n), 
	  .c_be(byte_enable), .SDRAMinit(SDRAMinit) );

/******************** BACKEND INTERFACE ********************/
// This section selects appropriate read data based on address

  parameter MAGIC_NUMBER = 32'hFEEDBEEF; // a random value to test read_only

  reg wr_n_d, rd_n_d;
  wire wr_n_fe, rd_n_fe;	  // asserted for one clock tick on falling edge of wr_n, rd_n
  wire csel;

  assign csel = addr_offset[26] == 1'b0;

  // delays for falling edge detector
  always @(posedge pci_clk or posedge rst)
    if (rst) begin
	   wr_n_d <= 1'b1;
		rd_n_d <= 1'b1;
    end else begin
	   wr_n_d <= wr_n;
		rd_n_d <= rd_n;
    end
  
  // falling edge detectors
  assign wr_n_fe = ~wr_n & wr_n_d;
  assign rd_n_fe = ~rd_n & rd_n_d;

  assign trdy_input = rd_n_fe | wr_n_fe;

  wire [31:0] data_rd_result, data_rd_status;


  // multiplexer for reads
  always @(posedge pci_clk or posedge rst)
    if (rst) data_rd <= 32'd0;
    else data_rd <= ( addr_offset[0] ? data_rd_status : data_rd_result );

  // delay unit (shift register) for trdy
  reg [3:0] trdy_delay;

  always @(posedge pci_clk or posedge rst)
    if (rst)
	   trdy_delay <= 4'd0;
    else begin
      trdy_delay[0] <= csel & (wr_n_fe | rd_n_fe);
	   trdy_delay[3:1] <= trdy_delay[2:0];
    end

  assign trdy_done = trdy_delay[2];


//********************************************************************************************


wire        cfifo_full, cfifo_empty, rfifo_full, rfifo_empty;
wire [31:0] cmd_in, result_out;	 // between FIFO and L4
wire        cfifo_wr, cfifo_rd, rfifo_wr, rfifo_rd;
wire [7:0]  cfifo_count, rfifo_count;
assign      cfifo_wr = wr_n_fe & ~addr_offset[0];
assign      rfifo_rd = rd_n_fe & ~addr_offset[0];	

wire L4_reset_in, L4_reset;
//wire L4_cycle_reset_in, L4_cycle_reset;
assign      L4_reset_in = (wr_n_fe & addr_offset[0]) | rst; // reset when write to port 4
// assign      L4_cycle_reset_in = (wr_n_fe & addr_offset[1]); // cycle reset when write to port 8

sync_reset SYNCR(.fast_clk(pci_clk), .slow_clk(L4_clk), 
                 .reset_in(L4_reset_in), .reset_out(L4_reset));

/* sync_reset SYNCR2(.fast_clk(pci_clk), .slow_clk(L4_clk), 
                 .reset_in(L4_cycle_reset_in), .reset_out(L4_cycle_reset));    */

wire [5:0] ctl_state; // include in top byte of status word	  

// status word - add more flags later (e.g. count)
assign      data_rd_status = { 2'd0, ctl_state,
                               2'b00,rfifo_full, rfifo_empty, rfifo_count, 
                               2'b00, cfifo_full, cfifo_empty, cfifo_count };


cmd_fifo CFIFO(
  .din(data_wr),
  .wr_en(cfifo_wr),
  .wr_clk(pci_clk),
  .rd_en(cfifo_rd),	
  .rd_clk(L4_clk),	
  .ainit(L4_reset),
  .dout(cmd_in),
  .full(cfifo_full),
  .empty(cfifo_empty),
  .wr_count(cfifo_count),
  .wr_ack(cfifo_ack),
  .wr_err(cfifo_err));

result_fifo RFIFO(
	.din(result_out),
	.wr_en(rfifo_wr),
	.wr_clk(L4_clk),
	.rd_en(rfifo_rd),
	.rd_clk(pci_clk),
	.ainit(L4_reset),
	.dout(data_rd_result),
	.full(rfifo_full),
	.empty(rfifo_empty),
	.rd_count(rfifo_count),
	.rd_ack(rfifo_ack),
	.rd_err(rfifo_err)
);

//NOT CONNECTED IO
wire [3:0] status_reg;
wire [1:0] cur_layer; 


                

L4_all32x32 array(.clk(L4_clk), .resetn(!L4_reset), /*.cycle_reset(L4_cycle_reset),*/ .cmd_empty(cfifo_empty), .cmd_in(cmd_in), 
                .cmd_rd(cfifo_rd), .result_full(rfifo_full), .result_out(result_out), 
			 .result_wr(rfifo_wr), .ctl_state(ctl_state), .status_reg(status_reg), 
			 .cur_layer(cur_layer));   




endmodule




