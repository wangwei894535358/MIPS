# CLK
# PadFunction: IO_L12P_T1_MRCC_38
set_property VCCAUX_IO DONTCARE [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]

# PadFunction: IO_L13N_T2_MRCC_15
set_property VCCAUX_IO DONTCARE [get_ports rst]
set_property IOSTANDARD LVCMOS18 [get_ports rst]

set_property IOSTANDARD LVCMOS18 [get_ports {MEM_WB_RegWriteReg[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {MEM_WB_RegWriteReg[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {MEM_WB_RegWriteReg[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {MEM_WB_RegWriteReg[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {MEM_WB_RegWriteReg[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports MEM_WB_MemtoReg]
set_property IOSTANDARD LVCMOS18 [get_ports MEM_WB_RegWrite]







set_property SLEW FAST [get_ports {MEM_WB_RegWriteReg[4]}]
set_property SLEW FAST [get_ports {MEM_WB_RegWriteReg[3]}]
set_property SLEW FAST [get_ports {MEM_WB_RegWriteReg[2]}]
set_property SLEW FAST [get_ports {MEM_WB_RegWriteReg[1]}]
set_property SLEW FAST [get_ports {MEM_WB_RegWriteReg[0]}]
set_property SLEW FAST [get_ports MEM_WB_MemtoReg]
set_property PACKAGE_PIN AM28 [get_ports MEM_WB_RegWrite]
set_property SLEW FAST [get_ports MEM_WB_RegWrite]
