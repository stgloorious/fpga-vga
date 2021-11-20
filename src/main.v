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
wire px_clk; /** Output from PLL */
wire pll_lock;

wire [3:0] red_i;
wire [3:0] green_i;
wire [3:0] blue_i;
wire [9:0] x_o;
wire [9:0] y_o;

reg [3:0] red;
reg [3:0] green;
reg [3:0] blue;

assign red_i = red;
assign green_i = green;
assign blue_i = blue;

pll u_pll (
	.clock_in(clk_i),
	.clock_out(px_clk),
	.locked()
);

vga u_vga (
	.clk_i(px_clk),
	.reset_ni(reset_ni),
	.red_i(red),
	.green_i(green),
	.blue_i(blue),
	.x_o(x_o),
	.y_o(y_o),
	.red_o(red_o),
	.green_o(green_o),
	.blue_o(blue_o),
	.hsync_o(hsync_o),
	.vsync_o(vsync_o)
);


always @(posedge px_clk, negedge reset_ni)begin
	if (!reset_ni) begin
		red='b0;
		green='b0;
		blue='b0;
	end else begin
		if (x_o > 0 && x_o < 640 && y_o > 0 && y_o < 480) begin 
			red='d15;
			blue='d15;
			green='d15;
		end else begin
			red='b0;
			green='b0;
			blue='b0;
		end
		end
end

endmodule





