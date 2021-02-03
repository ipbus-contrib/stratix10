library ieee;
use ieee.std_logic_1164.all;
library work;
use work.prm_format.all;

package eth_package is

    constant NUM_OF_ETH_CHANNEL     : integer := 1;
    constant DEVICE_FAMILY          : string  := "Stratix 10";
    constant NUM_OF_CH_WIDTH        : integer := log2ceil(NUM_OF_ETH_CHANNEL);


    -- array types.. might be easier if I could access the reconfig block IP, but looks not so trivial.
    type array_2bit  is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(1  downto 0);
    type array_5bit  is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(4  downto 0);
    type array_6bit  is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(5  downto 0);
    type array_7bit  is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(6  downto 0);
    type array_10bit is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector (9 downto 0);
    type array_11bit is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(10 downto 0);
    type array_16bit is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(15 downto 0);
    type array_32bit is array (NUM_OF_ETH_CHANNEL-1 downto 0) of std_logic_vector(31 downto 0);
    
end eth_package;
