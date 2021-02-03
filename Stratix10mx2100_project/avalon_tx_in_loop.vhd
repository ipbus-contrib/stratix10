------------------------------  <-  80 chars  ->  ------------------------------
--! Design     : avalon_tx_in_loop.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 28.10.20
--! Comments   : To be used only for loopback test
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_tx_in_loop is
port (
    mac_clk                     : in  std_logic;
    reset                       : in  std_logic;
        
    avalon_st_rx_ready          : out std_logic;
  
    avalon_st_tx_valid          : out std_logic;
    avalon_st_tx_startofpacket  : out std_logic;
    avalon_st_tx_endofpacket    : out std_logic;
    avalon_st_tx_data           : out std_logic_vector(31 downto 0);
    avalon_st_tx_empty          : out std_logic_vector(1 downto 0);
    avalon_st_tx_error          : out std_logic
    );
end avalon_tx_in_loop;

architecture behav of avalon_tx_in_loop is

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

-- The following data are taken from the ethernet Simulation of the example design,
-- the one with 1G/2.5G for both arria and stratix -- At time 458720938 ps
-- FYI : The one on which is based this entire design is the one from Arria (that does not have some not necessary features)

--    -- RX signal
--    avalon_st_rx_ready          <=    '1' when (counter_mac > 10000) else
--                                      '0';
--    -- TX signals
--    avalon_st_tx_valid          <=    '1' when ((counter_mac > 13000) and (counter_mac < 13018)) else
--                                      '0';
--
--    avalon_st_tx_startofpacket  <=    '1' when ((counter_mac > 11000) and (counter_mac < 13002)) else
--                                      '1' when ((counter_mac > 13017) and (counter_mac < 13999)) else
--                                      '0';
--
--    avalon_st_tx_endofpacket    <=    '1' when ((counter_mac > 13016) and (counter_mac < 13018)) else
--                                      '0';
--
--    avalon_st_tx_data           <=    x"eecc88cc" when ((counter_mac > 11000) and (counter_mac <= 13001)) else
--                                      x"aaeeeecc" when ((counter_mac > 13001) and (counter_mac <= 13002)) else
--                                      x"88ccaaee" when ((counter_mac > 13002) and (counter_mac <= 13003)) else
--                                      x"88f700dd" when ((counter_mac > 13003) and (counter_mac <= 13004)) else
--                                      x"dddddddd" when ((counter_mac > 13004) and (counter_mac <= 13006)) else
--                                      x"ddddddde" when ((counter_mac > 13006) and (counter_mac <= 13007)) else
--                                      x"d899dddd" when ((counter_mac > 13007) and (counter_mac <= 13008)) else
--                                      x"dddddddd" when ((counter_mac > 13008) and (counter_mac <= 13012)) else
--                                      x"00000000" when ((counter_mac > 13012) and (counter_mac <= 13013)) else
--                                      x"00000006" when ((counter_mac > 13013) and (counter_mac <= 13014)) else
--                                      x"fa670000" when ((counter_mac > 13014) and (counter_mac <= 13015)) else
--                                      x"00000000" when ((counter_mac > 13015) and (counter_mac <= 13017)) else
--                                      x"eecc88cc" when ((counter_mac > 13017) and (counter_mac <= 13999)) else
--                                      x"00000000";
--
--    avalon_st_tx_empty          <=    "00";
--
--    avalon_st_tx_error          <=    '0';
    

-- the folllowing packet is an example of PING message (nicely owrking in SIM)
-- https://hpd.gasmi.net/

--    -- RX signal
--    avalon_st_rx_ready          <=    '1' when (counter_mac > 10000) else
--                                      '0';
--    -- TX signals
--    avalon_st_tx_valid          <=    '1' when ((counter_mac > 13000) and (counter_mac <= 13015)) else
--                                      '0';
--
--    avalon_st_tx_startofpacket  <=    '1' when ((counter_mac > 13000) and (counter_mac <= 13001)) else
--                                      '1' when ((counter_mac > 13015) and (counter_mac < 13999)) else
--                                      '0';
--
--    avalon_st_tx_endofpacket    <=    '1' when ((counter_mac >= 13015) and (counter_mac < 13016)) else
--                                      '0';
--
--    avalon_st_tx_data           <=      x"020DDBA1" when ((counter_mac > 13000) and (counter_mac <= 13001)) else
--                                        x"15100000" when ((counter_mac > 13001) and (counter_mac <= 13002)) else
--                                        x"5E000101" when ((counter_mac > 13002) and (counter_mac <= 13003)) else
--                                        x"08004500" when ((counter_mac > 13003) and (counter_mac <= 13004)) else
--                                        x"00280000" when ((counter_mac > 13004) and (counter_mac <= 13005)) else
--                                        x"0000FF01" when ((counter_mac > 13005) and (counter_mac <= 13006)) else
--                                        x"19E1C0A8" when ((counter_mac > 13006) and (counter_mac <= 13007)) else
--                                        x"C801C0A8" when ((counter_mac > 13007) and (counter_mac <= 13008)) else
--                                        x"C8100800" when ((counter_mac > 13008) and (counter_mac <= 13009)) else
--                                        x"C8010001" when ((counter_mac > 13009) and (counter_mac <= 13010)) else
--                                        x"5652C0A8" when ((counter_mac > 13010) and (counter_mac <= 13011)) else
--                                        x"00010000" when ((counter_mac > 13011) and (counter_mac <= 13012)) else
--                                        x"00000000" when ((counter_mac > 13012) and (counter_mac <= 13013)) else
--                                        x"00000000" when ((counter_mac > 13013) and (counter_mac <= 13014)) else
--                                        x"00000000" when ((counter_mac > 13014) and (counter_mac <= 13015)) else
--                                        x"00000000";
--
--    avalon_st_tx_empty          <=    "00";
--
--    avalon_st_tx_error          <=    '0';

-- the folllowing packet is an example of ARP request
    -- RX signal
    avalon_st_rx_ready          <=      '1' when (counter_mac > 10000) else
                                        '0';
    -- TX signals
    avalon_st_tx_valid          <=      '1' when ((counter_mac > 13000) and (counter_mac <= 13015)) else
                                        '0';

    avalon_st_tx_startofpacket  <=      '1' when ((counter_mac > 13000) and (counter_mac <= 13001)) else
                                        '1' when ((counter_mac > 13015) and (counter_mac < 13999)) else
                                        '0';

    avalon_st_tx_endofpacket    <=      '1' when ((counter_mac >= 13015) and (counter_mac < 13016)) else
                                        '0';

    avalon_st_tx_data           <=      x"FFFFFFFF" when ((counter_mac > 13000) and (counter_mac <= 13001)) else
                                        x"FFFF507B" when ((counter_mac > 13001) and (counter_mac <= 13002)) else
                                        x"9DCFB902" when ((counter_mac > 13002) and (counter_mac <= 13003)) else
                                        x"08060001" when ((counter_mac > 13003) and (counter_mac <= 13004)) else
                                        x"08000604" when ((counter_mac > 13004) and (counter_mac <= 13005)) else
                                        x"0001507B" when ((counter_mac > 13005) and (counter_mac <= 13006)) else
                                        x"9DCFB902" when ((counter_mac > 13006) and (counter_mac <= 13007)) else
                                        x"C0A8C802" when ((counter_mac > 13007) and (counter_mac <= 13008)) else
                                        x"00000000" when ((counter_mac > 13008) and (counter_mac <= 13009)) else
                                        x"0000C0A8" when ((counter_mac > 13009) and (counter_mac <= 13010)) else
                                        x"C8100000" when ((counter_mac > 13010) and (counter_mac <= 13011)) else
                                        x"00000000" when ((counter_mac > 13011) and (counter_mac <= 13012)) else
                                        x"00000000" when ((counter_mac > 13012) and (counter_mac <= 13013)) else
                                        x"00000000" when ((counter_mac > 13013) and (counter_mac <= 13014)) else
                                        x"A1241DB7" when ((counter_mac > 13014) and (counter_mac <= 13015)) else
                                        x"00000000";

    avalon_st_tx_empty          <=      "00";

    avalon_st_tx_error          <=      '0';
    
-- The following packet is a UPD + IPbus read request
--
--    -- RX signal
--    avalon_st_rx_ready          <=    '1' when (counter_mac > 10000) else
--                                      '0';
--    -- TX signals
--    avalon_st_tx_valid          <=    '1' when ((counter_mac > 13000) and (counter_mac <= 13014)) else
--                                      '0';
--
--    avalon_st_tx_startofpacket  <=    '1' when ((counter_mac > 13000) and (counter_mac <= 13001)) else
--                                      '1' when ((counter_mac > 13014) and (counter_mac < 13999)) else
--                                      '0';
--
--    avalon_st_tx_endofpacket    <=    '1' when ((counter_mac >= 13014) and (counter_mac < 13015)) else
--                                      '0';
--
--    avalon_st_tx_data           <=      x"020DDBA1" when ((counter_mac > 13000) and (counter_mac <= 13001)) else
--                                        x"15100800" when ((counter_mac > 13001) and (counter_mac <= 13002)) else
--                                        x"2086354B" when ((counter_mac > 13002) and (counter_mac <= 13003)) else
--                                        x"08004500" when ((counter_mac > 13003) and (counter_mac <= 13004)) else
--                                        x"0028AB49" when ((counter_mac > 13004) and (counter_mac <= 13005)) else
--                                        x"4000FF11" when ((counter_mac > 13005) and (counter_mac <= 13006)) else
--                                        x"F700C0A8" when ((counter_mac > 13006) and (counter_mac <= 13007)) else
--                                        x"C800C0A8" when ((counter_mac > 13007) and (counter_mac <= 13008)) else
--                                        x"C81099D0" when ((counter_mac > 13008) and (counter_mac <= 13009)) else
--                                        x"C3510014" when ((counter_mac > 13009) and (counter_mac <= 13010)) else
--                                        x"72282000" when ((counter_mac > 13010) and (counter_mac <= 13011)) else
--                                        x"00F02000" when ((counter_mac > 13011) and (counter_mac <= 13012)) else
--                                        x"050F0000" when ((counter_mac > 13012) and (counter_mac <= 13013)) else
--                                        x"00020000" when ((counter_mac > 13013) and (counter_mac <= 13014)) else
--                                        x"00000000";
--
--    avalon_st_tx_empty          <=    "00";
--
--    avalon_st_tx_error          <=    '0';
   

end behav;
