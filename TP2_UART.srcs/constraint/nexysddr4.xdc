## This file is a general .xdc for the Nexys4 DDR Rev. C

## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { i_clk }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {i_clk}];

## Reset
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { i_reset }]; #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { i_rx }]; #IO_L7P_T1_AD6P_35 Sch=uart_txd_in
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { o_tx }]; #IO_L11N_T1_SRCC_35 Sch=uart_rxd_out

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {o_tx_done }]; #IO_L18P_T2_A24_15 Sch=led[0]
