// L4_decs.v - global definitions for multi-layer L4 machine
// John A. Nestor	August 2004

`ifndef L4_DECS

`define L4_DECS

// Cell Command Signals

`define CLEARX 2'b11
`define WRITE  2'b01
`define READ   2'b00
`define EXPAND 2'b10


// Cell State Codes

`define EMPTY   3'b111
`define BLOCKED 3'b101
`define XE      3'b000
`define XW      3'b001
`define XN      3'b010
`define XS      3'b011
`define XU      3'b100
`define XD      3'b110

`define UNETCHED_EMPTY		4'b0111
`define UNETCHED_BLOCKED	4'b0101
`define UNETCHED_XE			4'b0000
`define UNETCHED_XW			4'b0001
`define UNETCHED_XN			4'b0010
`define UNETCHED_XS			4'b0011
`define UNETCHED_XU			4'b0100
`define UNETCHED_XD			4'b0110

`define ETCHED_EMPTY		4'b1111
`define ETCHED_BLOCKED	4'b1101
`define ETCHED_XE			4'b1000
`define ETCHED_XW			4'b1001
`define ETCHED_XN			4'b1010
`define ETCHED_XS			4'b1011
`define ETCHED_XU			4'b1100
`define ETCHED_XD			4'b1110

`define UNETCHABLE `ETCHED_EMPTY
`define TRACED		 `ETCHED_BLOCKED




// Number of layers

`define N_LAYERS 4
`define N_LAYERBITS  2  // log2(NLAYERS)

// Control codes for row & col decoders

`define DECODE_DISABLE  3'b000
`define DECODE_LOWER    3'b001
`define DECODE_UPPER    3'b010
`define DECODE_RANGE    3'b011
`define DECODE_ALL      3'b100

// Commmand Opcodes

`define C_ROUTE_EXTEND_INIT 2'b00
`define C_ROUTE 2'b01
`define C_SELECT 2'b10
`define C_EXTENDED 2'b11
`define CF_WRITE 4'd0
`define CF_READ 4'd1
`define CF_CLEAR_ARRAY 4'd2
`define CF_WRITE_ARRAY 4'd3

`define CF_READ_ARRAY 4'd4
`define CF_CLEARX 4'd5
`define CF_EXPAND 4'd6
`define CF_ROUTE_EXTEND 4'd7
`define CF_GET_XCOUNT 4'd8
`define CF_GET_TCOUNT 4'd9

`define C_EXTEND_FILL 26'd0
`define C_WRITE_FILL 22'd0

// Status returned from Commands -- change width and values of this later?
`define RESULT_ETCH    3'd0
`define RESULT_SUCCESS 3'd1
`define RESULT_XFAIL   3'd2
`define RESULT_TFAIL   3'd3
`define RESULT_TRACE   3'd4
`define RESULT_XCOUNT 3'd5
`define RESULT_TCOUNT 3'd6
`define RESULT_STATUS  3'd7

`endif