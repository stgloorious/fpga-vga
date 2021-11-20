/**
* @file main.v
* @brief fpga-vga top-level file
*
*/


module main (
	input clk_i, /** 12 MHz */
	input reset_ni,

	/* To VGA monitor */
	output red[3:0],
	output green[3:0],
	output blue[3:0],
	output hsync,
	output vsync

);

wire px_clk;
wire pll_lock;

pll u_pll (
	.clock_in(clk_i),
	.clock_out(px_clk),
	.locked(pll_lock)
)
