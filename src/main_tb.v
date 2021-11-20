/**
* @file main_tb.v
* @brief testbench for main.v
*
*/

`timescale 10ps/1ps
module template_tb();

/* applied stimuli */
reg clk_i; /** 12 MHz */
reg reset_ni;

reg px_clk; /** 25.125 MHz */

main dut(
	.clk_i(clk_i),
	.reset_ni(reset_ni)
);

/* Reset */
initial begin 
reset_ni = 1'b0;
#4000
reset_ni = 1'b1;
end

/* Generate clock */
initial begin 
	clk_i = 1'b0;
end
always begin
			#416 clk_i = ~clk_i;
end

/* Generate PLL clock */
initial begin 
	px_clk = 1'b0;
end
always begin
	#199 px_clk = ~px_clk;
	force template_tb.dut.u_pll.clock_out = px_clk; /** Simulate PLL */
end

/* Simulation parameters */
parameter DURATION = 500000000; /* Number of time steps */ 
`define DUMPSTR(x) `"x.vcd`"
initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, template_tb);
   #(DURATION) $display("End of simulation");
  $finish;
end

endmodule
