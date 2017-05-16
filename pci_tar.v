// ************************************************************************
// $Header: //Dosequis/d/rcs_proj/dn3k10s/fpgacode/rcs/pci_tar.v 1.11 2001/12/27 21:55:48Z mperry Exp $
// ************************************************************************
// 06/18/99 NAP: Initial Revision
// 06/29/99 NAP: Fixed a bunch of bugs (and simplified the code).
// 06/29/99 NAP: Changed the addresses used so that all A0 of the flash isn't
//                  used and the other bits are changable.
// 07/02/99 NAP: Removed onchip_reg1 so that interconnect registers in fpga_f
//                  would work.
// 07/06/99 NAP: Changed the class code so that it is a vaild number.
// 07/08/99 NAP: Undid a major change in the parameters that shouldn't have
//                  been changed (looked like somebody did a sequential 
//                  numbering on them).
// 11/22/99 NAP: Changed the function for perr_l (so that it wouldn't give
//                  extra assertions during the last clock cycle when it 
//                  should always be driven high).
//               Removed the incorrect logic for serr_l, and forced it to 
//                  tri-state always.
// 01/05/00 JWP: removed double declaration of par_reg
// 04/10/00 NAP: Removed unused "trdy_ena" signal.
//               Used a parameter for the delay on asserting TRDY.
// 06/20/00 JWP: changed comment about Bars
// 09/26/00 JWP: added 32 bit capabilities
// 11/01/00 JWP: added second ad_reg in order to use IOB
// 11/01/00 JWP: added internal trdy, devsel, stop to improve IO timing
// 11/01/00 JWP: changed one more trdy use to internal version
// 11/07/00 JWP: changed bar match to get better timing
// 03/02/01 NAP: changed comments about amount of memory allocated
// 06/28/01 MWP: copied and edited for dn3000k10
// 09/18/01 MWP: trdy is now based on timer for configuration reads/writes,
//                  but based on input signal for normal reads/writes.
// 11/28/01 MWP: made BAR0 smaller
// ************************************************************************

/*************************************************************************/
/*  pci_tar.v                                                            */
/*                                                                       */
/*  target only reference pci design - ONE module only                   */
/*                                                                       */
/*************************************************************************/

module pci_tar(
        pci_clk,
        ad,
        c_be_n,
        par,
        perr_l,
        serr_l,
        frame_n,
        irdy_n,
	trdy_input,
        trdy_n,
        devsel_n,
        idsel,
        rst_n,
        stop_n,

//	bar_select,
        addr_offset,
        data_wr,
        data_rd,
        wr_n,
        rd_n,
	c_be,
	SDRAMinit // initialize SDRAM at config access
        );
// parameter num_parts = 3;

input  rst_n;                // PCI master reset
input  pci_clk;                  // pci clock
inout  [31:0] ad;            // multiplexed address/data
input  [3:0] c_be_n;         // command/byte enable
input  idsel;                // initialize device select
input  frame_n;              // transfer frame
input  irdy_n;               // initiator ready
input  trdy_input;           // target ready initiated at FPGA
output  trdy_n;               // target ready
output  stop_n;               // stop request
output  devsel_n;             // device selected
inout  par;                  // parity
output perr_l;
output serr_l;
//output [2:0] bar_select;
output [26:0] addr_offset;   // address offset within each device
//output [num_parts-1:0] part_select; address of which device to access (6 fpgas, 1flash, 1 cpld)
output [31:0] data_wr;       // data from device to back end
input  [31:0] data_rd;       // data to device from back end
output wr_n;                  // write strobe to back end
output rd_n;                  // read strobe to backend
output [3:0] c_be;

output SDRAMinit; // initialize SDRAM at config access

// main state machine states
parameter idle      = 7'h01;  // 0000 0001
parameter comp_addr = 7'h02;  // 0000 0010
parameter s_data    = 7'h04;  // 0000 0100
parameter turn_ar   = 7'h08;  // 0000 1000
parameter bus_busy  = 7'h10;  // 0001 0000
parameter backoff   = 7'h20;  // 0010 0000
parameter state_cfg = 7'h40;  // 0100 0000

// configuration space address
parameter did_vid     = 8'h00;
parameter pcists_cmd  = 8'h04;
parameter clcd_rid    = 8'h08;
parameter bist_etc    = 8'h0c;
parameter cbcisptr    = 8'h28;
parameter subsid_vid  = 8'h2c;
parameter exrom       = 8'h30;
parameter max_lat_etc = 8'h3c;

// configuration space parameters
parameter VENDOR_ID       = 16'hABCD;
parameter DEVICE_ID       = 16'h1234;
parameter REVISION_ID     = 8'h47;
parameter CLASS_CODE      = 24'hFF0000;
parameter PCISTATUS       = 16'h0;
parameter HEADER_TYPE     = 8'h00;
parameter CISPTR          = 32'h0;
parameter BIST            = 8'h48;
parameter SUBSVID         = 16'h5678;
parameter SUBSID          = 16'h90AB;

// target ready delay parameter
parameter trdy_delay      = 4'hA;     // trdy delay parameter

reg [31:5] bar_0;            // base address register
reg [31:5] bar_1;            // base address register
reg [31:0] config_data;      // latch the ad[] lines to back end
reg adoe;                    // address/data output enable control
reg devsel_n_reg;              // devsel register
reg devsel_reg_int;              // devsel register
reg trdy_n_reg;                // target ready register
reg trdy_reg_int;                // target ready register
reg trdy_d;
reg trdyoe;                  // target ready output enable
reg [3:0] trdy_delay_cnt;    // trdy delay counter
reg stop_n_reg;                // stop register
reg stop_reg_int;                // stop register
reg [6:0] target;            // main state machine
reg [9:0] pcicmd_reg;        // command register
reg rdwr;                    // read/write strobe
reg [31:0] addr;             // latch ad[] address phase to back end
reg [31:0] ad_d;             // ad[] input latch
reg [3:0] c_be_n_d;          // c_be_n input latch
reg wr_rd;                   // read/write cycle
reg frame_d;
reg frame_dd;
reg irdy_d;

reg write_access;
wire read_access; // negation of write_access

wire frame;
wire irdy;
wire rst;
// wire reset;	    // commented out - never used JN 6/17/04
wire [3:0]c_be;
wire [31:0] ad;              // address output with tristate
wire rd_n;
wire wr_n;
wire [15:0] pcicmd;          // command register
wire bar_match_any;          // any BAR match other FPGA's
wire bar0match;              // BAR match FLASH
wire bar1match;              // BAR match non-flash registers

reg [31:0] data_wr;       // data from device to back end

reg bar_match_any_d;

assign frame     = !frame_n;
assign irdy      = !irdy_n;
assign rst       = !rst_n;
assign c_be[3:0] = ~c_be_n_d[3:0];
assign rd_n = !(rdwr & wr_rd & bar_match_any_d);
assign wr_n = !(rdwr & !wr_rd & bar_match_any_d);
assign pcicmd[15:0] = {6'b0, pcicmd_reg[9:0]};

always @ (posedge pci_clk or posedge rst) begin
    if (rst) begin
        data_wr[31:0] <= 'b0;
        bar_match_any_d <= 1'b0;
    end else begin
        bar_match_any_d <= bar_match_any;
        if ( irdy & bar_match_any )
           data_wr[31:0] <= ad[31:0];
    end
end

assign read_access = ~write_access;

// state machine
always @ (posedge pci_clk or posedge rst)
    begin
        if (rst) begin
            target <= idle;
            write_access <= 1'b0;
        end else begin
            case(target)
                idle:
                    if ( frame & (~frame_d) ) begin
                        if(idsel & (c_be_n[3:1] == 3'b101))
                            target <= state_cfg;   // configuration access
                        else if(c_be_n[3:1] == 3'b011)
                            target <= bus_busy;   // memory read/write cycle
                        write_access <= c_be_n[0];
                    end else 
                        target <= idle;

            bus_busy:
                target <= comp_addr;

            comp_addr:
                if(bar_match_any)
                    target <= s_data;
                else
                    target <= idle;

            s_data:
                if(!(trdy_reg_int & irdy))
                    target <= s_data;
                else if(irdy & trdy_reg_int & !frame) // check trdy or trdy_reg
                    target <= idle;
                else if(irdy & trdy_reg_int & frame)
                    target <= backoff;

            backoff:
                if(frame)
                    target <= backoff;
                else
                    target <= turn_ar;  // Neal, doesn't seem right...


            state_cfg:
                if(!(irdy & trdy_reg_int))
                    target <= state_cfg;
                else if(irdy & trdy_reg_int & !frame)
                    target <= idle;
                else if(irdy & trdy_reg_int & frame)
                    target <= backoff;

            turn_ar:
                target <= idle;

            default:
                target <= idle;
        endcase
    end
end  // state machine

assign SDRAMinit = frame & (~frame_d) & idsel & (c_be_n[3:0] == 4'hb);

// write to configuration registers
always @(posedge pci_clk or posedge rst)
begin
    if (rst) begin
        bar_0[31:5] <= 27'b0;
        bar_1[31:5] <= 27'b0;
        pcicmd_reg[9:0] <= 10'b0;
    end else begin
        pcicmd_reg[8] <= 1'b0;
        bar_0[22:5] <= 'b0;
        bar_1[27:5] <= 'b0;
        if( (target == state_cfg) & write_access ) begin
            case(addr[5:2])
                4'h1: begin // status/command
                    pcicmd_reg[9] <= ad_d[9];
                    if(c_be[0])
                        pcicmd_reg[7:0]  <= ad_d[7:0];
                end
                4'h4: begin // 128Mbytes of memory space
                    if(c_be[3])
                        bar_0[31:24] <= ad_d[31:24];
                    if(c_be[2])
                        bar_0[23] <= ad_d[23];
                end
                4'h5: begin // 128Mbytes of memory space
                    if(c_be[3])
                        bar_1[31:28] <= ad_d[31:28];
                end
            endcase // case(addr[7:0])
        end // if(target == state_cfg & write_access)
    end
end

// latch address from ad_d
always @(posedge pci_clk or posedge rst)
begin
    if (rst) begin
        addr[31:0] <= 32'b0;
    end else begin
        if ((~frame_dd) & frame_d)
            addr[31:0] <= ad_d[31:0];
    end
end

    // bar_select gives the number of the BAR accessed, or 7 if no bar-match
//assign bar_select[2] = !(bar0match | bar1match); // | bar2match | bar3match);
//assign bar_select[1] = !(bar0match | bar1match); // | bar4match | bar5match);
//assign bar_select[0] = !(bar0match); // | bar2match | bar4match);
    // addr_offset[22:1] are used by the FLASH
    // addr[27:2] are valid PCI offset address bits in bar1
    // addr[22:2] are valid PCI offset address bits in bar0
assign addr_offset[25:0] = addr[27:2];
assign addr_offset[26] = bar1match;

// readback registers/mux
always @(posedge pci_clk or posedge rst) begin
    if (rst) begin
        config_data[31:0] <= 32'b0;
    end else begin
        case(addr[7:0])
            did_vid:
                config_data[31:0] <= {DEVICE_ID[15:0], VENDOR_ID[15:0]};
            pcists_cmd:
                config_data[31:0] <= {PCISTATUS[15:0], pcicmd[15:0]};
            clcd_rid:
                config_data[31:0] <= {CLASS_CODE[23:0], REVISION_ID[7:0]};
            8'h10: // 16Mbytes of memory space
                config_data[31:0] <= {bar_0[31:5], 5'b0};
            8'h14: // 16Mbytes of memory space
                config_data[31:0] <= {bar_1[31:5], 5'b0};
            subsid_vid:
                config_data[31:0] <= {SUBSID[15:0], SUBSVID[15:0]};
            default:
                config_data[31:0] <= 32'h0;
        endcase
    end
end

reg [31:0] ad_reg;
reg [31:0] ad2_reg;
assign ad[31:0] = (adoe ? ad_reg[31:0] : 32'bz);

always @(posedge pci_clk or posedge rst)
begin
    if(rst) begin
        ad_reg[31:0] <= 32'h0;
        ad2_reg[31:0] <= 32'hffffffff;  // so not optimized out
    end else begin
        if (bar_match_any) begin
            ad_reg[31:0] <= data_rd[31:0];
            ad2_reg[31:0] <= data_rd[31:0];
        end else begin
            ad_reg[31:0] <= config_data[31:0];
            ad2_reg[31:0] <= config_data[31:0];
                end
    end
end

// adoe controls when ad[] is driven. It is asserted at the same clock
// cycles as devsel.
always @(posedge pci_clk or posedge rst)
begin
    if(rst) begin
        adoe <= 1'b0;
    end else begin
            // drive AD upon the start of an accepted read access
        if ( read_access ) begin
            if ( target == state_cfg )
                adoe <= 1'b1;
            if ( (target == comp_addr) & bar_match_any )
                adoe <= 1'b1;
        end

        if ( (~frame) & irdy & (trdy_reg_int | stop_reg_int) )
            adoe <= 1'b0;
    end
end


// counter delays trdy.
always @(posedge pci_clk or posedge rst)
begin
    if(rst)
        trdy_delay_cnt[3:0] <= 0;
    else if (irdy) begin
        if (trdy_delay_cnt[3:0] != 4'hf)
            trdy_delay_cnt[3:0] <= trdy_delay_cnt[3:0] + 1;
    end else
        trdy_delay_cnt[3:0] <= 4'b0;
end

assign trdy_n = (trdyoe ? trdy_n_reg : 1'bz);
assign devsel_n = (trdyoe ? devsel_n_reg : 1'bz);
assign stop_n = (trdyoe ? stop_n_reg : 1'bz);

// trdy_reg enables trdy 12 clock cycles after irdy is asserted.
// Speed isn't critical...better safe than sorry.
always @(posedge pci_clk or posedge rst)
begin
    if(rst) begin
        trdy_n_reg <= 1'b1;
        trdy_reg_int <= 1'b0;
    end else begin
        if(irdy) begin
           if (target == state_cfg) begin
             trdy_n_reg <= !(trdy_delay_cnt[3:0] == trdy_delay);
             trdy_reg_int <= (trdy_delay_cnt[3:0] == trdy_delay);
           end else begin
             trdy_n_reg <= !trdy_input;
             trdy_reg_int <= trdy_input;
           end
        end else begin
           trdy_n_reg <= 1'b1;
           trdy_reg_int <= 1'b0;
        end
    end
end


// trdy should be asserted when the 2nd configuration cycle
// and remains aserted until irdy
// and trdy are asserted together
always @(posedge pci_clk or posedge rst)
begin
    if(rst)
        trdyoe <= 0;
    else
        trdyoe <=  ((target == comp_addr) & bar_match_any)
                 | (target == state_cfg)
                 | (target == s_data)
                 | (target == backoff);
end

// assert read or write strobe at  trdy_delay_cnt[3:0] == 4 to 11
always @(posedge pci_clk or posedge rst)
begin
    if(rst)
        rdwr <= 1'b0;
    //else if((trdy_delay_cnt[3:2] == 2'b10) || (trdy_delay_cnt[3:2] == 2'b01))
    //else if((trdy_delay_cnt[5:0] >= 4) && (trdy_delay_cnt[5:0] <= trdy_delay) && !trdy_input)
    else if((trdy_delay_cnt[3:0] >= 4) && !irdy_n)
        rdwr <= 1'b1;
    else
        rdwr <= 1'b0;
end


assign bar0match = (addr[31:23] == bar_0[31:23]) & pcicmd[1];
assign bar1match = (addr[31:28] == bar_1[31:28]) & pcicmd[1];
assign bar_match_any = bar0match | bar1match;

// devsel should be asserted from the time a match is determined until
// turn_ar is entered
always @(posedge pci_clk or posedge rst) begin
    if(rst) begin
        devsel_n_reg <= 1'b1;
        devsel_reg_int <= 1'b0;
    end else begin
        devsel_n_reg <= !(((target == comp_addr) & bar_match_any)
                     | ((target == state_cfg) & (!(irdy & trdy_reg_int) | frame))
                     | ((target == s_data) & (!(irdy & trdy_reg_int) | frame))
                     | ((target == backoff) & frame & devsel_reg_int));
        devsel_reg_int <=  ((target == comp_addr) & bar_match_any)
                     | ((target == state_cfg) & (!(irdy & trdy_reg_int) | frame))
                     | ((target == s_data) & (!(irdy & trdy_reg_int) | frame))
                     | ((target == backoff) & frame & devsel_reg_int);
    end
end

// Stop is asserted with trdy in a non-burst mode. It stays asserted until
// frame is deasserted.
always @(posedge pci_clk or posedge rst)
begin
    if (rst) begin
        stop_n_reg <= 1'b1;
        stop_reg_int <= 1'b0;
    end else begin
        stop_n_reg <= !(((trdy_reg_int & irdy) | stop_reg_int) & frame);
        stop_reg_int <= ((trdy_reg_int & irdy) | stop_reg_int) & frame;
    end
end

// wr_rd indicates read or write cycle
always @(posedge pci_clk or posedge rst)
begin
    if(rst)
        wr_rd <= 1;
    else
        wr_rd <=  ((target == bus_busy) && c_be[0])
                | ((target != idle) && wr_rd);
end

reg par_reg;   // JWP: line commented out, double declaration
reg par_oe;
reg perr_l_reg;
reg perr_l_oe;


always @(posedge pci_clk or posedge rst)
begin
    if(rst) begin
        c_be_n_d[3:0] <= 4'h0;
        frame_d <= 0;
        frame_dd <= 0;
        irdy_d <= 0;
        trdy_d <= 0;
        par_reg <= 1'b0;
        par_oe <= 1'b0;
        perr_l_reg <= 1'b0;
        perr_l_oe <= 1'b0;
        ad_d[31:0] <= 32'h0;
    end else begin
        ad_d[31:0] <= ad[31:0];
        c_be_n_d[3:0] <= c_be_n[3:0];
        frame_d <= frame;
        frame_dd <= frame_d;
        irdy_d <= irdy;
        trdy_d <= trdy_reg_int;

        par_reg <= (^(ad2_reg[31:0])) ^ (^(c_be_n[3:0]));
        par_oe <= adoe;

        perr_l_reg <= 1'b1;
        if ( trdy_d & irdy_d )
            if ( ((^ad_d[31:0]) ^ (^c_be_n_d[3:0])) != par)
                perr_l_reg <= 1'b0;
        perr_l_oe <= trdyoe;
    end
end

assign par = (par_oe ? par_reg : 1'bz);
assign perr_l = (perr_l_oe ? perr_l_reg : 1'bz);
//assign serr_l = (perr_l_oe ? perr_l_reg : 1'bz);
assign serr_l = 1'bz;

endmodule
