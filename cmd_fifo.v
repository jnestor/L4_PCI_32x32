/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used             *
*     solely for design, simulation, implementation and creation of            *
*     design files limited to Xilinx devices or technologies. Use              *
*     with non-Xilinx devices or technologies is expressly prohibited          *
*     and immediately terminates your license.                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"            *
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                  *
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION          *
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION              *
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS                *
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                  *
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE         *
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY                 *
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                  *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          *
*     FOR A PARTICULAR PURPOSE.                                                *
*                                                                              *
*     Xilinx products are not intended for use in life support                 *
*     appliances, devices, or systems. Use in such applications are            *
*     expressly prohibited.                                                    *
*                                                                              *
*     (c) Copyright 1995-2004 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synopsys directives "translate_off/translate_on" specified below are
// supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file cmd_fifo.v when simulating
// the core, cmd_fifo. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

`timescale 1ns/1ps

module cmd_fifo(
	din,
	wr_en,
	wr_clk,
	rd_en,
	rd_clk,
	ainit,
	dout,
	full,
	empty,
	wr_count,
	wr_ack,
	wr_err);


input [31 : 0] din;
input wr_en;
input wr_clk;
input rd_en;
input rd_clk;
input ainit;
output [31 : 0] dout;
output full;
output empty;
output [7 : 0] wr_count;
output wr_ack;
output wr_err;

// synopsys translate_off

      ASYNC_FIFO_V6_1 #(
		32,	// c_data_width
		0,	// c_enable_rlocs
		255,	// c_fifo_depth
		0,	// c_has_almost_empty
		0,	// c_has_almost_full
		0,	// c_has_rd_ack
		0,	// c_has_rd_count
		0,	// c_has_rd_err
		1,	// c_has_wr_ack
		1,	// c_has_wr_count
		1,	// c_has_wr_err
		0,	// c_rd_ack_low
		2,	// c_rd_count_width
		0,	// c_rd_err_low
		1,	// c_use_blockmem
		0,	// c_wr_ack_low
		8,	// c_wr_count_width
		0)	// c_wr_err_low
	inst (
		.DIN(din),
		.WR_EN(wr_en),
		.WR_CLK(wr_clk),
		.RD_EN(rd_en),
		.RD_CLK(rd_clk),
		.AINIT(ainit),
		.DOUT(dout),
		.FULL(full),
		.EMPTY(empty),
		.WR_COUNT(wr_count),
		.WR_ACK(wr_ack),
		.WR_ERR(wr_err),
		.ALMOST_FULL(),
		.ALMOST_EMPTY(),
		.RD_COUNT(),
		.RD_ACK(),
		.RD_ERR());


// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of cmd_fifo is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of cmd_fifo is "black_box"

endmodule

