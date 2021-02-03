// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module	eth_1588_traffic_controller #(
	parameter 	TSTAMP_FP_WIDTH = 4
)(
	input 	wire	 							clk,
	input 	wire	 							reset_n,
                                				
	//Avalon MM                 				
	input 	wire								avl_mm_read,
	input 	wire								avl_mm_write,
	output 	wire								avl_mm_waitrequest,
	input 	wire	[7:0]						avl_mm_baddress,
	output 	wire	[31:0]					avl_mm_readdata,
	input 	wire	[31:0]					avl_mm_writedata,
	            	            				
	//Master Avalon ST          					
	output 	wire	[63:0] 					master_avl_st_tx_data,
	output 	wire	[2:0]  					master_avl_st_tx_empty,
	output 	wire	 							master_avl_st_tx_eop,
	output 	wire	 							master_avl_st_tx_error,
	input 	wire	 							master_avl_st_tx_ready,
	output 	wire	 							master_avl_st_tx_sop,
	output 	wire	 							master_avl_st_tx_val,    
	            	            				
	input 	wire	[63:0] 					master_avl_st_rx_data,
	input 	wire	[2:0]  					master_avl_st_rx_empty,
	input 	wire	 							master_avl_st_rx_eop,
	input 	wire	[5:0]						master_avl_st_rx_error,
	output 	wire 								master_avl_st_rx_ready,
	input 	wire 								master_avl_st_rx_sop,
	input 	wire 								master_avl_st_rx_val,
	                            				
	                            				
	input 	wire								master_mac_tx_status_valid,
	input 	wire	[39:0] 					master_mac_tx_status_data,
	input 	wire	[6:0]						master_mac_tx_status_error,
	                            				
	input 	wire								master_mac_rx_status_valid,
	input 	wire	[39:0] 					master_mac_rx_status_data,
	input 	wire	[6:0]						master_mac_rx_status_error,
	                            				
	                            				
	//Slave Avalon ST           				
	output 	wire	[63:0] 					slave_avl_st_tx_data,
	output 	wire	[2:0]  					slave_avl_st_tx_empty,
	output 	wire	 							slave_avl_st_tx_eop,
	output 	wire	 							slave_avl_st_tx_error,
	input 	wire	 							slave_avl_st_tx_ready,
	output 	wire	 							slave_avl_st_tx_sop,
	output 	wire	 							slave_avl_st_tx_val,    
	            	            				
	input 	wire	[63:0] 					slave_avl_st_rx_data,
	input 	wire	[2:0]  					slave_avl_st_rx_empty,
	input 	wire	 							slave_avl_st_rx_eop,
	input 	wire	[5:0]						slave_avl_st_rx_error,
	output 	wire 								slave_avl_st_rx_ready,
	input 	wire 								slave_avl_st_rx_sop,
	input 	wire 								slave_avl_st_rx_val,
	                            				
	//Master 1588 Signals       				
    input 	wire         						master_tx_egress_timestamp_96b_valid, 
    input 	wire 	[95:0]  						master_tx_egress_timestamp_96b_data, 
    input 	wire 	[TSTAMP_FP_WIDTH-1:0]   master_tx_egress_timestamp_96b_fingerprint, 

    output 	wire 	[TSTAMP_FP_WIDTH-1:0]  	master_tx_egress_timestamp_request_fingerprint, 
    output 	wire        						master_tx_egress_timestamp_request_valid,
                                				
    input 	wire         						master_rx_ingress_timestamp_96b_valid, 
    input 	wire 	[95:0]  						master_rx_ingress_timestamp_96b_data,
                                				
	//Slave 1588 Signals        				
	output 	wire         						slave_tx_egress_timestamp_request_valid, 
	output 	wire 	[TSTAMP_FP_WIDTH-1:0]	slave_tx_egress_timestamp_request_fingerprint, 
	                            				
	input 	wire          						slave_tx_egress_timestamp_96b_valid, 
	input 	wire 	[95:0]   					slave_tx_egress_timestamp_96b_data, 
	input 	wire 	[TSTAMP_FP_WIDTH-1:0]	slave_tx_egress_timestamp_96b_fingerprint, 
	                            				
	input 	wire          						slave_rx_ingress_timestamp_96b_valid, 
	input 	wire 	[95:0]   					slave_rx_ingress_timestamp_96b_data, 
	
	//Eth 1588 Traffic Controller Control	
	input 	wire         					wait_limit,
	output	wire	[1:0]						start_tod_sync,
	input		wire   [1:0]					channel_ready,
	output	wire								eth_1588_traffic_controller_error_n
    
);

wire				go_master;
wire				mem_capt_ena;
wire				mem_capt_read;
wire	[47:0]	average_delay_fnsec;    
wire	[47:0]	average_offset_fnsec;
wire				master_error;
wire				slave_error;
wire				capt_offset_start;
reg				[1:0]	crc_error;
wire				queue_valid; 
wire				sec_error;

    
wire			offset_adjustment_valid;
wire			offset_adjustment_ready;
wire	[191:0]	offset_adjustment_data;
reg             capt_offset_done;
reg      [12:0] capt_offset_addr;
wire     [11:0] mem_offset_rdaddr;
wire     [11:0] mem_delay_rdaddr;
wire     [47:0] mem_out_offset;
wire     [47:0] mem_out_delay;

wire     [1:0]  channel_ready_sync;

wire			oneport_loopback;

//Master Avalon ST
wire	[63:0] 					master_avl_st_tx_int_data;
wire	[2:0]  					master_avl_st_tx_int_empty;
wire	 						master_avl_st_tx_int_eop;
wire	 						master_avl_st_tx_int_error;
wire	 						master_avl_st_rx_int_ready;
wire	 						master_avl_st_tx_int_sop;
wire	 						master_avl_st_tx_int_val;

wire 	[TSTAMP_FP_WIDTH-1:0]  	master_tx_egress_timestamp_request_fingerprint_int;
wire        					master_tx_egress_timestamp_request_valid_int;

//Slave Avalon ST
wire	[63:0] 					slave_avl_st_tx_int_data;
wire	[2:0]  					slave_avl_st_tx_int_empty;
wire	 						slave_avl_st_tx_int_eop;
wire	 						slave_avl_st_tx_int_error;
wire	 						slave_avl_st_rx_int_ready;
wire	 						slave_avl_st_tx_int_sop;
wire	 						slave_avl_st_tx_int_val;

wire         					slave_tx_egress_timestamp_request_valid_int;
wire 	[TSTAMP_FP_WIDTH-1:0]	slave_tx_egress_timestamp_request_fingerprint_int;

assign oneport_loopback = 1'b1;

assign master_avl_st_tx_data    = oneport_loopback ? (slave_avl_st_tx_int_val ? slave_avl_st_tx_int_data : master_avl_st_tx_int_data) : master_avl_st_tx_int_data;
assign master_avl_st_tx_empty   = oneport_loopback ? (slave_avl_st_tx_int_val ? slave_avl_st_tx_int_empty : master_avl_st_tx_int_empty) : master_avl_st_tx_int_empty;
assign master_avl_st_tx_eop     = oneport_loopback ? (slave_avl_st_tx_int_val ? slave_avl_st_tx_int_eop : master_avl_st_tx_int_eop) : master_avl_st_tx_int_eop;
assign master_avl_st_tx_error   = oneport_loopback ? (slave_avl_st_tx_int_val ? slave_avl_st_tx_int_error : master_avl_st_tx_int_error) : master_avl_st_tx_int_error;
assign master_avl_st_rx_ready   = master_avl_st_rx_int_ready | (oneport_loopback & slave_avl_st_rx_int_ready);
assign master_avl_st_tx_sop     = oneport_loopback ? (slave_avl_st_tx_int_val ? slave_avl_st_tx_int_sop : master_avl_st_tx_int_sop) : master_avl_st_tx_int_sop;
assign master_avl_st_tx_val     = master_avl_st_tx_int_val | (oneport_loopback & slave_avl_st_tx_int_val);

assign master_tx_egress_timestamp_request_fingerprint   = oneport_loopback ? (slave_tx_egress_timestamp_request_valid_int ? slave_tx_egress_timestamp_request_fingerprint_int : master_tx_egress_timestamp_request_fingerprint_int) : master_tx_egress_timestamp_request_fingerprint_int;
assign master_tx_egress_timestamp_request_valid         = master_tx_egress_timestamp_request_valid_int | (oneport_loopback & slave_tx_egress_timestamp_request_valid_int);

assign slave_avl_st_rx_ready = slave_avl_st_rx_int_ready;

assign slave_avl_st_tx_data  = slave_avl_st_tx_int_data;
assign slave_avl_st_tx_empty = slave_avl_st_tx_int_empty;
assign slave_avl_st_tx_eop   = slave_avl_st_tx_int_eop;
assign slave_avl_st_tx_error = slave_avl_st_tx_int_error;
assign slave_avl_st_tx_sop   = slave_avl_st_tx_int_sop;
assign slave_avl_st_tx_val   = slave_avl_st_tx_int_val;

assign slave_tx_egress_timestamp_request_valid       = slave_tx_egress_timestamp_request_valid_int;
assign slave_tx_egress_timestamp_request_fingerprint = slave_tx_egress_timestamp_request_fingerprint_int;

altera_std_synchronizer #(.depth(2)) channel_ready_sync_0_inst (
    .clk(clk),
    .reset_n(reset_n),
    .din(channel_ready[0]),
    .dout(channel_ready_sync[0])
);

altera_std_synchronizer #(.depth(2)) channel_ready_sync_1_inst (
    .clk(clk),
    .reset_n(reset_n),
    .din(channel_ready[1]),
    .dout(channel_ready_sync[1])
);

assign capt_offset_start =  channel_ready_sync[0] & channel_ready_sync[1] & go_master;
assign eth_1588_traffic_controller_error_n = ~(slave_error | master_error | crc_error[0] | crc_error[1] | sec_error);	

//==============================TRAFFIC_CTRL================================ 
	  
traffic_controller_1588 traffic_controller_1588_inst (	 
	.clk													(clk),
	.reset												(~reset_n),	
                                                    	
	// avalon MM                                    	
	.csr_address										(avl_mm_baddress[7:2]),    //byte to dword address 
	.csr_waitrequest									(avl_mm_waitrequest),
	.csr_read											(avl_mm_read),        
	.csr_readdata										(avl_mm_readdata),  
	.csr_write											(avl_mm_write),      
	.csr_writedata										(avl_mm_writedata),  
	
  //output	
	.go_master											(go_master),
	.mem_capt_ena										(mem_capt_ena),
	.mem_capt_read										(mem_capt_read),
	.start_tod_sync									(start_tod_sync),
			                                        	
	//input	                                            	
	.average_delay_fnsec								(average_delay_fnsec),    
	.average_offset_fnsec							(average_offset_fnsec), 
			                                        	
	.master_error										(master_error),
	.slave_error										(slave_error),
	.capt_offset_start								(capt_offset_start),
	.capt_offset_done								(capt_offset_done),
	.mem_offset_rdaddr								(mem_offset_rdaddr),
	.mem_delay_rdaddr								(mem_delay_rdaddr),
	.mem_out_offset								    (mem_out_offset),
	.mem_out_delay								    (mem_out_delay),
	.crc_error											(crc_error)
);
	
char10g1588_master master_gen_mon_inst (
	.clk															(clk),           
	.rst_n														(reset_n),
		                                            	
    .wait_limit                   						(wait_limit),
 
	.master_tx_egress_timestamp_request_fingerprint		(master_tx_egress_timestamp_request_fingerprint_int),
    .master_tx_egress_timestamp_request_valid			(master_tx_egress_timestamp_request_valid_int), 
		                                            	
	.master_rx_ingress_timestamp_96b_valid				(master_rx_ingress_timestamp_96b_valid), 
    .master_rx_ingress_timestamp_96b_data				(master_rx_ingress_timestamp_96b_data), 
                                                    	
	.master_tx_egress_timestamp_96b_valid				(master_tx_egress_timestamp_96b_valid), 
    .master_tx_egress_timestamp_96b_data				(master_tx_egress_timestamp_96b_data), 
    .master_tx_egress_timestamp_96b_fingerprint			(master_tx_egress_timestamp_96b_fingerprint), 
                                                    	
    .master_st_rx_endofpacket     						(master_avl_st_rx_eop), 
    .master_st_rx_startofpacket   						(master_avl_st_rx_sop), 
    .master_st_rx_valid           						(master_avl_st_rx_val),  
    .master_st_rx_empty           						(master_avl_st_rx_empty), 
    .master_st_rx_error           						(master_avl_st_rx_error), 
    .master_st_rx_data            						(master_avl_st_rx_data),
    .master_st_rx_ready           						(master_avl_st_rx_int_ready), 
                                  						
	.master_st_tx_endofpacket     						(master_avl_st_tx_int_eop), 
    .master_st_tx_error           						(master_avl_st_tx_int_error),  
    .master_st_tx_startofpacket   						(master_avl_st_tx_int_sop),
    .master_st_tx_valid           						(master_avl_st_tx_int_val),  
    .master_st_tx_empty           						(master_avl_st_tx_int_empty),
    .master_st_tx_data            						(master_avl_st_tx_int_data), 
    .master_st_tx_ready           						(master_avl_st_tx_ready),  
		                                            	
	.master_st_rxstatus_valid     						(master_mac_rx_status_valid), 
    .master_st_rxstatus_data      						(master_mac_rx_status_data),
    .master_st_rxstatus_error     						(master_mac_rx_status_error), 
    .master_txstatus_valid        						(master_mac_tx_status_valid), 
    .master_txstatus_data         						(master_mac_tx_status_data), 
    .master_txstatus_error        						(master_mac_tx_status_error),  
    
	.master_link_fault_status_xgmii_rx_data 			(2'h0),
    .master_rx_ready_export       						(channel_ready_sync[1]),
    .master_tx_ready_export       						(channel_ready_sync[0] & go_master),
                                                    	
	.error_o                      						(master_error),        
	.loopback_en                  						(1'b0)
);
 	
char10g1588_slave slave_gen_mon_inst (
	.clk																(clk),
	.rst_n															(reset_n),

	.slave_tx_egress_timestamp_request_fingerprint		(slave_tx_egress_timestamp_request_fingerprint_int),
	.slave_tx_egress_timestamp_request_valid				(slave_tx_egress_timestamp_request_valid_int), 
	 
	.slave_rx_ingress_timestamp_96b_valid					(oneport_loopback ? master_rx_ingress_timestamp_96b_valid : slave_rx_ingress_timestamp_96b_valid), 
	.slave_rx_ingress_timestamp_96b_data					(oneport_loopback ? master_rx_ingress_timestamp_96b_data : slave_rx_ingress_timestamp_96b_data), 

	.slave_tx_egress_timestamp_96b_valid					(oneport_loopback ? master_tx_egress_timestamp_96b_valid : slave_tx_egress_timestamp_96b_valid), 
	.slave_tx_egress_timestamp_96b_data						(oneport_loopback ? master_tx_egress_timestamp_96b_data : slave_tx_egress_timestamp_96b_data), 
	.slave_tx_egress_timestamp_96b_fingerprint			(oneport_loopback ? master_tx_egress_timestamp_96b_fingerprint : slave_tx_egress_timestamp_96b_fingerprint), 

	.slave_st_rx_endofpacket     						(oneport_loopback ? master_avl_st_rx_eop : slave_avl_st_rx_eop), 
	.slave_st_rx_startofpacket   						(oneport_loopback ? master_avl_st_rx_sop : slave_avl_st_rx_sop), 
	.slave_st_rx_valid           						(oneport_loopback ? master_avl_st_rx_val : slave_avl_st_rx_val),  
	.slave_st_rx_empty           						(oneport_loopback ? master_avl_st_rx_empty : slave_avl_st_rx_empty), 
	.slave_st_rx_error           						(oneport_loopback ? master_avl_st_rx_error : slave_avl_st_rx_error), 
	.slave_st_rx_data            						(oneport_loopback ? master_avl_st_rx_data : slave_avl_st_rx_data),
	.slave_st_rx_ready           						(slave_avl_st_rx_int_ready), 

	.slave_st_tx_endofpacket     						(slave_avl_st_tx_int_eop), 
	.slave_st_tx_error           						(slave_avl_st_tx_int_error),  
	.slave_st_tx_startofpacket   						(slave_avl_st_tx_int_sop),
	.slave_st_tx_valid           						(slave_avl_st_tx_int_val),  
	.slave_st_tx_empty           						(slave_avl_st_tx_int_empty),
	.slave_st_tx_data            						(slave_avl_st_tx_int_data), 
	.slave_st_tx_ready           						(oneport_loopback ? master_avl_st_tx_ready : slave_avl_st_tx_ready),  
		 
	.error_o                      						(slave_error),
	.offset_adjustment_valid							(offset_adjustment_valid),
	.offset_adjustment_data								(offset_adjustment_data),
	.offset_adjustment_ready							(offset_adjustment_ready)
);
 
char10g1588_avg avgoffset ( 
	// Outputs
	.offset_adjustment_ready							(offset_adjustment_ready),
	.average_offset_fnsec								(average_offset_fnsec),
	.sec_error         									(sec_error),
	.queue_valid       									(queue_valid),   
                                						
	// Inputs                   						
	.clk               									(clk),  
	.rst_n             									(reset_n),      
	.offset_adjustment_data								(offset_adjustment_data[95:0]),
	.offset_adjustment_valid							(offset_adjustment_valid)
);                              						
                                						                     						
char10g1588_avg avgdelay (      						
	// Outputs                  						
	.offset_adjustment_ready							(),
	.average_offset_fnsec								(average_delay_fnsec), 
	.sec_error          									(),             
	.queue_valid        									(),             
                                						
	// Inputs                   						
	.clk                									(clk),  
	.rst_n              									(reset_n),      
	.offset_adjustment_data								(offset_adjustment_data[191:96]), 
	.offset_adjustment_valid							(offset_adjustment_valid)
	);

always @(posedge clk or negedge reset_n) begin
    if (reset_n == 0) begin
        capt_offset_done <= 0;
        capt_offset_addr <= 0;
    end else begin
        if (~mem_capt_ena) begin
            capt_offset_done <= 0;
            capt_offset_addr <= 0;
        end
        else if (capt_offset_start) begin
            capt_offset_done <= capt_offset_done | ((&capt_offset_addr) & offset_adjustment_valid);
            
            if (offset_adjustment_valid) begin
                capt_offset_addr <= capt_offset_addr + 13'h1;
            end
        end
    end
end

char10g1588_ram #(
        .LPM_HINT ("ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=OFFSET")
    ) ram_offset (
        .clock                                              (clk),
        .address                                            (mem_capt_read ? mem_offset_rdaddr : capt_offset_addr),
        .wren                                               (offset_adjustment_valid & capt_offset_start & ~capt_offset_done),
        .data                                               (offset_adjustment_data[47:0]),
        .q                                                  (mem_out_offset)
    );

char10g1588_ram #(
        .LPM_HINT ("ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=DELAY")
    ) ram_delay (
        .clock                                              (clk),
        .address                                            (mem_capt_read ? mem_delay_rdaddr : capt_offset_addr),
        .wren                                               (offset_adjustment_valid & capt_offset_start & ~capt_offset_done),
        .data                                               (offset_adjustment_data[143:96]),
        .q                                                  (mem_out_delay)
    );

always @(posedge clk or negedge reset_n) begin

	if (reset_n == 0) begin
		crc_error <= 2'b00;
    end 
	else begin
		if (master_avl_st_rx_error[1] && master_avl_st_rx_val && master_avl_st_rx_ready) begin
			crc_error[0] <= 1'b1;
		end

		if (slave_avl_st_rx_error[1] && slave_avl_st_rx_val && slave_avl_st_rx_ready) begin
			crc_error[1] <= 1'b1;
      	end
   end
end

endmodule
