library ieee;
use ieee.std_logic_1164.all;

package prm_format is

--! layer information
    constant num_pix_layer          : integer := 4;
    constant num_str_layer          : integer := 4;
    
    constant tot_num_layer          : integer := num_pix_layer + num_str_layer;

--! general HTT-PRM values
    constant eventID_length         : integer := 32;
    constant cluster_length         : integer := 32;
    constant SSID_length            : integer := 16;
    constant sectorID_length        : integer := 16;
    constant roadID_length          : integer := 24;
    
    constant tot_num_asics          : integer := 20;
    constant am_groups              : integer := 4;
    constant asics_per_group        : integer := tot_num_asics/am_groups;

--! Error word
    constant errWord_length         : integer := 32;


--! DO related into
    constant clp_add_length         : integer := 12;
    constant ccm_add_length         : integer := 5;

--! HBM related info
    constant requestID_length       : integer := 16;

    type eventID_array_t        is array (tot_num_layer-1 downto 0) of std_logic_vector(eventID_length-1 downto 0);
    type cluster_array_t        is array (tot_num_layer-1 downto 0) of std_logic_vector(cluster_length-1 downto 0);
    type clp_data_array_t       is array (tot_num_layer-1 downto 0) of std_logic_vector(clp_add_length-1 downto 0);
    type ccm_data_array_t       is array (tot_num_layer-1 downto 0) of std_logic_vector(ccm_add_length-1 downto 0);
    type cluster_ssid_array_t   is array (tot_num_layer-1 downto 0) of std_logic_vector(cluster_length+SSID_length-1 downto 0);
    type ssid_t                 is array (tot_num_layer-1 downto 0) of std_logic_vector(SSID_length-1 downto 0);
    type roadlay_array_t        is array (tot_num_layer-1 downto 0) of std_logic_vector((roadID_length+tot_num_layer)-1 downto 0);
    type secID_array_t          is array (tot_num_layer-1 downto 0) of std_logic_vector((sectorID_length)-1 downto 0);

    function log2ceil(arg : positive) return natural;
    function div_ceil(a : natural; b : positive) return natural;
    function roundUp2Power(arg : positive) return positive;
    function maxof2numbers(a : positive; b: positive) return positive;
    function pow2(arg : positive) return natural;
end prm_format;

package body prm_format is
  
--! Logarithms: log*ceil*
--! ==========================================================================
--! return log2; always rounded up
--! From https://github.com/VLSI-EDA/PoC/blob/master/src/common/utils.vhdl
    function log2ceil(arg : positive) return natural is
        variable tmp : positive;
        variable log : natural;
    begin
        if arg = 1 then return 0; end if;
        tmp := 1;
        log := 0;
        while arg > tmp loop
            tmp := tmp * 2;
            log := log + 1;
        end loop;
        return log;
    end function;

--! Divisions: div_*
--! ===========================================================================
--! integer division; always round-up
--! calculates: ceil(a / b)
    function div_ceil(a : natural; b : positive) return natural is
    begin
        return (a + (b - 1)) / b;
    end function;

--! Returns next larger value in power of 2
--! ==========================================================================
--! 
    function roundUp2Power(arg : positive) return positive is
        variable tmp : positive;
    begin
        tmp := 1;
        while arg > tmp loop
            tmp := tmp * 2;
        end loop;
        return tmp;
    end function;

--! Returns maximum of two numbers
--! ==========================================================================
--! 
    function maxof2numbers(a : positive; b: positive) return positive is
    begin
        if (a > b)  then 
            return a; 
        elsif (a < b) then
            return b;
        else    -- a = b
            return a;
        end if;
    end function;       

--! Returns power of 2
--! ==========================================================================
--! 
    function pow2(arg : positive) return natural is
        variable tmp : positive;
        variable log : natural;
    begin
        if arg = 0 then return 1; end if;
        tmp := 1;
        log := 0;
        while arg > log loop
            tmp := tmp * 2;
            log := log + 1;
        end loop;
        return tmp;
    end function;

end package body prm_format;
