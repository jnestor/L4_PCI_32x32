module L4_layercounter(clk, resetn, en, layer, top_l, bottom_l);
    parameter           NLBITS  = 3;
    parameter           NLAYERS = 8;
    input               clk;
    input               resetn;
    input               en;
    output [NLBITS-1:0] layer;
    output              top_l;
    output              bottom_l;

    reg    [NLBITS-1:0] layer;

assign top_l = !(layer == NLAYERS-1);

assign bottom_l = !(layer == 0);

always @(posedge clk)
begin
    if (!resetn || (!top_l && en)) layer <= 0;
    else if (en) layer <= layer + 1;
end

endmodule
