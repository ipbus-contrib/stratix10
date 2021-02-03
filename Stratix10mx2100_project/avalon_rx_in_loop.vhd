------------------------------  <-  80 chars  ->  ------------------------------
--! Design     : avalon_rx_in_loop.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 28.10.20
--! Comments   : To be used only for loopback test
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_rx_in_loop is
port (
    mac_clk                     : in  std_logic;
    reset                       : in  std_logic;
  
    avalon_st_rx_valid          : out std_logic;
    avalon_st_rx_startofpacket  : out std_logic;
    avalon_st_rx_endofpacket    : out std_logic;
    avalon_st_rx_data           : out std_logic_vector(31 downto 0);
    avalon_st_rx_empty          : out std_logic_vector(1 downto 0);
    avalon_st_rx_error          : out std_logic_vector(5 downto 0)
    );
end avalon_rx_in_loop;

architecture behav of avalon_rx_in_loop is

    signal counter_mac          : unsigned(13 downto 0) := (others => '0');  

begin

    counter_proc: process(mac_clk)
    begin
        if rising_edge(mac_clk) then
           if reset = '1' then
               counter_mac <= (others => '0');
           else
               counter_mac <= counter_mac + 1;
               if counter_mac = "11111111111111" then 
                   counter_mac <= (others => '0'); 
               end if;
           end if;
        end if;
    end process;

-- the folllowing packet is an example of ARP request
    avalon_st_rx_valid     <=    '1' when ((counter_mac > 13004) and (counter_mac <= 13005)) else
                                 '1' when ((counter_mac > 13009) and (counter_mac <= 13010)) else
                                 '1' when ((counter_mac > 13014) and (counter_mac <= 13015)) else
                                 '1' when ((counter_mac > 13019) and (counter_mac <= 13020)) else
                                 '1' when ((counter_mac > 13024) and (counter_mac <= 13025)) else
                                 '1' when ((counter_mac > 13029) and (counter_mac <= 13030)) else
                                 '1' when ((counter_mac > 13034) and (counter_mac <= 13035)) else
                                 '1' when ((counter_mac > 13039) and (counter_mac <= 13040)) else
                                 '1' when ((counter_mac > 13044) and (counter_mac <= 13045)) else
                                 '1' when ((counter_mac > 13049) and (counter_mac <= 13050)) else
                                 '1' when ((counter_mac > 13054) and (counter_mac <= 13055)) else
                                 '1' when ((counter_mac > 13059) and (counter_mac <= 13060)) else
                                 '1' when ((counter_mac > 13064) and (counter_mac <= 13065)) else
                                 '1' when ((counter_mac > 13069) and (counter_mac <= 13070)) else
                                 '1' when ((counter_mac > 13079) and (counter_mac <= 13080)) else
                                 '1' when ((counter_mac > 13089) and (counter_mac <= 13090)) else
                                 '0';

    avalon_st_rx_startofpacket  <=    '1' when ((counter_mac > 13004) and (counter_mac <= 13005)) else
                                      '0';

    avalon_st_rx_endofpacket    <=    '1' when ((counter_mac > 13089) and (counter_mac <= 13090)) else
                                      '0';

    avalon_st_rx_data      <=    x"FFFFFFFF" when ((counter_mac > 13000) and (counter_mac <= 13005)) else
                                 x"FFFF507B" when ((counter_mac > 13005) and (counter_mac <= 13010)) else
                                 x"9DCEB902" when ((counter_mac > 13010) and (counter_mac <= 13015)) else
                                 x"08060001" when ((counter_mac > 13015) and (counter_mac <= 13020)) else
                                 x"08000604" when ((counter_mac > 13020) and (counter_mac <= 13025)) else
                                 x"0001507B" when ((counter_mac > 13025) and (counter_mac <= 13030)) else
                                 x"9DCEB902" when ((counter_mac > 13030) and (counter_mac <= 13035)) else
                                 x"C0A8C802" when ((counter_mac > 13035) and (counter_mac <= 13040)) else
                                 x"00000000" when ((counter_mac > 13040) and (counter_mac <= 13045)) else
                                 x"0000C0A8" when ((counter_mac > 13045) and (counter_mac <= 13050)) else
                                 x"C8100000" when ((counter_mac > 13050) and (counter_mac <= 13055)) else
                                 x"00000000" when ((counter_mac > 13055) and (counter_mac <= 13060)) else
                                 x"00000000" when ((counter_mac > 13060) and (counter_mac <= 13065)) else
                                 x"00000000" when ((counter_mac > 13065) and (counter_mac <= 13070)) else
                                 x"11ffaa55" when ((counter_mac > 13070) and (counter_mac <= 13080)) else
                                 x"A1241DB7" when ((counter_mac > 13080) and (counter_mac <= 13090)) else
                                 x"00000000";

    --avalon_st_rx_ready          <=    '1';

    avalon_st_rx_error          <=    "000000";

    avalon_st_rx_empty          <=    "00";

end behav;
