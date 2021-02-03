# Copyright (C) 2019  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: monitoring.tcl
# Generated on: Wed Dec  2 10:11:55 2020

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "monitoring"]} {
		puts "Project monitoring is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists monitoring]} {
		project_open -revision monitoring monitoring
	} else {
		project_new -revision monitoring monitoring
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 19.2.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "11:41:33  NOVEMBER 13, 2019"
	set_global_assignment -name LAST_QUARTUS_VERSION "19.2.0 Pro Edition"
	set_global_assignment -name DEVICE 1SM21BHU2F53E1VG
	set_global_assignment -name FAMILY "Stratix 10"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP
	set_global_assignment -name SEED 100
	set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
	set_global_assignment -name ENABLE_NCE_PIN OFF
	set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name ENABLE_SIGNALTAP ON
	set_global_assignment -name USE_SIGNALTAP_FILE stp_clocks.stp
	set_global_assignment -name AUTO_RESTART_CONFIGURATION OFF
	set_global_assignment -name MINIMUM_SEU_INTERVAL 0
	set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
	set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_100MHZ
	set_global_assignment -name NUM_PARALLEL_PROCESSORS 14
	set_global_assignment -name USE_CONF_DONE SDM_IO16
	set_global_assignment -name USE_INIT_DONE SDM_IO0
	set_global_assignment -name USE_CVP_CONFDONE SDM_IO15
	set_global_assignment -name VID_OPERATION_MODE "PMBUS MASTER"
	set_global_assignment -name USE_PWRMGT_SCL SDM_IO14
	set_global_assignment -name USE_PWRMGT_SDA SDM_IO11
	set_global_assignment -name PWRMGT_BUS_SPEED_MODE "100 KHZ"
	set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER
	set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 47
	set_global_assignment -name PWRMGT_SLAVE_DEVICE1_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE2_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE3_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE4_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE5_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE6_ADDRESS 00
	set_global_assignment -name PWRMGT_SLAVE_DEVICE7_ADDRESS 00
	set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS
	set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE ON
	set_global_assignment -name EDA_SIMULATION_TOOL "<None>"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT NONE -section_id eda_simulation
	set_global_assignment -name ENABLE_LOGIC_ANALYZER_INTERFACE OFF
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name IP_FILE IP/To_MAC_fifo.ip
	set_global_assignment -name VHDL_FILE hilo_detect.vhd
	set_global_assignment -name VHDL_FILE delay_chain.vhd
	set_global_assignment -name VHDL_FILE valid_8to32.vhd
	set_global_assignment -name VHDL_FILE valid_32to8.vhd -hdl_version VHDL_2008
	set_global_assignment -name IP_FILE IP/valid_32to8fifo.ip
	set_global_assignment -name VHDL_FILE avalon_tx_in_loop.vhd
	set_global_assignment -name VHDL_FILE mux161.vhd
	set_global_assignment -name VHDL_FILE x2a_SRL16.vhd
	set_global_assignment -name VERILOG_FILE imported_from_design_example/alt_mge_reset_synchronizer.v
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_txtransactor_if_simple.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_tx_mux.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_rxtransactor_if_simple.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_clock_crossing_if.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_status_buffer.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_rxram_shim.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_rxram_mux.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_packet_parser.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_dualportram_tx.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_dualportram_rx.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_dualportram.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_do_rx_reset.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_byte_sum.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_build_status.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_build_resend.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_build_ping.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_buffer_selector.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_rarp_block.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_build_payload.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_build_arp.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_ipaddr_block.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/transactor_cfg.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/transactor_sm.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/transactor_if.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/transactor.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/trans_arb.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_transport_udp/firmware/hdl/udp_if_flat.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_slaves/firmware/hdl/ipbus_peephole_ram.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_slaves/firmware/hdl/ipbus_ram.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_slaves/firmware/hdl/ipbus_ctrlreg_v.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_util/firmware/hdl/ipbus_clock_div.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/ipbus_trans_decl.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_util/firmware/hdl/ipbus_decode_ipbus_example.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_core/firmware/hdl/ipbus_package.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_util/firmware/hdl/ipbus_example.vhd
	set_global_assignment -name VHDL_FILE ../components/ipbus_util/firmware/hdl/masters/ipbus_ctrl.vhd
	set_global_assignment -name VHDL_FILE reset_gen.vhd -hdl_version VHDL_2008
	set_global_assignment -name VHDL_FILE ipbus_top.vhd -hdl_version VHDL_2008
	set_global_assignment -name VHDL_FILE ipbus_axi_ast.vhd -hdl_version VHDL_2008
	set_global_assignment -name SIGNALTAP_FILE stp_clocks.stp
	set_global_assignment -name SYSTEMVERILOG_FILE imported_from_design_example/altera_eth_top.sv
	set_global_assignment -name SYSTEMVERILOG_FILE imported_from_design_example/alt_mge_rd.sv
	set_global_assignment -name VERILOG_FILE imported_from_design_example/alt_mge_channel.v
	set_global_assignment -name IP_FILE IP/reset_controller.ip
	set_global_assignment -name VERILOG_FILE imported_from_design_example/reconfig/alt_mge_rcfg_txpll_switch.v
	set_global_assignment -name VERILOG_FILE imported_from_design_example/reconfig/alt_mge_rcfg_mif_rom.v
	set_global_assignment -name VERILOG_FILE imported_from_design_example/reconfig/alt_mge_rcfg_mif_master.v
	set_global_assignment -name VERILOG_FILE imported_from_design_example/reconfig/alt_mge_rcfg_ch_recal.v
	set_global_assignment -name SYSTEMVERILOG_FILE imported_from_design_example/reconfig/alt_mge_rcfg.sv
	set_global_assignment -name SYSTEMVERILOG_FILE imported_from_design_example/reconfig/alt_mge_phy_reconfig_parameters_CFG1.sv
	set_global_assignment -name SYSTEMVERILOG_FILE imported_from_design_example/reconfig/alt_mge_phy_reconfig_parameters_CFG0.sv
	set_global_assignment -name IP_FILE imported_from_design_example/jtag_avalon_master/alt_jtag_csr_master.ip
	set_global_assignment -name QSYS_FILE imported_from_design_example/address_decoder/alt_mge_rd_avmm_mux_xcvr_rcfg.qsys
	set_global_assignment -name QSYS_FILE imported_from_design_example/address_decoder/alt_mge_rd_addrdec_mch.qsys
	set_global_assignment -name IP_FILE IP/atx_1562.ip
	set_global_assignment -name VHDL_FILE eth_package.vhd
	set_global_assignment -name VHDL_FILE prm_format.vhd
	set_global_assignment -name VHDL_FILE Monitoring.vhd
	set_global_assignment -name IP_FILE IP/clock_gen_pll.ip
	set_global_assignment -name IP_FILE IP/phy_layer.ip
	set_global_assignment -name IP_FILE IP/phy_pll_625.ip
	set_global_assignment -name IP_FILE IP/MAC_layer_low.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_channel_0_mac.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_channel_0_native_phy_rcfg.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_master_channel.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_mge_reconfig.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_mac_clk.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_csr_clk.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_channel_0_phy.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_jtag_if.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_avmm_mux_xcvr_rcfg/alt_mge_rd_avmm_mux_xcvr_rcfg_user_rcfg_master.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_avmm_mux_xcvr_rcfg/alt_mge_rd_avmm_mux_xcvr_rcfg_mge_rcfg_master.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_avmm_mux_xcvr_rcfg/alt_mge_rd_avmm_mux_xcvr_rcfg_csr_clk.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_avmm_mux_xcvr_rcfg/alt_mge_rd_avmm_mux_xcvr_rcfg_xcvr_rcfg_slave.ip
	set_global_assignment -name IP_FILE imported_from_design_example/address_decoder/ip/alt_mge_rd_addrdec_mch/alt_mge_rd_addrdec_mch_sysid_qsys_0.ip
	set_global_assignment -name SDC_FILE monitoring.out.sdc
	set_global_assignment -name IP_FILE IP/axi_fifo_8.ip
	set_location_assignment PIN_AJ43 -to rx_cdr_refclk
	set_location_assignment PIN_AU17 -to ref_clk_100
	set_location_assignment PIN_BL14 -to reset_n
	set_location_assignment PIN_BL13 -to "reset_n(n)"
	set_location_assignment PIN_AW17 -to zqsfp0_1v8_modsel_l
	set_location_assignment PIN_AV16 -to zqsfp0_1v8_reset_l
	set_location_assignment PIN_AW16 -to zqsfp0_1v8_modprs_l
	set_location_assignment PIN_BC16 -to zqsfp0_1v8_lpmode
	set_location_assignment PIN_BB16 -to zqsfp0_1v8_int_l
	set_location_assignment PIN_AY16 -to zqsfp1_1v8_reset_l
	set_location_assignment PIN_AY15 -to zqsfp1_1v8_modprs_l
	set_location_assignment PIN_BE15 -to zqsfp1_1v8_lpmode
	set_location_assignment PIN_BF15 -to zqsfp1_1v8_int_l
	set_location_assignment PIN_BA17 -to zqsfp1_1v8_modsel_l
	set_location_assignment PIN_BD16 -to zqsfp_s10_i2c_sda
	set_location_assignment PIN_BJ16 -to zqsfp_s10_i2c_scl
	set_location_assignment PIN_BH11 -to s10_led[3]
	set_location_assignment PIN_BG11 -to s10_led[2]
	set_location_assignment PIN_BF12 -to s10_led[1]
	set_location_assignment PIN_BG12 -to s10_led[0]
	set_instance_assignment -name IO_STANDARD LVDS -to ref_clk_100 -entity monitoring
	set_instance_assignment -name GLOBAL_SIGNAL GLOBAL_CLOCK -to ref_clk_100 -entity monitoring
	set_instance_assignment -name IO_STANDARD LVDS -to reset_n -entity monitoring
	set_location_assignment PIN_AN51 -to zsqfp_tx_p
	set_location_assignment PIN_AN50 -to "zsqfp_tx_p(n)"
	set_location_assignment PIN_AM45 -to zsqfp_rx_p
	set_location_assignment PIN_AM44 -to "zsqfp_rx_p(n)"
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to zsqfp_tx_p -entity monitoring
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to zsqfp_rx_p -entity monitoring

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
