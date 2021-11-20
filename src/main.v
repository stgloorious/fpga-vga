/**
* @file main.v
* @brief fpga-vga top-level file
*
*/

/**
* Defines top level interface
*
*/
module main (
	input clk_i, /** 12 MHz */
	input reset_ni,

	/* To VGA monitor */
	output [3:0] red_o,
	output [3:0] green_o,
	output [3:0] blue_o,
	output hsync_o,
	output vsync_o
);

/**
*	Pixel clock, must be 25.175 MHz for 640x480@60Hz mode
*	PLL does not achieve this exact value, but 
*	rather 25.125 MHz
*
*/
reg px_clk_r;
reg pll_lock_r;

wire px_clk; /** Output from PLL */
wire pll_lock;

assign px_clk = px_clk_r;
assign pll_lock = pll_lock_r;

pll u_pll (
	.clock_in(clk_i),
	.clock_out(px_clk),
	.locked(pll_lock)
);

vga u_vga (
	.clk_i(px_clk),
	.reset_ni(reset_ni),
	.red_o(red_o),
	.green_o(green_o),
	.blue_o(blue_o),
	.hsync_o(hsync_o),
	.vsync_o(vsync_o)
);

endmodule





