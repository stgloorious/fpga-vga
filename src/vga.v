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


reg[9:0] horizontal_counter_d; /** counts individual pixels */
reg[9:0] horizontal_counter_q; 
reg[9:0] vertical_counter_d; /** counts horizontal lines */
reg[9:0] vertical_counter_q;

/* Buffered output signals */
reg [3:0] red_d;
reg [3:0] red_q;
reg [3:0] green_d;
reg [3:0] green_q;
reg [3:0] blue_d;
reg [3:0] blue_q;
reg [3:0] hsync_d;
reg [3:0] hsync_q;
reg [3:0] vsync_d;
reg [3:0] vsync_q;

/* Register to wire assertion */
assign hsync_o = hsync_q;
assign vsync_o = vsync_q;
assign red_o = red_q;
assign green_o = green_q;
assign blue_o = blue_q;

/* Synched by pixel clock, 25.175 MHz */
always @ (posedge clk_i, negedge reset_ni) begin
	
	/**
	* After a reset, the counters start at 
	* the end of the visible area, e.g. just 
	* before the last horizontal sync pulse 
	* before the vertical blank time starts.
  * This is supposed to make synchronization 
	* with a monitor on startup easier, although it 
	* is unclear how fast a typical 
	* monitor is able to achieve synchronization
	* with a new device. It is also not critical 
	* for the application.
	*
	*/
	if (!reset_ni) begin	
		/* Set all output lines asynchronously */
		red_q <= 'b0;
		green_q <= 'b0;
		blue_q <= 'b0;
		
		hsync_q <= 'b0;
		vsync_q <= 'b0;
		
		/* Reset counters */
		horizontal_counter_q <= visible_area_h;
		vertical_counter_q <= visible_area_v;
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

	/* Testing */
	red_d = red_q + 1;
	green_d = green_q + 1;
	blue_d = blue_q + 1;

	/* Increment pixel count */
	horizontal_counter_d = horizontal_counter_q + 1;
	vertical_counter_d = vertical_counter_q;

	/* Increment line count */
	if (horizontal_counter_q > whole_line - 2) begin
		horizontal_counter_d = 'b0;
		vertical_counter_d = vertical_counter_q + 1;
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

endmodule
