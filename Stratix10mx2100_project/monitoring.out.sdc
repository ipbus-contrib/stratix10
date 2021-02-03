## Generated SDC file "monitoring.out.sdc"

## Copyright (C) 2019  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Intel Corporation"
## PROGRAM "Quartus Prime"
## VERSION "Version 19.2.0 Build 57 06/24/2019 SJ Pro Edition"

## DATE    "Thu Oct 29 11:36:20 2020"

##
## DEVICE  "1SM21BHU2F53E1VG"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {altera_reserved_tck} -period 41.667 -waveform { 0.000 20.833 } [get_ports { altera_reserved_tck }]

create_clock -period "125MHz"   [get_ports { rx_cdr_refclk }]


#**************************************************************
# Set Clock Group
#**************************************************************


set_clock_groups -physically_exclusive -group [get_clocks {eth_inst|DUT|CHANNEL_GEN[0].u_channel|phy|alt_mge_phy_0|profile0|*}]

set_clock_groups -physically_exclusive -group [get_clocks {eth_inst|DUT|CHANNEL_GEN[0].u_channel|phy|alt_mge_phy_0|profile1|*}]

#**************************************************************
# False path
#**************************************************************

set_false_path -from [get_clocks {altera_reserved_tck}] -to [get_clocks {eth_inst|core_pll|iopll_0_clk_156}]
set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_clk_156}] -to [get_clocks {altera_reserved_tck}]

set_false_path -from [get_clocks {altera_reserved_tck}] -to [get_clocks {eth_inst|core_pll|iopll_0_clk_125}]
set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_clk_125}] -to [get_clocks {altera_reserved_tck}]

set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_refclk}] -to [get_clocks {altera_reserved_tck}]
set_false_path -from [get_clocks {altera_reserved_tck}] -to [get_clocks {eth_inst|core_pll|iopll_0_refclk}]

set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_refclk}] -to [get_clocks {eth_inst|core_pll|iopll_0_clk_125}]
set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_clk_125}] -to [get_clocks {eth_inst|core_pll|iopll_0_refclk}]

set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_refclk}] -to [get_clocks {eth_inst|core_pll|iopll_0_clk_156}]

set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_clk_39}] -to [get_clocks {eth_inst|core_pll|iopll_0_refclk}]
set_false_path -from [get_clocks {eth_inst|core_pll|iopll_0_refclk}] -to [get_clocks {eth_inst|core_pll|iopll_0_clk_39}]