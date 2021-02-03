---------------------------------------------------------------------------------
--! Design     : x2a_SRL16.vhd
--! Author     : Alessandra Camplani
--! Email      : alessandra.camplani@cern.ch
--! Created    : 13.11.2019
--! Comments   : x2a_SRL16 block
-- Conversion done from Xilinx component SRL16 to Intel Altera Megafunctions
-- Done following picture 16, at page 38/33 of this document
-- http://xilinx.eetrend.com/files-eetrend-xilinx/forum/201703/11147-29109-altera_design_flow_for_xilinx_users.pdf
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY work;
LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY x2a_SRL16 IS
    port (
        A   : IN STD_LOGIC_VECTOR(3 downto 0);
        CLK : IN STD_LOGIC;
        D   : IN STD_LOGIC;
        Q   : OUT STD_LOGIC
    );
END x2a_SRL16;

ARCHITECTURE arch OF x2a_SRL16 IS

    component lpm_shiftreg
        generic(
            LPM_WIDTH : integer
        );
        PORT (
            clock   : IN STD_LOGIC;
            shiftin : IN STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component mux161
        PORT (
            x : in std_logic_vector(15 downto 0);
            s : in std_logic_vector(3 downto 0);
            y : out std_logic
        );
    end component;

signal shift_out : STD_LOGIC_VECTOR(15 downto 0);

BEGIN

    i1 : lpm_shiftreg
        generic map(
            LPM_WIDTH => 16
        )
        PORT MAP(
            clock   => CLK,
            shiftin => D,
            q       => shift_out
        );

    i2 : mux161
    PORT MAP(
        x   => shift_out,
        s   => A,
        y   => Q
    );
END arch;