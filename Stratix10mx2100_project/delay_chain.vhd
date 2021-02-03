-------------------------------------------------------------------------------
-- Design     : delay_chain.vhd
-- Author     : Steffen Staerz
-- Maintainer : Alessandra Camplani
-- Email      : alessandra.camplani@cern.ch
-- Comments   : Delays a signal in the 'clk' clock domain (it's a shift register!)
-------------------------------------------------------------------------------
-- Details    :
-- The delay is determined by several generics:
-- d_width (>= 1) determines the width of the signal to be delayed
-- d_depth (>= 1) determines the depth of the delay chain (shift register)
-- on_reset gives the default value on reset ('0' by default)
--
-- delay_chain can also be used to synchronise in a single bit signal
-- Don't use it for synchronising std_logic_vectors over clock domains!
-- For this purpose use DC FIFOs instead!
-------------------------------------------------------------------------------
--
-- Instantiation template (for delaying a std_logic):
--
--  [inst_name]: entity work.DELAY_CHAIN
--  generic map (
--      D_DEPTH     => [positive := 3],     -- number of clock cycles it shell be delayed
--      ON_RESET    => [std_logic := '0'],  -- initial and 'on reset'-value
--      RAM_STYLE   => [string := "AUTO"]   -- RAM style used
--  )
--  port map (
--      CLK         => [in  std_logic],     -- clock
--      RST         => [in  std_logic],     -- sync reset
--      SIG_IN(0)   => [in  std_logic],     -- input signal
--      SIG_OUT(0)  => [out std_logic]      -- delayed output signal
--  );
--
-- Instantiation template (for delaying a std_logic_vector):
--
--  [inst_name]: entity work.DELAY_CHAIN
--  generic map (
--      D_WIDTH     => [positive := 1],     -- width of the signal to be delayed
--      D_DEPTH     => [positive := 3],     -- number of clock cycles it shell be delayed
--      ON_RESET    => [std_logic := '0'],  -- initial and 'on reset'-value
--      RAM_STYLE   => [string := "AUTO"]   -- RAM style used
--  )
--  port map (
--      CLK         => [in  std_logic],                             -- clock
--      RST         => [in  std_logic],                             -- sync reset
--      SIG_IN      => [in  std_logic_vector(D_WIDTH-1 downto 0)],  -- input signal
--      SIG_OUT     => [out std_logic_vector(D_WIDTH-1 downto 0)]   -- delayed output signal
--  );
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity DELAY_CHAIN is
    generic (
        D_WIDTH     : positive := 1;    -- width of the signal to be delayed
        D_DEPTH     : positive := 3;    -- number of clock cycles it shell be delayed
        ON_RESET    : std_logic := '0'; -- initial and 'on reset'-value
        RAM_STYLE   : string := "AUTO"  -- RAM style used
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        SIG_IN      : in  std_logic_vector(D_WIDTH-1 downto 0);
        SIG_OUT     : out std_logic_vector(D_WIDTH-1 downto 0)
    );
end DELAY_CHAIN;

architecture Behavioral of DELAY_CHAIN is
    type DELAY_REG_T is array (D_DEPTH-1 downto 0) of std_logic_vector(D_WIDTH-1 downto 0);
    signal DELAY_REG : DELAY_REG_T := (others => (others => ON_RESET));
    attribute RAMSTYLE : string;
    attribute RAMSTYLE of DELAY_REG : signal is RAM_STYLE;
begin
    SIG_OUT <= DELAY_REG(0);

    GEN_D_DEPTH_ONE: if D_DEPTH = 1 generate
        process(CLK)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    DELAY_REG(0) <= (others => ON_RESET);
                else
                    DELAY_REG(0) <= SIG_IN;
                end if;
            end if;
        end process;
    end generate;
    -- else:
    GEN_D_DEPTH_MORE: if D_DEPTH > 1 generate
        process(CLK)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    DELAY_REG <= (others => (others => ON_RESET));
                else
                -- shift right and insert sig_in on the left
                    DELAY_REG(D_DEPTH-1 downto 0) <= SIG_IN & DELAY_REG(D_DEPTH-1 downto 1);
                end if;
            end if;
        end process;
    end generate;
end Behavioral;