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


module traffic_controller_1588 (	 
	input wire			clk,
   input wire			reset,	
		// avalon MM
	input  wire [5:0]   csr_address,     
	output wire         csr_waitrequest,
	input  wire         csr_read,        
	output reg  [31:0]   csr_readdata,  
	input  wire         csr_write,      
	input  wire [31:0]  csr_writedata,  
	 
	output reg                                             go_master,
	output reg                                             mem_capt_ena,
	output reg                                             mem_capt_read,
	output reg	[1:0]											 		 start_tod_sync,
	 

	input wire [47:0]                                  	 average_delay_fnsec,    
   input wire [47:0]                                      average_offset_fnsec, 
	 
	input wire															 master_error,
	input wire															 slave_error,
   input wire 															 capt_offset_start,
   input wire 															 capt_offset_done,
   output reg [11:0]													 mem_offset_rdaddr,
   output reg [11:0]													 mem_delay_rdaddr,
   input wire [47:0]													 mem_out_offset,
   input wire [47:0]													 mem_out_delay,
   input reg  [1:0]													 crc_error														
	
);
 localparam CONTROL_ADDR = 6'h0;
 localparam START_TOD_SYNC_ADDR = 6'h1;
 localparam DELAY_FNS_H_ADDR = 6'h2;
 localparam DELAY_FNS_L_ADDR = 6'h3;
 localparam OFFSET_FNS_H_ADDR = 6'h4;
 localparam OFFSET_FNS_L_ADDR = 6'h5;
 localparam ERROR_ADDR = 6'h6;
 localparam CAPT_OFFSET_STATUS_ADDR = 6'h7;
 localparam MEM_READ_OFFSET_PTR_ADDR = 6'h8;
 localparam MEM_READ_OFFSET_L_ADDR = 6'h9;
 localparam MEM_READ_OFFSET_H_ADDR = 6'hA;
 localparam MEM_READ_DELAY_PTR_ADDR = 6'hB;
 localparam MEM_READ_DELAY_L_ADDR = 6'hC;
 localparam MEM_READ_DELAY_H_ADDR = 6'hD;

 
 //write process
 always @ (posedge clk or posedge reset)
  begin
  if(reset == 1'b1)
	begin
		go_master <= 1'b0;
		mem_capt_ena <= 1'b0;
		mem_capt_read <= 1'b0;
		start_tod_sync <= 2'b00;
	end
  else if (csr_write && csr_address == CONTROL_ADDR )
  	begin
        go_master <= csr_writedata[0];
  		mem_capt_ena <= csr_writedata[1];
  		mem_capt_read <= csr_writedata[2];
    end
  else if (csr_write && csr_address == START_TOD_SYNC_ADDR )
  		start_tod_sync <= csr_writedata[1:0];
	
  end

	
	//read process
 always @ (posedge clk or posedge reset)
  begin
  if(reset == 1'b1)
	 csr_readdata <=32'h0;
  else if (csr_read)
	 begin
	 case (csr_address)
	  CONTROL_ADDR: csr_readdata <= {29'h0, mem_capt_read, mem_capt_ena, go_master};
	  START_TOD_SYNC_ADDR: csr_readdata <= {30'h0,start_tod_sync};
	  DELAY_FNS_H_ADDR: csr_readdata <= average_delay_fnsec[47:16];
	  DELAY_FNS_L_ADDR: csr_readdata <= {16'h0,average_delay_fnsec[15:0]};
	  OFFSET_FNS_H_ADDR: csr_readdata <= average_offset_fnsec[47:16];
	  OFFSET_FNS_L_ADDR: csr_readdata <= {16'h0,average_offset_fnsec[15:0]};
	  ERROR_ADDR: csr_readdata <= {28'h0,crc_error,slave_error,master_error};
	  CAPT_OFFSET_STATUS_ADDR: csr_readdata <= {30'h0, capt_offset_done, capt_offset_start}; 
	  MEM_READ_OFFSET_PTR_ADDR: csr_readdata <= {20'h0, mem_offset_rdaddr};
	  MEM_READ_OFFSET_L_ADDR: csr_readdata <= mem_out_offset[31:0];
	  MEM_READ_OFFSET_H_ADDR: csr_readdata <= {16'h0, mem_out_offset[47:32]};
	  MEM_READ_DELAY_PTR_ADDR: csr_readdata <= {20'h0, mem_delay_rdaddr};
      MEM_READ_DELAY_L_ADDR: csr_readdata <= mem_out_delay[31:0];
	  MEM_READ_DELAY_H_ADDR: csr_readdata <= {16'h0, mem_out_delay[47:32]};
	  default: csr_readdata <= 32'h0;
     endcase
	end
 end
 
    // Memory capture sequences
    //  1. Ensure the system is up and running (capt_offset_start == 1).
    //  2. Write 1 to go_master to start packet generation, and write 1 to mem_capt_ena to enable storing of data into memories.
    //  3. Wait until measuring process completed (capt_offset_done == 1).
    //  4. Write 1 to mem_capt_read to enter reading mode, and maintain value of 1 for mem_capt_ena register.
    //  5. Write address 0 to mem_offset_rdaddr, to indicate starting read address.
    //  6. Read from MEM_READ_OFFSET_H_ADDR and then MEM_READ_OFFSET_L_ADDR.
    //     mem_offset_rdaddr will be incremented when MEM_READ_OFFSET_L_ADDR is read.
    //     Optional to skip read from MEM_READ_OFFSET_H_ADDR if you assume value of MEM_READ_OFFSET_H_ADDR is always zero, or don't care.
    //  7. mem_offset_rdaddr will be incremented (overflow) back to 0, which indicates whole memory blocks have been read.
    //  8. Repeat steps 5, 6, and 7 for DELAY result reading process.
    //  9. Write 0 to mem_capt_read and mem_capt_ena to disable read mode and reset the capture process.
    // 10. Write 1 to mem_capt_ena to start storing data into memories again.
    // 11. Repeat steps 3 to 10 to continouosly capture the data.
    always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            mem_offset_rdaddr <= 12'h0;
            mem_delay_rdaddr  <= 12'h0;
        end
        else begin
            if (csr_write) begin
                case (csr_address)
                    MEM_READ_OFFSET_PTR_ADDR: mem_offset_rdaddr <= csr_writedata[11:0];
                    MEM_READ_DELAY_PTR_ADDR: mem_delay_rdaddr <= csr_writedata[11:0];
                    default: begin
                        mem_offset_rdaddr <= mem_offset_rdaddr;
                        mem_delay_rdaddr <= mem_delay_rdaddr;
                    end
                endcase
            end
            else if (csr_read) begin
                case (csr_address)
                    MEM_READ_OFFSET_L_ADDR: mem_offset_rdaddr <= mem_offset_rdaddr + 12'h1;
                    MEM_READ_DELAY_L_ADDR: mem_delay_rdaddr <= mem_delay_rdaddr + 12'h1;
                    default: begin
                        mem_offset_rdaddr <= mem_offset_rdaddr;
                        mem_delay_rdaddr <= mem_delay_rdaddr;
                    end
                endcase
            end
        end
    end
 
 
 //wait request
 
 reg rddly, wrdly;
   always@(posedge clk or posedge reset)
   begin
      if(reset) 
	 begin 
	      wrdly <= 1'b0; 
	      rddly <= 1'b0; 
	 end 
      else 
	 begin 
	      wrdly <= csr_write; 
	      rddly <= csr_read; 
	 end 
   end
  
   wire wredge = csr_write & ~wrdly;
   wire rdedge = csr_read  & ~rddly;

   assign csr_waitrequest = (wredge|rdedge);
 
 
endmodule	