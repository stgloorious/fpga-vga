# fpga-vga
Little FPGA project that drives a VGA monitor.
Written in Verilog, developed using [open source tools](https://github.com/FPGAwars/apio) and [hardware](https://icebreaker-fpga.org/).

## Hardware components
- FPGA: Lattice iCE40UP5K on iCEBreaker v1.0e Development Board
- Pmod VGA from Digilent ([Schematic](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_sch.pdf))

## VGA
Since VGA (Video Graphics Array) uses purely analog RGB signals, 
some additional hardware is needed. The [VGA Pmod](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_rm.pdf)
contains 3.3V bus drivers and simple 4-bit R-2R resistor DACs, one per
color channels. This allows the proper signals expected by a VGA monitor to 
be generated by the FPGA. My implementation supports the standard 
**640x480@60Hz** mode.

<img src="https://github.com/stgloorious/fpga-vga/blob/master/docs/figures/signals.png" width="400" />


#### Timing
|Update frequency      | |
|---------------------|-------|
| Screen refresh rate | 60 Hz |
| Vertical refresh    | 31.47 kHz |
| Pixel frequency     | 25.175 MHz |

**Horizontal timing (line)**
| Scanline part | Pixels | Time [us] |
|---------------|--------|-------------------| 
|Visible area		|640		| 25.42|
|Front porch		|16|0.6356|
|Sync pulse     |96|3.813|
|Back porch			|48|1.907|
|Whole line			|800|31.78|

**Vertical timing (frame)**
| Scanline part | Pixels | Time [us] |
|---------------|--------|-------------------| 
|Visible area		|480		| 15253|
|Front porch		|10|317.8|
|Sync pulse     |2|63.56|
|Back porch			|33|1049|
|Whole line			|525|16683|

## References 
- [Pmod VGA Reference Manual (Digilent)](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_rm.pdf)
- [Pmod VGA Schematic (Digilent)](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_sch.pdf)
- [TinyVGA VGA Timing specification](http://www.tinyvga.com/vga-timing/640x480@60Hz)
- [Wikipedia: Video Graphics Array](https://en.wikipedia.org/wiki/Video_Graphics_Array)
- [Youtube: Ben Eater, The world's worst video card?](https://www.youtube.com/watch?v=l7rce6IQDWs)
## Remarks
This project is the result of the P&S Course "iCEBreaker FPGA For IoT Sensing Systems (227-0085-28P)" at ETH Zürich.
