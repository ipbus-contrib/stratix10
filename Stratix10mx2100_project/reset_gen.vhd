------------------------------  <-  80 chars  ->  ------------------------------
--! Design     : reset_gen.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 04.11.2020
--! Comments   : reset_gen block, former clocks_7s_extphy
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_gen is
--  generic(
--      CLK_FR_FREQ: real := 100.0;  -- 100MHz reference
--      CLK_VCO_FREQ: real := 1000.0; -- VCO freq 1000MHz
--      CLK_AUX_FREQ: real := 40.0
--  );
    port(
        sysclk          : in  std_logic;
        clk_ipb         : in  std_logic;
        clk_mac         : in  std_logic;
        
        soft_rst        : in  std_logic;
        ext_rst         : in  std_logic;

        PLL_locked      : in  std_logic;
        nuke            : in  std_logic;


        rst_mac         : out std_logic;
        rst_ipb         : out std_logic;
        rst_ipb_ctrl    : out std_logic;

        locked          : out std_logic;
        onehz           : out std_logic
    );

end reset_gen;

architecture rtl of reset_gen is

    signal d17          : std_logic;
    signal d17_d        : std_logic;

    signal nuke_i       : std_logic := '0';
    signal nuke_d       : std_logic := '0';
    signal nuke_d2      : std_logic := '0';
    
    signal combi_rst    : std_logic := '0';
    signal srst         : std_logic := '0';
    signal rst          : std_logic := '0';
    signal rctr         : unsigned(3 downto 0) := "0000";

begin

--  ibufgds0: IBUFGDS port map(
--      i => sysclk_p,
--      ib => sysclk_n,
--      o => sysclk
--  );
--  
--  clko_200 <= sysclk; -- io delay ref clock only, no bufg
--
--  bufg125: BUFG port map(
--      i => clk_mac_i,
--      o => clk_mac_b
--  );
--
--  clko_125 <= clk_mac_b;
--
--  bufg125_90: BUFG port map(
--      i => clk_mac_90_i,
--      o => clko_125_90
--  );
--  
--  bufgipb: BUFG port map(
--      i => clk_ipb_i,
--      o => clk_ipb_b
--  );
--  
--  clko_ipb <= clk_ipb_b;
--  
--  bufgaux: BUFG port map(
--      i => clk_aux_i,
--      o => clk_aux_b
--  );
--  
--  clko_aux <= clk_aux_b;

--  mmcm: MMCME2_BASE
--      generic map(
--          clkin1_period => 1000.0 / CLK_FR_FREQ,
--          clkfbout_mult_f => CLK_VCO_FREQ / CLK_FR_FREQ,
--          clkout1_divide => integer(CLK_VCO_FREQ / 125.00),
--          clkout2_divide => integer(CLK_VCO_FREQ / 125.00),
--          clkout2_phase => 90.0,
--          clkout3_divide => integer(CLK_VCO_FREQ / 31.25),
--          clkout4_divide => integer(CLK_VCO_FREQ / CLK_AUX_FREQ)
--      )
--      port map(
--          clkin1 => sysclk,
--          clkfbin => clkfb,
--          clkfbout => clkfb,
--          clkout1 => clk_mac_i,
--          clkout2 => clk_mac_90_i,
--          clkout3 => clk_ipb_i,
--          clkout4 => clk_aux_i,
--          locked => PLL_locked,
--          rst => '0',
--          pwrdwn => '0'
--      );
    
    clkdiv: entity work.ipbus_clock_div
        port map(
            clk => sysclk,
            d17 => d17,
            d28 => onehz
        );
    
    process(sysclk)
    begin
        if rising_edge(sysclk) then
            d17_d <= d17;
            if d17='1' and d17_d='0' then
                rst <= nuke_d2 or not PLL_locked;
                nuke_d <= nuke_i; -- Time bomb (allows return packet to be sent)
                nuke_d2 <= nuke_d;
            end if;
        end if;
    end process;
        
    locked <= PLL_locked;
    srst <= '1' when rctr /= "0000" else '0';


    process(clk_ipb)
    begin
        if rising_edge(clk_ipb) then
            rst_ipb <= rst or srst;
            nuke_i <= nuke;
            if srst = '1' or soft_rst = '1' then
                rctr <= rctr + 1;
            end if;
        end if;
    end process;
--    rsto_ipb <= rst_ipb;

  combi_rst <= rst or ext_rst; 

--    process(clk_ipb_b)
--    begin
--        if rising_edge(clk_ipb_b) then
--            rst_ipb_ctrl <= rst;
--        end if;
--    end process;
--   rsto_ipb_ctrl <= rst_ipb_ctrl;
    
    ipbus_rst_clk : entity work.alt_mge_reset_synchronizer
        port map(
            clk         => clk_ipb,
            --reset_in    => rst,
            reset_in    => combi_rst,
            reset_out   => rst_ipb_ctrl
        );


--    process(clk_aux_b)
--    begin
--        if rising_edge(clk_aux_b) then
--            rst_aux <= rst;
--        end if;
--    end process;
--   rsto_aux <= rst_aux;

--    process(clk_mac_b)
--    begin
--        if rising_edge(clk_mac_b) then
--            rst_mac <= rst;
--        end if;
--    end process;
--    rsto_125 <= rst_mac;
    mac_rst_clk : entity work.alt_mge_reset_synchronizer
        port map(
            clk         => clk_mac,
            reset_in    => combi_rst,
            reset_out   => rst_mac
        );
    
            
end rtl;
