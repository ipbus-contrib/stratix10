--------------------------------------------------------------------------------
-- Design     : conv_ipb_mac
  
-- Author     : Sebastian DITTMEIER
-- Created    : 01.12.2020 Last Modified: xx.xx.xxxx
-- Comments   : Translates between 8b IPBus AXI and 32b MAC Avalaon
--              
--          
-- 07.12.2020 : adding FIFO to have a non-interrupted valid towards the MAC; by Alessandra Camplani
----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity conv_ipb_mac is
port (
    clk                         : in  std_logic;
    rst                         : in  std_logic;

    tx_axi_data                 : in  std_logic_vector(7 downto 0);
    tx_axi_valid                : in  std_logic;
    tx_axi_last                 : in  std_logic;
    tx_axi_error                : in  std_logic;    -- no handling yet

    -- READY goint to IPbus
    tx_axi_ready                : out  std_logic                    := '0';
    
    -- Ready coming from the MAC
    tx_avst_ready               : in  std_logic;

-- converting to 32 bit
    tx_avst_data                : out std_logic_vector(31 downto 0) := (others => '0');
    tx_avst_valid               : out std_logic                     := '0';
    tx_avst_startofpacket       : out std_logic                     := '0';
    tx_avst_endofpacket         : out std_logic                     := '0';
    tx_avst_error               : out std_logic                     := '0'; -- no handling yet
    tx_avst_empty               : out std_logic_vector(1 downto 0)  := (others => '0')
);
end conv_ipb_mac;

architecture rtl of conv_ipb_mac is
-------------------------------------------------------------------------------- 
-- header (functions, limitations, assumptions, generics) 

-------------------------------------------------------------------------------- 
    -- constant declarations, component declarations, signal declarations 
    signal data_reg             : std_logic_vector(31 downto 0) := (others => '0');
    signal start_of_packet      : std_logic                     := '0';
    signal end_of_packet        : std_logic                     := '0';
    signal data_valid           : std_logic                     := '0';
    signal comb_valid           : std_logic                     := '0';
    signal cnt_4                : std_logic_vector(1 downto 0)  := (others => '0');
    signal empty                : std_logic_vector(1 downto 0)  := (others => '0');
    signal not_last             : std_logic                     := '0';

    signal end_of_packet_r      : std_logic                     := '0';
    signal reading_step         : std_logic                     := '0';

    signal fifo_data_in         : std_logic_vector(36 downto 0) := (others => '0');
    signal fifo_data_out        : std_logic_vector(36 downto 0) := (others => '0');
    signal fifo_read            : std_logic                     := '0';
    signal fifo_empty           : std_logic                     := '0';
    signal fifo_full            : std_logic                     := '0';
    signal fifo_usedw           : std_logic_vector(12 downto 0) := (others => '0');

    type state_type              is (idle, reading);
    signal state                 : state_type;

    component To_MAC_fifo is
        port (
            data  : in  std_logic_vector(36 downto 0) := (others => 'X'); -- datain
            wrreq : in  std_logic                     := 'X';             -- wrreq
            rdreq : in  std_logic                     := 'X';             -- rdreq
            clock : in  std_logic                     := 'X';             -- clk
            q     : out std_logic_vector(36 downto 0);                    -- dataout
            usedw : out std_logic_vector(12 downto 0);                    -- usedw
            full  : out std_logic;                                        -- full
            empty : out std_logic                                         -- empty
        );
    end component To_MAC_fifo;

begin
-- component instances, processes, combinatorial expressions
    schedule : process(rst, clk)
    begin
        if(rising_edge(clk))then
            if(rst = '1')then
                start_of_packet   <= '0';
                end_of_packet     <= '0';
                tx_avst_error     <= '0';                 -- no handling yet
                empty             <= (others => '0');     -- used for zero padding for last word!
                -- set to 0 if all 32b are valid, 1 if LSByte is invalid, 2 if 2 LSBytes are invalid, 3 if 3 LSBytes are invalid
                data_valid        <= '0';
                cnt_4             <= "00";
                not_last          <= '0';
            else
                -- combine the 8b words to 32b words using shift register
                -- assumption: first word is MSB, 4th word is LSB
                -- no handling of tx_axi_error yet
                -- we only process data if the MAC is ready
                -- as we directly forward the ready signal to IPBus
                -- IPBus keeps the valid high but does not change data while ready is low
                if(tx_axi_valid = '1' and tx_avst_ready = '1')then
                    data_reg(31 downto 8)   <= data_reg(23 downto 0);
                    data_reg(7 downto 0)    <= tx_axi_data;
                    cnt_4                   <= cnt_4 + 1;
                    if(cnt_4 = "11")then    -- now we have filled a 32b word, set valid signal
                        data_valid  <= '1';
                        empty       <= "00";
                        not_last    <= not tx_axi_last;
                        if(tx_axi_last = '0' and not_last = '0')then
                            start_of_packet <= '1';
                        end if;
                        if(tx_axi_last = '1')then
                            end_of_packet   <= '1';
                        end if;
                    end if;
                end if;
                
                -- we only lift the data_valid if ready is high, otherwise we also stall the valid high
                -- actually we remove all control signals
                if(data_valid = '1' and tx_avst_ready = '1')then
                    data_valid              <= '0';
                    start_of_packet   <= '0';
                    end_of_packet     <= '0';
                    empty             <= "00";
                end if;
                
                --peculiar case: last word of IPBus is not 4 Bytes long
                if(tx_axi_valid = '1' and tx_avst_ready = '1')then
                    if(cnt_4 = "11")then    -- now we have filled a 32b word, set valid signal
                    else    -- not 4 Bytes with last word!
                        if(tx_axi_last = '1')then   -- catching the last word to be shorter 4 Bytes
                            data_valid          <= '1';
                            not_last            <= not tx_axi_last; -- set to zero
                            if(not_last = '0')then -- in case that it's just a single word with less than 4 bytes
                                start_of_packet <= '1';
                            end if;
                            end_of_packet       <= '1';
                            empty               <= "11"-cnt_4;  -- first word, cnt_4 is "00" -> so avst_empty should be "11", and so on 
                            cnt_4               <= "00";    -- reset the counter
                            if(cnt_4 = "00")then
                                data_reg(31 downto 24)  <= tx_axi_data;
                            elsif(cnt_4 = "01")then
                                data_reg(31 downto 24)  <= data_reg(7 downto 0);
                                data_reg(23 downto 16)  <= tx_axi_data;
                            
                            elsif(cnt_4 = "10")then
                                data_reg(31 downto 16) <= data_reg(15 downto 0);
                                data_reg(15 downto 8)  <= tx_axi_data;
                            end if;
                        end if;
                    end if;
                end if;
                
            end if; -- rst
        end if; -- clk
    end process schedule;
    

--    tx_avst_data    <= data_reg;
--    tx_avst_valid   <= data_valid;
    tx_axi_ready    <= tx_avst_ready;


-- An underflow could occur on the Avalon streaming TX interface. An underflow occurs
-- when the avalon_st_tx_valid signal is deasserted in the middle of frame
-- transmission. 
-- Underflow will prevent you packat from be sent back proparly to the machine.
-- For this reason we must make the packet compact, with no space between the valids.

------------------------------------------------------------------------------------------------
-- Fifo input data 
    fifo_data_in <= start_of_packet & end_of_packet & data_reg & data_valid & empty;

    fifo_out : component To_MAC_fifo
        port map (
            clock => clk, --            .clk
            data  => fifo_data_in,  --  fifo_input.datain
            wrreq => data_valid, --            .wrreq

            rdreq => fifo_read, --            .rdreq
            q     => fifo_data_out,     -- fifo_output.dataout

            usedw => fifo_usedw, --            .usedw
            full  => fifo_full,  --            .full
            empty => fifo_empty  --            .empty
        );
------------------------------------------------------------------------------------------------
-- State machine for reading

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                state <= idle;
            else
                end_of_packet_r  <= end_of_packet;
                
                case state is
                
                    when idle =>
                        if end_of_packet = '1' then
                            state <= reading;
                        else
                            state <= idle;
                        end if;
                    
                    when reading =>
                        if tx_avst_ready = '1' and fifo_data_out(35) = '1' then
                            state <= idle;
                        else
                            state <= reading;
                        end if;
                        
                end case;
            end if;
        end if;
    end process;

    fifo_read     <= tx_avst_ready      when  state = reading   else '0';
    reading_step  <= '1'                when  state = reading   else '0';

    tx_avst_empty               <= fifo_data_out(1 downto 0);
    -- to keep the valid high only during reading state
    tx_avst_valid               <= (fifo_data_out(2) and (tx_avst_startofpacket or reading_step));
    tx_avst_data                <= fifo_data_out(34 downto 3);
    tx_avst_endofpacket         <= fifo_data_out(35);
    -- to keep the sop only 1 clk cycle short
    tx_avst_startofpacket       <= fifo_data_out(36) and end_of_packet_r;

end rtl;
