## Clock signal (100 MHz)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { CLK100MHZ }];

## Reset Button (btn[0])
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { btn_reset }];

## Switches (Keyboard Fallback / Input)
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }];
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }];

## Pmod Header JA - PS/2 Keyboard
## Mapping: Pin 1 (Data), Pin 2 (NC), Pin 3 (Clock), Pin 4 (GND)
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { ps2_data }]; # JA Pin 1
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 PULLUP true } [get_ports { ps2_clk }];  # JA Pin 3

## Pmod Header JB - VGA Lower Bits (R0-1, G0-1, B0-1)
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { vga_r[0] }]; # JB Pin 1
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { vga_r[1] }]; # JB Pin 2
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { vga_g[0] }]; # JB Pin 3
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { vga_g[1] }]; # JB Pin 4
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { vga_b[0] }]; # JB Pin 7
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { vga_b[1] }]; # JB Pin 8

## Pmod Header JC - VGA Upper Bits and Sync (R2-3, G2-3, B2-3, HS, VS)
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { vga_r[2] }]; # JC Pin 1
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { vga_r[3] }]; # JC Pin 2
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { vga_g[2] }]; # JC Pin 3
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { vga_g[3] }]; # JC Pin 4
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { vga_b[2] }]; # JC Pin 7
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { vga_b[3] }]; # JC Pin 8
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { hsync }];    # JC Pin 9
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { vsync }];    # JC Pin 10

## LEDs
set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];
