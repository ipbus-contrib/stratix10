------------------------------------------------- ------------------------------
--! Design     : valid_8to32.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 10.11.2019
--! Comments   : 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity valid_8to32 is
  port(
    clk                         : in  std_logic;
    rst                         : in  std_logic;

    tx_axi_data                 : in  std_logic_vector(7 downto 0);
    tx_axi_valid                : in  std_logic;
    tx_axi_last                 : in  std_logic;
    tx_axi_error                : in  std_logic;

    -- READY goint to IPbus
    tx_axi_ready                : out  std_logic                    := '0';
    
    -- Ready coming from the MAC
    tx_avst_ready               : in  std_logic;

-- converting to 32 bit
    tx_avst_data                : out std_logic_vector(31 downto 0) := (others => '0');
    tx_avst_valid               : out std_logic                     := '0';
    tx_avst_startofpacket       : out std_logic                     := '0';
    tx_avst_endofpacket         : out std_logic                     := '0';
    tx_avst_error               : out std_logic                     := '0';
    tx_avst_empty               : out std_logic_vector(1 downto 0)  := (others => '0')

  );
end valid_8to32;

architecture rtl of valid_8to32 is

    signal fifo_AXIdata_in          : std_logic_vector(10 downto 0) := (others => '0'); 
    signal fifo_AXIdata_out         : std_logic_vector(10 downto 0) := (others => '0'); 
    signal fifo_AXI_read            : std_logic := '0';
    signal fifo_AXI_empty           : std_logic := '0';
    signal fifo_AXI_full            : std_logic := '0';
    signal fifo_AXI_afull           : std_logic := '0';
    
    signal axi_data                 : std_logic_vector(7 downto 0);
    signal axi_valid                : std_logic;
    signal axi_last                 : std_logic;
    signal axi_error                : std_logic;

    -- TX info 8 bit
    signal avst_8_data              : std_logic_vector(7 downto 0)   := (others => '0');
    signal avst_8_valid             : std_logic                      := '0';
    signal avst_8_startofpacket     : std_logic                      := '0';
    signal avst_8_endofpacket       : std_logic                      := '0';
    signal avst_8_empty             : std_logic_vector(1 downto 0)   := (others => '0');
    signal avst_8_error             : std_logic                      := '0';

    signal flag_for_start           : std_logic                      := '1';
    signal startofpacket            : std_logic                      := '1';

    type AV_state_type              is (idle, read0, read1, read2, read3, write_last1, write_last2, write_last0, pad1, pad2, pad0, end_of_valid, waiting_time);
    signal AV_state                 : AV_state_type;

    signal standby_cnt              : unsigned(3 downto 0)          := (others => '0');
    signal sm_busy                  : std_logic := '0';
    signal bit32_started            : std_logic := '0';
    signal bit32_completed          : std_logic := '0';
    signal end_packet               : std_logic := '0';
    signal avst_8_endofpacket_r     : std_logic := '0';
    
    signal avst_8_data_r            : std_logic_vector(7 downto 0)  := (others => '0'); 
    signal tx_avst_data_i           : std_logic_vector(31 downto 0) := (others => '0'); 

    signal internal_avst_data           : std_logic_vector(31 downto 0) := (others => '0');
    signal internal_avst_valid          : std_logic                     := '0';
    signal internal_avst_startofpacket  : std_logic                     := '0';
    signal internal_avst_endofpacket    : std_logic                     := '0';
    signal internal_avst_error          : std_logic                     := '0';
    signal internal_avst_empty          : std_logic_vector(1 downto 0)  := (others => '0');
    
    signal fifo_toMAC_data_in           : std_logic_vector(34 downto 0) := (others => '0');
    signal fifo_toMAC_data_out          : std_logic_vector(34 downto 0) := (others => '0');

    signal toMAC_usedw                  : std_logic_vector(12 downto 0) := (others => '0');
    signal toMAC_full                   : std_logic                     := '0';
    signal toMAC_empty                  : std_logic                     := '0';

    component axi_fifo_8 is
        port (
            data        : in  std_logic_vector(10 downto 0) := (others => 'X'); -- datain
            wrreq       : in  std_logic                    := 'X';             -- wrreq
            rdreq       : in  std_logic                    := 'X';             -- rdreq
            clock       : in  std_logic                    := 'X';             -- clk
            q           : out std_logic_vector(10 downto 0);                    -- dataout
            full        : out std_logic;                                       -- full
            empty       : out std_logic;                                       -- empty
            almost_full : out std_logic                                        -- almost_full
        );
    end component axi_fifo_8;

    component To_MAC_fifo is
        port (
            data  : in  std_logic_vector(34 downto 0) := (others => 'X'); -- datain
            wrreq : in  std_logic                     := 'X';             -- wrreq
            rdreq : in  std_logic                     := 'X';             -- rdreq
            clock : in  std_logic                     := 'X';             -- clk
            q     : out std_logic_vector(34 downto 0);                    -- dataout
            usedw : out std_logic_vector(12 downto 0);                    -- usedw
            full  : out std_logic;                                        -- full
            empty : out std_logic                                         -- empty
        );
    end component To_MAC_fifo;
    
begin

--------------------------------------------------------
-- Please refer to the ticket opened in the IPbus repo
-- https://github.com/ipbus/ipbus-firmware/issues/186

-- some of the suggestion mentioned here could not be applied
-- e.g. (i) the fifo that should get 8bit in input and 32 in output 
-- input and output clock are the same, the first event would always be not as one wish
-- (ii) in case of full (almost full not available) the data would still be paused 
-- having a fifo written with multiple copied of the same data (as valid would be high
-- and valid is used to write)
-- This would leave with the same problem ecountered when the ticket was opened
-- 
-- Instead a AXI ready always set to 1 could avoid this (of course it's more risky)
-- But this could be the right strategy.
-- The flag full will be connected to the error signal
-- Fifos quite deep will be used to try to mitigate problems

--------------------------------------------------------
-- AXI data dump from IPbus and AXI ready
--------------------------------------------------------
    
    -- Ready always set to high to get a continuous flow from the IPbus block
    tx_axi_ready        <= '1';
    
    -- To preserve all the AXI info
    fifo_AXIdata_in     <= tx_axi_data & tx_axi_valid & tx_axi_last & tx_axi_error;
    
    -- read when not empty
    fifo_AXI_read       <= (not (fifo_AXI_empty)) and (not (sm_busy));
    
    -- to dump the data and not lose anything
    axi_dump : component axi_fifo_8
        port map (
            clock       => clk,
            wrreq       => tx_axi_valid,
            data        => fifo_AXIdata_in,

            rdreq       => fifo_AXI_read,
            q           => fifo_AXIdata_out,

            full        => fifo_AXI_full,
            empty       => fifo_AXI_empty,
            almost_full => fifo_AXI_afull
        );

            axi_data    <= fifo_AXIdata_out(10 downto 3);
            axi_valid   <= fifo_AXIdata_out(2);
            axi_last    <= fifo_AXIdata_out(1);
            axi_error   <= fifo_AXIdata_out(0) or fifo_AXI_full;
            

--------------------------------------------------------
-- AXI to avalon conversion and start signal creation
--------------------------------------------------------
--- start of packet creation detection upon valid and last
    sop : process (clk,rst)
    begin
        if rising_edge(clk) then
            if axi_valid = '1' and axi_last = '0' then
                flag_for_start <= '1';
            else
                flag_for_start <= '0';
            end if;
        end if;
    end process;

-- start of packet 1 clk cycle long
  low_hi_start: entity work.hilo_detect
  generic map (
      lohi    => true   -- switch sense to low -> high
  )
  port map (
      clk     => clk,     -- clock
      sig_in  => flag_for_start,     -- input signal
      sig_out => startofpacket      -- output signal
  );

    avst_8_data            <= axi_data;
    avst_8_endofpacket     <= axi_last;
    avst_8_error           <= axi_error;
    avst_8_valid           <= axi_valid;
    avst_8_startofpacket   <= startofpacket;


--------------------------------------------------------
-- SM for 32 bit data preparation and controls recreation
--------------------------------------------------------
    -- possible padding available
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                AV_state <= idle;
            else
                avst_8_data_r <= avst_8_data;
                avst_8_endofpacket_r <= avst_8_endofpacket;
                case AV_state is
                
                    when idle =>
                        if avst_8_valid = '1' and avst_8_endofpacket = '0' then
                            AV_state <= read0;
                        else
                            AV_state <= idle;
                        end if;
                    
                    when read0 =>
                        if avst_8_endofpacket_r = '1' then
                            AV_state <= write_last0;
                        else
                            AV_state <= read1;
                        end if;
    
                    when read1 =>
                        if avst_8_endofpacket_r = '1' then
                            AV_state <= write_last1;
                        else
                            AV_state <= read2;
                        end if;
    
                    when read2 =>
                        if avst_8_endofpacket_r = '1' then
                            AV_state <= write_last2;
                        else
                            AV_state <= read3;
                        end if;
                    
                    when read3 =>
                        if avst_8_endofpacket_r = '1' then
                            AV_state <= end_of_valid;
                        else
                            AV_state <= read0;
                        end if;

                    when write_last0 =>
                        AV_state <= pad0;

                    when write_last1 =>
                        AV_state <= pad1;

                    when write_last2 =>
                        AV_state <= pad2;

                    when pad0 =>
                        AV_state <= pad1;
                        
                    when pad1 =>
                        AV_state <= pad2;

                    when pad2 =>
                        AV_state <= end_of_valid;
                        
                    when end_of_valid =>
                        AV_state       <= waiting_time;
                        standby_cnt <= (others => '0');

                    when waiting_time =>
                        standby_cnt <= standby_cnt + 1;
                        if standby_cnt = "1100" then
                            AV_state <= idle;
                        else
                            AV_state <= waiting_time;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
            
            elsif AV_state = read0 then
                tx_avst_data_i(31 downto 24)    <= avst_8_data_r;
                bit32_started                   <= '1';
                bit32_completed                 <= '0';

            elsif AV_state = read1 then
                tx_avst_data_i(23 downto 16)    <= avst_8_data_r;
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = read2 then
                tx_avst_data_i(15 downto 8)     <= avst_8_data_r;
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = read3 then
                tx_avst_data_i(7 downto 0)      <= avst_8_data_r;
                bit32_started                   <= '0';
                bit32_completed                 <= '1';
                
            elsif AV_state = write_last0 then
                tx_avst_data_i(31 downto 24)    <= avst_8_data_r;
                bit32_started                   <= '1';
                bit32_completed                 <= '0';

            elsif AV_state = write_last1 then
                tx_avst_data_i(23 downto 16)    <= avst_8_data_r;
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = write_last2 then
                tx_avst_data_i(15 downto 8)    <= avst_8_data_r;
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = pad0 then
                tx_avst_data_i(23 downto 16)    <= (others => '0');
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = pad1 then
                tx_avst_data_i(15 downto 8)    <= (others => '0');
                bit32_started                   <= '0';
                bit32_completed                 <= '0';

            elsif AV_state = pad2 then
                tx_avst_data_i(7 downto 0)     <= (others => '0');
                bit32_started                   <= '0';
                bit32_completed                 <= '1';
            
            else
                tx_avst_data_i(31 downto 24)    <= tx_avst_data_i(31 downto 24);
                tx_avst_data_i(23 downto 16)    <= tx_avst_data_i(23 downto 16);
                tx_avst_data_i(15 downto 8)     <= tx_avst_data_i(15 downto 8) ;
                tx_avst_data_i(7 downto 0)      <= tx_avst_data_i(7 downto 0)  ;
                bit32_started                   <= '0';
                bit32_completed                 <= '0';
            end if;
        end if;
    end process;

    end_packet                        <= '1'             when  AV_state = end_of_valid   else '0';
    sm_busy                           <= '1'             when (AV_state = end_of_valid   or
                                                               AV_state = waiting_time)  else '0';
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                internal_avst_data        <= (others => '0');
                internal_avst_valid       <= '0';
                internal_avst_endofpacket <= '0';
            elsif bit32_completed = '1' then
                internal_avst_data        <= tx_avst_data_i;
                internal_avst_valid       <= bit32_completed;
                internal_avst_endofpacket <= end_packet;
            else
                internal_avst_data  <= (others => '0');
                internal_avst_valid <= '0';
                internal_avst_endofpacket <= '0';
            end if;
        end if;
    end process;

-- Delays to align the controls
    start_d: entity work.DELAY_CHAIN
    generic map (
        D_DEPTH     => 5     -- number of clock cycles it shell be delayed
    )
    port map (
        CLK         => clk,     -- clock
        RST         => rst,     -- sync reset
        SIG_IN(0)   => avst_8_startofpacket,     -- input signal
        SIG_OUT(0)  => internal_avst_startofpacket      -- delayed output signal
    );

--------------------------------------------------------
-- FIFO just before the MAC
--------------------------------------------------------
    fifo_toMAC_data_in <= internal_avst_data & internal_avst_startofpacket & internal_avst_endofpacket & internal_avst_valid;

    fifo_before_MAC : component To_MAC_fifo
        port map (
            clock => clk, 
            wrreq => internal_avst_valid, --              probably some zeroes from the waiting time should be added here
            data  => fifo_toMAC_data_in,
            
            rdreq => tx_avst_ready, --            .rdreq
            q     => fifo_toMAC_data_out,     -- fifo_output.dataout
            
            usedw => toMAC_usedw, --            .usedw
            full  => toMAC_full,  --            .full
            empty => toMAC_empty  --            .empty
        );

    tx_avst_data            <= fifo_toMAC_data_out(34 downto 3);
    tx_avst_startofpacket   <= fifo_toMAC_data_out(2) and (not toMAC_empty) and tx_avst_ready;
    tx_avst_endofpacket     <= fifo_toMAC_data_out(1) and (not toMAC_empty) and tx_avst_ready;
    tx_avst_valid           <= fifo_toMAC_data_out(0) and (not toMAC_empty) and tx_avst_ready;
    tx_avst_error           <= '0';
    tx_avst_empty           <= (others => '0');

end rtl;
