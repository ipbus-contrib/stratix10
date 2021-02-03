# (C) 2001-2019 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


##==============================================================================
##		Monitor Registers Map
##==============================================================================
#--without 1588
set	MON_RXPKTCNT_EXPT		0x00000000 	
set	MON_RXPKTCNT_GOOD		0x00000004  	
set	MON_RXPKTCNT_BAD 		0x00000008  	
set	MON_RXBYTECNT_LO32 	0x0000000C	
set	MON_RXBYTECNT_HI32 	0x00000010	
set	MON_RXCYCLCNT_LO32 	0x00000014	
set	MON_RXCYCLCNT_HI32 	0x00000018	
set	MON_RXCTRL_STATUS 	0x0000001C	
set	GEN_MON_LPBK 			0x00000028	

#--with 1588

set DELAY_FNS_H 			0x08
set DELAY_FNS_L 			0x0C
set OFFSET_FNS_H 			0x10
set OFFSET_FNS_L			0x14
set ERROR 					0x18
set CAPT_OFFSET_START 	0x1C