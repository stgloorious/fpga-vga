/**
* @file vga.v
* @brief Generates 3x4-bit RGB, HSYNC and VSYNC signals for VGA interface
* @note supported modes: 640x480@60Hz
*
*/

module vga (
	input clk_i, /** used as pixel clock, 25.175 MHz */
	input reset_ni,

	/* To VGA monitor */
	output [3:0] red_o,
	output [3:0] green_o,
	output [3:0] blue_o,
	output hsync_o,
	output vsync_o


);

endmodule
