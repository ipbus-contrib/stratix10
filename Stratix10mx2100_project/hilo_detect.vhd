-------------------------------------------------------------------------------
-- Design     : hilo_detect.vhd
-- Author     : Steffen Staerz
-- Maintainer : Alessandra Camplani
-- Email      : alessandra.camplani@cern.ch
-- Comments   : Detects a signal change from high to low in consecutive clk cycles
-------------------------------------------------------------------------------
-- Details    :
-- Provides a simplistic logic for detecting a signal change in
-- consecutive clock cycles, depending on generic 'lohi':
-- Output '1' when 'sig_in' changes from '1' to '0' if lohi = false (default);
-- output '1' when 'sig_in' changes from '0' to '1' if lohi = true
-------------------------------------------------------------------------------
--
-- instantiation template:
--
--  [inst_name]: entity work.hilo_detect
--  generic map (
--      lohi    => [boolean := false]   -- switch sense to low -> high
--  )
--  port map (
--      clk     => [in  std_logic],     -- clock
--      sig_in  => [in  std_logic],     -- input signal
--      sig_out => [out std_logic]      -- output signal
--  );
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity hilo_detect is
generic (
    lohi    : boolean := false
);
port (
    clk     : in  std_logic;
    sig_in  : in  std_logic;
    sig_out : out std_logic
);
end hilo_detect;

architecture behavioral of hilo_detect is
signal reg : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            reg <= sig_in;
        end if;
    end process;

    inverted: if lohi generate
    begin
        sig_out <= not reg and sig_in;
    end generate;
    
    not_inverted: if not lohi generate
    begin
        sig_out <= not sig_in and reg;
    end generate;
end behavioral;

