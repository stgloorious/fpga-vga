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
wire px_clk;

/* Wires that are input to vga.v */
wire [3:0] red_i;
wire [3:0] green_i;
wire [3:0] blue_i;
wire [9:0] x_o;
wire [9:0] y_o;

/* Hold current RGB values */
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

/* Current ball position */
reg [9:0] x_ball='b0;
reg [9:0] y_ball='b0;

/* Ball size, adjusted for 16:9 stretching */
localparam BALL_HEIGHT = 'd27;
localparam BALL_WIDTH =	'd20;

localparam SCREEN_WIDTH = 'd640;
localparam SCREEN_HEIGHT = 'd480;

/* Runs at 25.125 MHz (pixel clock) */
always @(posedge px_clk, negedge reset_ni)begin
	
	if (!reset_ni) begin
		red='b0;
		green='b0;
		blue='b0;
	end else begin
		
		/* Only output RGB values if in visible area,
		* otherwise the "autoadjust" of the monitor makes 
		* weird things and the frame is not completely visible.
		*/
		if (x_o >= 0 && x_o < SCREEN_WIDTH 
			&& y_o >= 0 && y_o < SCREEN_HEIGHT) begin
			
			// Necessary?
			red = 'd0;
			green = 'd0;
			blue = 'd0;
			
			/* Draw ball */
			if (x_o >= x_ball && x_o < x_ball+BALL_WIDTH 
				&& y_o >= y_ball && y_o < y_ball+BALL_HEIGHT) begin 
				
				/* Ball color */
				red='d0;
				blue='d15;
				green='d0;
				end else begin

				/* Side bars */
				if (x_o < 50 || x_o > 590) begin 
					red = 'd2;
					green='d2;
					blue = 'd4;
				end else begin
					
					/* Background color */
					red = 'd15;
					green='d15;
					blue = 'd15;
				end

				/* Middle line */
				if (x_o == 320) begin
					red='d15;
					green='d0;
					blue='d0;
				end 
			end
		end else begin
			
			/* Outside of visible area */
			red='b0;
			green='b0;
			blue='b0;

		end
	end
end

reg [31:0] time_count = 'b0;
reg x_dir = DIR_INCREASING;
reg y_dir = DIR_INCREASING;

/** Counting at 25.125 MHz, ball moves 
* one step if counter reaches value TIMESTEP; */
localparam TIMESTEP = 'd100000;

/** How many pixels the ball advances in
* one timestep */
localparam BALL_STEP_SIZE = 'd1;

/* For indicating the direction 
* in which the ball is moving */
localparam DIR_DECREASING = 'b0;
localparam DIR_INCREASING = 'b1;

always @(posedge px_clk, negedge reset_ni) begin
	if (!reset_ni) begin
		x_ball = 'd0;
		y_ball = 'd0;
		x_dir = DIR_INCREASING;
		y_dir = DIR_INCREASING;
	end else begin

		/* Advance ball one step, 
		* with boundary check */
		if (time_count > TIMESTEP) begin 
			if (x_ball >= SCREEN_WIDTH-BALL_WIDTH) begin
				x_dir = DIR_DECREASING;
			end else begin
				if (x_ball == 0) begin
				x_dir = DIR_INCREASING;
				end
			end

			if (y_ball >= SCREEN_HEIGHT-BALL_HEIGHT) begin
				y_dir = DIR_DECREASING;
			end else begin
				if (y_ball == 0) begin 
					y_dir = DIR_INCREASING;
				end 
			end

				if (x_dir == DIR_DECREASING) begin
					x_ball = x_ball - BALL_STEP_SIZE;
				end else begin
					x_ball = x_ball + BALL_STEP_SIZE;	
				end

				if (y_dir == DIR_DECREASING) begin
					y_ball = y_ball - BALL_STEP_SIZE;
				end else begin 
					y_ball = y_ball + BALL_STEP_SIZE;
				end	

				time_count = 'b0;

		end else begin
			time_count = time_count + 1;
		end
	end
end

endmodule





