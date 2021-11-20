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
	.blue_o(blue_o)
);


/* Timing in pixel counts */
localparam visible_area_h = 'd640;
localparam front_porch_h = 'd16;
localparam sync_pulse_h = 'd96;
localparam back_porch_h = 'd48;
localparam whole_line = 'd800; /* sum of above */

localparam visible_area_v = 'd480;
localparam front_porch_v = 'd10;
localparam sync_pulse_v = 'd2;
localparam back_porch_v = 'd33;
localparam whole_frame = 'd525; /* sum of above */


reg[9:0] horizontal_counter_d = 'b0; /** counts individual pixels */
reg[9:0] horizontal_counter_q = 'b0; 
reg[9:0] vertical_counter_d = 'b0; /** counts horizontal lines */
reg[9:0] vertical_counter_q = 'b0;

/* Buffered output signals */
reg [3:0] red_d= 'b0;
reg [3:0] red_q= 'b0;
reg [3:0] green_d= 'b0;
reg [3:0] green_q= 'b0;
reg [3:0] blue_d= 'b0;
reg [3:0] blue_q= 'b0;
reg [3:0] hsync_d= 'b0;
reg [3:0] hsync_q= 'b0;
reg [3:0] vsync_d= 'b0;
reg [3:0] vsync_q= 'b0;

/* Register to wire assertion */
assign hsync_o = hsync_q;
assign vsync_o = vsync_q;
assign red_o = red_q;
assign green_o = green_q;
assign blue_o = blue_q;

/* Synched by pixel clock, 25.175 MHz */
always @ (posedge px_clk, negedge reset_ni) begin
	if (!reset_ni) begin
		/* Set all output lines asynchronously */
		red_q <= 'b0;
		green_q <= 'b0;
		blue_q <= 'b0;
		hsync_q <= 'b1;
		vsync_q <= 'b1;
		
		/* Reset counters */
		horizontal_counter_q <= 'b0;
		vertical_counter_q <= 'b0;
	end else begin 
		
		/* Separate synchronization */
		red_q <= red_d;
		green_q <= green_d;
		blue_q <= blue_d;
		hsync_q <= hsync_d;
		vsync_q <= vsync_d;

		horizontal_counter_q <= horizontal_counter_d;
		vertical_counter_q <= vertical_counter_d;
	end
end 

/* Combinatorics */
always @ (*) begin
	if (reset_ni) begin 
		
		/* Testing */
		red_d = red_q + 1;
		green_d = green_q + 1;
		blue_d = blue_q + 1;

		/* Increment pixel count */
		horizontal_counter_d = horizontal_counter_q + 1;

		/* Increment line count */
		if (horizontal_counter_q > whole_line - 2) begin
			horizontal_counter_d = 'b0;
			vertical_counter_d = vertical_counter_q + 1;

			/* Testing */
			red_d = 'b0;
			green_d = 'b0;
			blue_d = 'b0;
		end

		/* Generate horizontal sync pulse */
		if (horizontal_counter_q > visible_area_h + front_porch_h - 2 
			&& horizontal_counter_q < visible_area_h + front_porch_h + sync_pulse_h - 1) begin
			hsync_d = 'b1;
		end else begin
			hsync_d = 'b0;
		end

		/* Generate vertical sync pulse */
		if (vertical_counter_q > visible_area_v + front_porch_v - 2
			&& vertical_counter_q < visible_area_v + front_porch_v + sync_pulse_v - 1) begin
			vsync_d = 'b1;
		end else begin
			vsync_d = 'b0;
		end

		/* Reset line count after a complete frame */
		if (vertical_counter_q > whole_frame) begin
			vertical_counter_d = 'b0;
		end
	end
end

endmodule





