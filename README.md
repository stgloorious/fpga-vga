# fpga-vga
Little FPGA project that drives a VGA monitor

## Hardware components
- FPGA: Lattice iCE40UP5K on iCEBreaker v1.0e Development Board
- Pmod VGA from Digilent, [Schematic](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_sch.pdf)

### VGA
The [VGA Pmod](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_rm.pdf)
contains 3.3V bus drivers and a simple 4-bit R-2R resistor DAC per
color. 


## References 
- [Pmod VGA Reference Manual (Digilent)](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_rm.pdf)
- [Pmod VGA Schematic (Digilent)](https://digilent.com/reference/_media/reference/pmod/pmodvga/pmodvga_sch.pdf)

## Remarks
This project is the result of the P&S Course "iCEBreaker FPGA For IoT Sensing Systems (227-0085-28P)" at ETH Zürich.
