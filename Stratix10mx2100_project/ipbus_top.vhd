------------------------------  <-  80 chars  ->  ------------------------------
--! Design     : ipbus_top.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 04.11.2020
--! Comments   : ipbus_top block top level
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.prm_format.all;
use work.eth_package.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_top is
    generic(
        mac_address         : std_logic_vector(47 downto 0) := x"020ddba11510";
        ip_address          : std_logic_vector(31 downto 0) := x"c0a8c810"
    );
    port(
        sysclk              : in  std_logic;
        clk_mac             : in  std_logic;
        clk_ipb             : in  std_logic;
        
        rst_macIP           : in  std_logic;
        rst_n               : in  std_logic;
        
        -- MAC rx
        mac_rx_data         : in  std_logic_vector(7 downto 0); -- AXI4 style MAC signals
        mac_rx_valid        : in  std_logic;
        mac_rx_last         : in  std_logic;
        mac_rx_error        : in  std_logic;
        
        -- MAC tx
        mac_tx_data         : out std_logic_vector(7 downto 0);
        mac_tx_valid        : out std_logic;
        mac_tx_last         : out std_logic;
        mac_tx_error        : out std_logic;
        mac_tx_ready        : in  std_logic;
        
        -- PLL info
        PLL_locked          : in std_logic
    );
end ipbus_top;

architecture behav of ipbus_top is

    signal rst_ipb_ctrl     : std_logic := '0';
    signal rst_ipb          : std_logic := '0';
    signal rst_mac          : std_logic := '0';
    signal rst_aux          : std_logic := '0';
    signal soft_rst         : std_logic := '0';
    signal ext_rst          : std_logic := '0';
    
    signal status           : std_logic_vector(31 downto 0) := (others => '0');
    signal locked           : std_logic := '0';
    signal nuke             : std_logic := '0';
    signal userled          : std_logic := '0';
    signal pkt              : std_logic := '0';
    signal onehz            : std_logic := '0';
    
    signal ipb_out          : ipb_wbus;
    signal ipb_in           : ipb_rbus;
     
    
begin

 ----------------------------------------------------------
 ---------- IPbus block -----------------------------------
 ----------------------------------------------------------
    ipbus: entity work.ipbus_ctrl -- This is the IPbus infrastrucure.
        port map(
            mac_clk       => clk_mac, -- Ethernet MAC clock (125MHz)
            ipb_clk       => clk_ipb, -- IPbus clock
        
            rst_macclk    => rst_mac,      -- MAC clock domain sync reset
            rst_ipb       => rst_ipb_ctrl, -- IPbus clock domain sync reset (ctrl is correct)
            
            -- Input RX
            mac_rx_data   => mac_rx_data,
            mac_rx_valid  => mac_rx_valid,
            mac_rx_last   => mac_rx_last,
            mac_rx_error  => mac_rx_error,
            
            -- Output TX
            mac_tx_data   => mac_tx_data,
            mac_tx_valid  => mac_tx_valid,
            mac_tx_last   => mac_tx_last,
            mac_tx_error  => mac_tx_error,
            mac_tx_ready  => mac_tx_ready, -- input
            
            -- To and from the slaves
            ipb_out       => ipb_out,
            ipb_in        => ipb_in,
            
            -- Static MAC and IP addresses
            mac_addr      => mac_address,
            ip_addr       => ip_address,
            
            -- output
            pkt           => pkt
        );

 ----------------------------------------------------------
 ---------- IPbus slave entity ----------------------------
 ----------------------------------------------------------

    -- from the button on the board
    ext_rst <= not (rst_n);


-- For the moment we use ipbus_example instead of paylod 
-- This is good for simple PC testing

    payload: entity work.ipbus_example
        port map(
            ipb_clk   => clk_ipb,
            
            ipb_rst   => rst_ipb,

            -- output reset
            soft_rst  => soft_rst,
        
            -- To and from the IPbus block
            ipb_in    => ipb_out, --input to the slave
            ipb_out   => ipb_in,  -- output of the slave
            
            -- Input from where
            status    => status, -- in the ipbus repo e.g. payload example file, this is not connected
        
            -- output
            nuke      => nuke,
            userled   => userled
        );

 ---------------------------------------------------------
 ---------- Reset entity ----------------------------------
 ------ Former clocks_7s_extphy ---------------------------
 ----------------------------------------------------------

-- NOTE: rethink about the reset of the MAC, as for intel this is slightly different
-- We run on a 156 MHx clock, also let's check where that's actually generate, as we have
-- a dedicated reset entity

-- Also is this entity need at all.. maybe for some specific resets..

    inst_res: entity work.reset_gen
        port map(
            sysclk          => sysclk,
            clk_ipb         => clk_ipb,
            clk_mac         => clk_mac,
            
            soft_rst        => soft_rst,
            ext_rst         => ext_rst,
    
            PLL_locked      => PLL_locked,
            nuke            => nuke,
    
            rst_mac         => rst_mac,
            rst_ipb         => rst_ipb,
            rst_ipb_ctrl    => rst_ipb_ctrl,
    
            locked          => locked,
            onehz           => onehz
        );


end behav;
