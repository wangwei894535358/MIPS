# UART
set_property IOSTANDARD LVCMOS18 [get_ports TXD]
set_property IOSTANDARD LVCMOS18 [get_ports RXD]

# LED
set_property IOSTANDARD LVCMOS18 [get_ports {LED[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LED[7]}]

# CLK
# PadFunction: IO_L12P_T1_MRCC_38
set_property VCCAUX_IO DONTCARE [get_ports CLK_P]
set_property IOSTANDARD DIFF_SSTL15 [get_ports CLK_P]

# PadFunction: IO_L12N_T1_MRCC_38
set_property IOSTANDARD DIFF_SSTL15 [get_ports CLK_N]
set_property PACKAGE_PIN E18 [get_ports CLK_N]
set_property PACKAGE_PIN F18 [get_ports CLK_P]

# PadFunction: IO_L13N_T2_MRCC_15
set_property VCCAUX_IO DONTCARE [get_ports RST_X_IN]
set_property IOSTANDARD LVCMOS18 [get_ports RST_X_IN]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets genmmcmds/clk_ibuf]


create_clock -period 25.000 -name CLK_P -waveform {0.000 12.500}
