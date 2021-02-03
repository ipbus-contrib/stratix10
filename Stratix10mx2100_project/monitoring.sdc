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
## VERSION "Version 19.4.0 Build 64 12/04/2019 SC Pro Edition"

## DATE    "Tue Apr  7 16:07:10 2020"

##
## DEVICE  "1SM21BHU2F53E1VG"
##

derive_pll_clocks
derive_clock_uncertainty

#**************************************************************
# Time Information
#**************************************************************




#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {ref_clk_100} -period 1.000 -waveform { 0.000 0.500 } [get_ports {ref_clk_100}]
create_clock -name {altera_reserved_tck} -period 41.667 [get_ports { altera_reserved_tck }]

create_clock -period "125MHz"   [get_ports { rx_cdr_refclk }] 

#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock altera_reserved_tck -clock_fall -max 5 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall -max 5 [get_ports altera_reserved_tms]

#**************************************************************
# Set Output Delay
#**************************************************************


set_output_delay -clock altera_reserved_tck 5 [get_ports altera_reserved_tdo]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks { altera_reserved_tck }]
set_clock_groups -asynchronous -group [get_clocks { rx_cdr_refclk }]


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {altera_reserved_ntrst}]
set_false_path -from [get_clocks {ref_clk_100}] -to [get_clocks {ref_clk_100}]


#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************


#**************************************************************
# Set Minimum Delay
#**************************************************************


#**************************************************************
# Set Input Transition
#**************************************************************


#**************************************************************
# Set Net Delay
#**************************************************************


#**************************************************************
# Set Max Skew
#**************************************************************

#**************************************************************
# Set Disable Timing
#**************************************************************


#**************************************************************
# Disable Min Pulse Width
#**************************************************************

