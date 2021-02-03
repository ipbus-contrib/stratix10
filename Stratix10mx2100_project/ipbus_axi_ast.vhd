-- author: Rainer Hentges, TU Dresden, rainer.hentges@CERN.ch

-- to do:
--   check what the error bits in ff_rx_error mean. Should each bit throw an error?
--   check the ff_rx_ready signal. Are we always ready to receive data?
--     Should we use the tx fifo full signal (misc_ff_tx_a_full) to pull the ff_rx_ready signal down?
--     e.g. ff_rx_ready <= not misc_ff_tx_a_full;
--     How shall we treat lli_ipctrl_gbe_link_c.tx_avst.ready_o?

-- Updated by : Alessandra Camplani - alessandra.camplani@cern.ch

library ieee;
use ieee.std_logic_1164.all;

entity ipbus_axi_ast is
  port(
    clk_mac                     : in  std_logic;
    rst_mac                     : in  std_logic;

    -- RX AXI 
    rx_axi_data                 : out std_logic_vector(7 downto 0)    := (others => '0');
    rx_axi_valid                : out std_logic                       := '0';
    rx_axi_last                 : out std_logic                       := '0';
    rx_axi_error                : out std_logic                       := '0';
    
    -- TX axi
    tx_axi_ready                : out std_logic                       := '0';
    tx_axi_data                 : in  std_logic_vector(7 downto 0);
    tx_axi_valid                : in  std_logic;
    tx_axi_last                 : in  std_logic;
    tx_axi_error                : in  std_logic;
    
    -- RX Avalon ST
    rx_avst_ready               : out std_logic                       := '0'; -- this should be the ready coming from IPbus
    rx_avst_data                : in  std_logic_vector(31 downto 0);
    rx_avst_valid               : in  std_logic;
    rx_avst_startofpacket       : in  std_logic;
    rx_avst_endofpacket         : in  std_logic;
    rx_avst_error               : in  std_logic_vector(5 downto 0);
    rx_avst_empty               : in  std_logic_vector(1 downto 0);

    --TX Avalon ST
    tx_avst_ready               : in  std_logic; -- this is the ready coming from the MAC
    tx_avst_data                : out std_logic_vector(31 downto 0)   := (others => '0');
    tx_avst_valid               : out std_logic                       := '0';
    tx_avst_startofpacket       : out std_logic                       := '0';
    tx_avst_endofpacket         : out std_logic                       := '0';
    tx_avst_empty               : out std_logic_vector(1 downto 0)    := (others => '0');
    tx_avst_error               : out std_logic                       := '0'
  );
end ipbus_axi_ast;

architecture rtl of ipbus_axi_ast is

    signal rx_axi_sop                  : std_logic                      := '0';
    signal rx_axi_ready                : std_logic                      := '0';
    signal tx_axi_sop                  : std_logic                      := '0';
    signal tx_avst_ready_d             : std_logic                      := '0';
    signal tx_avst_ready_i             : std_logic                      := '0';
    
    -- RX info 8 bit
    signal ready_8_from_IPBUS          : std_logic                      := '0';
    signal rx_avst_8_data              : std_logic_vector(7 downto 0)   := (others => '0');
    signal rx_avst_8_valid             : std_logic                      := '0';
    signal rx_avst_8_startofpacket     : std_logic                      := '0';
    signal rx_avst_8_endofpacket       : std_logic                      := '0';
    signal rx_avst_8_error             : std_logic_vector(5 downto 0)   := (others => '0');
    signal rx_avst_8_empty             : std_logic_vector(1 downto 0)   := (others => '0');

begin

------------------------------------------------------------------
-------------------- RX conversion -------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
    -- From the MAC 32 bit to 8 bit
------------------------------------------------------------------
    conversion_to8: entity work.valid_32to8
    port map(
        clk                         => clk_mac,
        rst                         => rst_mac,
    
        -- Coming from MAC, 32 bit info
        ready_from_IPBUS            => rx_avst_ready,
        
        rx_avst_data                => rx_avst_data,
        rx_avst_valid               => rx_avst_valid,
        rx_avst_startofpacket       => rx_avst_startofpacket,
        rx_avst_endofpacket         => rx_avst_endofpacket,
        rx_avst_error               => rx_avst_error,
        rx_avst_empty               => rx_avst_empty,
    
        -- converting to 8 bit data
        rx_avst_8_data              => rx_avst_8_data,
        rx_avst_8_valid             => rx_avst_8_valid,
        rx_avst_8_startofpacket     => rx_avst_8_startofpacket,
        rx_avst_8_endofpacket       => rx_avst_8_endofpacket,
        rx_avst_8_error             => rx_avst_8_error,
        rx_avst_8_empty             => rx_avst_8_empty
    
    );

------------------------------------------------------------------
    -- From the MAC core (avalon) to the IPbus (AXI)
------------------------------------------------------------------
    rx_axi_data  <= rx_avst_8_data;
    rx_axi_valid <= rx_avst_8_valid;
    rx_axi_last  <= rx_avst_8_endofpacket;
    rx_axi_error <= rx_avst_8_error(5) or -- not very well connected..
                    rx_avst_8_error(4) or --
                    rx_avst_8_error(3) or --
                    rx_avst_8_error(2) or --
                    rx_avst_8_error(1) or --
                    rx_avst_8_error(0);   --
    
    -- RX avst is an output
    rx_avst_ready <= '1';  -- ??

------------------------------------------------------------------
    -- TX conversion
------------------------------------------------------------------
------------------------------------------------------------------
    -- From the IPbus 8 bit to 32 bit
------------------------------------------------------------------
    conversion_to32: entity work.conv_ipb_mac
    port map(
        clk                         => clk_mac,
        rst                         => rst_mac,
        
        -- Data from IPbus AXI
        tx_axi_data                 => tx_axi_data,
        tx_axi_valid                => tx_axi_valid,
        tx_axi_last                 => tx_axi_last,
        tx_axi_error                => tx_axi_error,

        -- READY going to IPbus
        tx_axi_ready                => tx_axi_ready,
        
        -- Ready coming from the MAC
        tx_avst_ready               => tx_avst_ready,

        -- Data to MAC Avalon ST
        tx_avst_data                => tx_avst_data,
        tx_avst_valid               => tx_avst_valid,
        tx_avst_startofpacket       => tx_avst_startofpacket,
        tx_avst_endofpacket         => tx_avst_endofpacket,
        tx_avst_error               => tx_avst_error, -- not very well connected... to be checked..
        tx_avst_empty               => tx_avst_empty
    );

end rtl;
