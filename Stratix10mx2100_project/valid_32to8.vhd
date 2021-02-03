------------------------------------------------- ------------------------------
--! Design     : monitoring.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 9.11.2019
--! Comments   : monitoring block top level
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity valid_32to8 is
  port(
    clk                         : in  std_logic;
    rst                         : in  std_logic;

    ready_from_IPBUS            : in  std_logic;
    
    -- Coming from MAC, 32 bit info
    rx_avst_data                : in  std_logic_vector(31 downto 0);
    rx_avst_valid               : in  std_logic;
    rx_avst_startofpacket       : in  std_logic;
    rx_avst_endofpacket         : in  std_logic;
    rx_avst_error               : in  std_logic_vector(5 downto 0);
    rx_avst_empty               : in  std_logic_vector(1 downto 0);

    -- converting to 8 bit data
    rx_avst_8_data              : out std_logic_vector(7 downto 0) := (others => '0');
    rx_avst_8_valid             : out std_logic := '0';
    rx_avst_8_startofpacket     : out std_logic := '0';
    rx_avst_8_endofpacket       : out std_logic := '0';
    rx_avst_8_error             : out std_logic_vector(5 downto 0) := (others => '0');
    rx_avst_8_empty             : out std_logic_vector(1 downto 0) := (others => '0')

  );
end valid_32to8;

architecture rtl of valid_32to8 is

    -- FIFO signals
    signal fifo_data_in         : std_logic_vector(32 downto 0) := (others => '0');
    signal fifo_data_out        : std_logic_vector(32 downto 0) := (others => '0');
    signal fifo_read            : std_logic                     := '0';
    signal fifo_empty           : std_logic                     := '0';
    signal fifo_full            : std_logic                     := '0';
    
    signal data                 : std_logic_vector(31 downto 0) := (others => '0');
    signal sop                  : std_logic                     := '0';
    signal eop                  : std_logic                     := '0';
    
    -- SM signals 
    type state_type                 is (idle, init, readout, read0, read1, read2, read3, waiting, endpacket);
    signal state                    : state_type;

    signal SMbusy               : std_logic                    := '0';
    signal state0               : std_logic                    := '0';
    signal state1               : std_logic                    := '0';
    signal state2               : std_logic                    := '0';
    signal state3               : std_logic                    := '0';

    signal build_valid          : std_logic                    := '0';
    signal new_start            : std_logic                    := '0';
    signal new_start_r          : std_logic                    := '0';
    signal new_start_rr         : std_logic                    := '0';
    signal new_start_rrr        : std_logic                    := '0';
    signal new_end              : std_logic                    := '0';

    component valid_32to8fifo is
        port (
            data  : in  std_logic_vector(32 downto 0) := (others => 'X'); -- datain
            wrreq : in  std_logic                    := 'X';             -- wrreq
            rdreq : in  std_logic                    := 'X';             -- rdreq
            clock : in  std_logic                    := 'X';             -- clk
            q     : out std_logic_vector(32 downto 0);                    -- dataout
            full  : out std_logic;                                       -- full
            empty : out std_logic                                        -- empty
        );
    end component valid_32to8fifo;
    
    component hilo_detect is
        generic (
            lohi    : boolean := false
        );
        port (
            clk     : in  std_logic;
            sig_in  : in  std_logic;
            sig_out : out std_logic
        );
    end component;

begin

-------------------------------------------------------
--- FIFO for 32 + start + stop from MAC
--------------------------------------------------------

    fifo_data_in <= rx_avst_data & rx_avst_endofpacket;

    fifo32_frommac : component valid_32to8fifo
        port map (
            clock => clk, --            .clk
            
            data  => fifo_data_in,  --  fifo_input.datain
            wrreq => rx_avst_valid, --            .wrreq

            rdreq => fifo_read, --            .rdreq
            q     => fifo_data_out,     -- fifo_output.dataout
            
            full  => fifo_full,  --            .full
            empty => fifo_empty  --            .empty
        );

    data <= fifo_data_out(32 downto 1);
    eop  <= fifo_data_out(0);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= idle;
            else
                case state is

                    when idle =>
                        if (fifo_empty = '0') then
                            state <= init;
                        else
                            state <= idle;
                        end if;

                    when init =>
                    state <= readout;

                    when readout =>
                    state <= read0;

                    when read0 =>
                    state <= read1;

                    when read1 =>
                    state <= read2;

                    when read2 =>
                    state <= read3;

                    when read3 =>
                        if (fifo_empty = '1') and (eop = '0') then
                            state <= waiting;
                        elsif (eop = '0') and (fifo_empty = '0') then
                            state <= readout;
                        elsif (eop = '1') then
                            state <= endpacket;
                        end if;
                    
                    when waiting =>
                        if fifo_empty = '0' then 
                            state <= readout;
                        else
                            state <= waiting;
                        end if;
                    
                    when endpacket =>
                    state <= idle;

                end case;
            end if;
        end if;
    end process;
    
    SMbusy      <= '0' when state = idle           else '1';

    fifo_read   <= '1' when state = readout           else '0';
    
    state0      <= '1' when state = read3           else '0';
    state1      <= '1' when state = read2           else '0';
    state2      <= '1' when state = read1           else '0';
    state3      <= '1' when state = read0           else '0';
    
    new_start   <= '1' when state = init            else '0';
    new_end     <= '1' when state = endpacket       else '0';


--- to redirect all the data into rx_avst_8_data
--- Data preparation
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then

            else
            
                build_valid     <= state0 or state1 or state2 or state3;
                new_start_r     <= new_start;
                new_start_rr    <= new_start_r;
                new_start_rrr   <= new_start_rr;
                
                if state0 = '1' then
                    rx_avst_8_data <= data(7 downto 0);
    
                elsif state1 = '1' then
                    rx_avst_8_data <= data(15 downto 8);
    
                elsif state2 = '1' then
                    rx_avst_8_data <= data(23 downto 16);
    
                elsif state3 = '1' then
                    rx_avst_8_data <= data(31 downto 24);
                end if;
            end if;
        end if;
    end process;

    rx_avst_8_valid         <= build_valid;
    rx_avst_8_startofpacket <= new_start_rrr;
    rx_avst_8_endofpacket   <= new_end;
    rx_avst_8_error         <= (others => '0');
    rx_avst_8_empty         <= (others => '0');

end rtl;
