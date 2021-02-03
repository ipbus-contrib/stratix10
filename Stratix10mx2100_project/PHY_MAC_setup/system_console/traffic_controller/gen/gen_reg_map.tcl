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
##		Generator Registers Map
##==============================================================================  

#--without 1588
set GEN_NUMPKTS 			0x00000000
set GEN_RANDOMLENGTH 	0x00000004
set GEN_RANDOMPAYLOAD	0x00000008
set GEN_START 				0x0000000C
set GEN_STOP 				0x00000010
set GEN_MACSA0 			0x00000014
set GEN_MACSA1 			0x00000018
set GEN_MACDA0 			0x0000001C
set GEN_MACDA1 			0x00000020
set GEN_TXPKTCNT 			0x00000024
set GEN_RNDSEED0 			0x00000028
set GEN_RNDSEED1 			0x0000002C
set GEN_RNDSEED2 			0x00000030
set GEN_PKTLENGTH 		0x00000034


#--with 1588

set GO_MASTER 				0x00
set START_TOD_SYNC 		    0x04
set DELAY_FNS_H_ADDR        0x08;
set DELAY_FNS_L_ADDR        0x0C;
set OFFSET_FNS_H_ADDR       0x10;
set OFFSET_FNS_L_ADDR       0x14;
set ERROR_ADDR              0x18;
set CAPT_OFFSET_STATUS_ADDR 0x1C;
set MEM_READ_OFFSET_PTR_ADDR 0x20;
set MEM_READ_OFFSET_L_ADDR  0x24;
set MEM_READ_OFFSET_H_ADDR  0x28;
set MEM_READ_DELAY_PTR_ADDR 0x2C;
set MEM_READ_DELAY_L_ADDR   0x30;
set MEM_READ_DELAY_H_ADDR   0x34;
