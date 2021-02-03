------------------------------  <-  80 chars  ->  ------------------------------
--! Design     : monitoring.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 13.11.2019
--! Comments   : monitoring block top level
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.prm_format.all;
use work.eth_package.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity monitoring is
    generic(
        RST_CYCLES              : unsigned  := x"FFFF" -- 65535 clk cycles
    );
    port(
        -- 100 MHz clock (possibly to derive the other logic clocks)
        ref_clk_100             : in    std_logic; -- AU_16/17 (IObank 3B)
        
        -- 125 MHz clock for PHY module
        rx_cdr_refclk           : in    std_logic;

        reset_n                 : in    std_logic;

        zsqfp_rx_p              : in    std_logic;
        zsqfp_tx_p              : out   std_logic;

        zqsfp0_1v8_modsel_l     : out   std_logic;
        zqsfp0_1v8_reset_l      : out   std_logic;
        zqsfp0_1v8_modprs_l     : in    std_logic;
        
        zqsfp0_1v8_lpmode       : out   std_logic;
        zqsfp0_1v8_int_l        : in    std_logic;
        
        zqsfp1_1v8_modsel_l     : out   std_logic;
        zqsfp1_1v8_reset_l      : out   std_logic;
        zqsfp1_1v8_modprs_l     : in    std_logic;
        
        zqsfp1_1v8_lpmode       : out   std_logic;
        zqsfp1_1v8_int_l        : in    std_logic;
        
        zqsfp_s10_i2c_sda       : inout std_logic;
        zqsfp_s10_i2c_scl       : out   std_logic;

        s10_led                 : out   std_logic_vector(3 downto 0)
        
    );
end monitoring;

architecture behav of monitoring is

    signal clk_mac              : std_logic                                 := '0';
    signal clk_ipb              : std_logic                                 := '0';

    signal rst_auto_n           : std_logic                                 := '1';
    signal comb_reset_n         : std_logic                                 := '1';
    signal resetdone            : std_logic                                 := '0';
    signal rst_mac              : std_logic                                 := '0';
    
    signal channel_ready_n      : std_logic                                 := '1';
    signal PLL_locked           : std_logic                                 := '0';
    
    signal counter              : unsigned(15 downto 0)                     := (others => '0');

    -- RX AXI 
    signal mac_rx_data                  : std_logic_vector(7 downto 0)      := (others => '0');
    signal mac_rx_valid                 : std_logic                         := '0';
    signal mac_rx_last                  : std_logic                         := '0';
    signal mac_rx_error                 : std_logic                         := '0';
    
    -- TX axi
    signal mac_tx_ready                 : std_logic                         := '0';
    signal mac_tx_data                  : std_logic_vector(7 downto 0)      := (others => '0');
    signal mac_tx_valid                 : std_logic                         := '0';
    signal mac_tx_last                  : std_logic                         := '0';
    signal mac_tx_error                 : std_logic                         := '0';

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  Signals used in Compilation mode
    --  MAC TX User Frame
    signal avalon_st_tx_startofpacket       : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_tx_endofpacket         : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_tx_valid               : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_tx_error               : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_tx_ready               : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_tx_data                : array_32bit            := (others => (others => '0'));
    signal avalon_st_tx_empty               : array_2bit             := (others => (others => '0'));
   
    --  MAC RX User Frame
    signal avalon_st_rx_startofpacket       : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_rx_endofpacket         : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_rx_data                : array_32bit            := (others => (others => '0'));
    signal avalon_st_rx_valid               : std_logic_vector(0 downto 0)      := (others => '0');
    signal avalon_st_rx_empty               : array_2bit             := (others => (others => '0'));
    signal avalon_st_rx_error               : array_6bit             := (others => (others => '0'));
    signal avalon_st_rx_ready               : std_logic_vector(0 downto 0)      := (others => '0');

    -- to avoid signal stuck warning
    attribute keep: boolean;


    signal zqsfp0_1v8_modsel_l_i            : std_logic;
    attribute keep of zqsfp0_1v8_modsel_l_i : signal is true;
    
    signal zqsfp0_1v8_lpmode_i              : std_logic;
    attribute keep of zqsfp0_1v8_lpmode_i   : signal is true;
    
    signal zqsfp1_1v8_modsel_l_i            : std_logic;
    attribute keep of zqsfp1_1v8_modsel_l_i : signal is true;
    
    signal zqsfp1_1v8_lpmode_i              : std_logic;
    attribute keep of zqsfp1_1v8_lpmode_i   : signal is true;

begin

 ----------------------------------------------------------
 ---------- QSFP settings ---------------------------------
 ----------------------------------------------------------
 
-- QSFP 0 (that corresponds to ...)
    zqsfp0_1v8_modsel_l_i   <= '1';
    zqsfp0_1v8_modsel_l     <= zqsfp0_1v8_modsel_l_i;
    zqsfp0_1v8_reset_l      <= reset_n;
    
    zqsfp0_1v8_lpmode_i     <= '0';
    zqsfp0_1v8_lpmode       <= zqsfp0_1v8_lpmode_i;
    
-- QSFP 1 (that corresponds to ...)
    zqsfp1_1v8_modsel_l_i   <= '1';
    zqsfp1_1v8_modsel_l     <= zqsfp1_1v8_modsel_l_i;
    zqsfp1_1v8_reset_l      <= reset_n;
    
    zqsfp1_1v8_lpmode_i      <= '0';
    zqsfp1_1v8_lpmode       <= zqsfp1_1v8_lpmode_i;

-- SQFP I2C
    zqsfp_s10_i2c_sda    <= 'Z';
    zqsfp_s10_i2c_scl    <= 'Z';

 ----------------------------------------------------------
 ---------- heartbit and LEDs -----------------------------
 ----------------------------------------------------------

    s10_led <= channel_ready_n & PLL_locked & zqsfp1_1v8_modsel_l_i & zqsfp0_1v8_modsel_l_i;

 ----------------------------------------------------------
 ---------- Eth Module ------------------------------------
 ----------------------------------------------------------
    eth_inst : entity work.altera_eth_top
    generic map(
        NUM_OF_CHANNEL      => 1,
        DEVICE_FAMILY       => "Stratix 10"
    )
    port map(
        
        -- Clock in
        refclk                      => rx_cdr_refclk,
        clk_100                     => ref_clk_100,
    
        -- Clock out
        mac_clk                     => clk_mac,
        ipbus_clk                   => clk_ipb,
        
        -- Reset
        reset_n                     => reset_n,
        
        -- Serial Interface
        rx_serial_data              => zsqfp_rx_p,
        tx_serial_data              => zsqfp_tx_p,
        
        -- MAX tx user frame (Avalon ST)
        avalon_st_tx_startofpacket  => avalon_st_tx_startofpacket,
        avalon_st_tx_endofpacket    => avalon_st_tx_endofpacket,
        avalon_st_tx_valid          => avalon_st_tx_valid,
        avalon_st_tx_data           => avalon_st_tx_data,
        avalon_st_tx_ready          => avalon_st_tx_ready,
        avalon_st_tx_error          => avalon_st_tx_error,
        avalon_st_tx_empty          => avalon_st_tx_empty,
        
        --  MAC RX User Frame (Avalon ST)
        avalon_st_rx_startofpacket  => avalon_st_rx_startofpacket,
        avalon_st_rx_endofpacket    => avalon_st_rx_endofpacket,
        avalon_st_rx_valid          => avalon_st_rx_valid,
        avalon_st_rx_data           => avalon_st_rx_data,
        avalon_st_rx_ready          => avalon_st_rx_ready,
        avalon_st_rx_error          => avalon_st_rx_error,
        avalon_st_rx_empty          => avalon_st_rx_empty,
        
        -- LED
        channel_ready_n             => channel_ready_n,
        
        -- PLL locked
        core_pll_locked             => PLL_locked
    );

 ----------------------------------------------------------
 ---------- Avalon/AXI  conversion ------------------------
 ----------------------------------------------------------
    converter: entity work.ipbus_axi_ast
    port map(
        clk_mac               => clk_mac,
        rst_mac               => rst_mac,

        -- RX AXI
        rx_axi_data           => mac_rx_data,
        rx_axi_valid          => mac_rx_valid,
        rx_axi_last           => mac_rx_last,
        rx_axi_error          => mac_rx_error,

        -- TX axi
        tx_axi_data           => mac_tx_data,
        tx_axi_valid          => mac_tx_valid,
        tx_axi_last           => mac_tx_last,
        tx_axi_error          => mac_tx_error,
        tx_axi_ready          => mac_tx_ready,

        -- RX Avalon ST
        rx_avst_startofpacket => avalon_st_rx_startofpacket(0),
        rx_avst_endofpacket   => avalon_st_rx_endofpacket(0),
        rx_avst_valid         => avalon_st_rx_valid(0),
        rx_avst_data          => avalon_st_rx_data(0),
        rx_avst_ready         => avalon_st_rx_ready(0),
        rx_avst_error         => avalon_st_rx_error(0),
        rx_avst_empty         => avalon_st_rx_empty(0),

        --TX Avalon ST
        tx_avst_startofpacket => avalon_st_tx_startofpacket(0),
        tx_avst_endofpacket   => avalon_st_tx_endofpacket(0),
        tx_avst_valid         => avalon_st_tx_valid(0),
        tx_avst_data          => avalon_st_tx_data(0),
        tx_avst_ready         => avalon_st_tx_ready(0),
        tx_avst_error         => avalon_st_tx_error(0),
        tx_avst_empty         => avalon_st_tx_empty(0)
    );

 ----------------------------------------------------------
 ---------- IPbus block -----------------------------------
 ----------------------------------------------------------
    ipbus: entity work.ipbus_top -- This is the IPbus infrastrucure.
        generic map(
            mac_address   => x"020ddba11510",
            ip_address    => x"c0a8c810"    --192.168.200.16
        )
        port map(
            sysclk        => ref_clk_100,   -- Osc clock 100 MHz
            clk_mac       => clk_mac,       -- Ethernet MAC clock (156.25 MHz)
            clk_ipb       => clk_ipb,       -- IPbus clock (156.25/4 MHz)
        
            rst_macIP     => rst_mac,       -- From the IPpossibly..
            rst_n         => reset_n,

            -- Input RX (AXI format)
            mac_rx_data   => mac_rx_data,
            mac_rx_valid  => mac_rx_valid,
            mac_rx_last   => mac_rx_last,
            mac_rx_error  => mac_rx_error,
            
            -- Output TX (AXI format)
            mac_tx_data   => mac_tx_data,
            mac_tx_valid  => mac_tx_valid,
            mac_tx_last   => mac_tx_last,
            mac_tx_error  => mac_tx_error,
            mac_tx_ready  => mac_tx_ready, -- input from MAC
            
            PLL_locked    => PLL_locked
        );

end behav;
