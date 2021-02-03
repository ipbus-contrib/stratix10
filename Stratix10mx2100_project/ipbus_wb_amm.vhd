library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cactus;
use cactus.ipbus.all;

library ipctrl;
use ipctrl.ipctrl_if.all;
use ipctrl.ipctrl_cst.all;

entity ipb_to_avalon_mm is
  port(
    -- clock and reset
    clk_100           : in    std_logic;
    rst_100           : in    std_logic;
    -- to internal packet logic (ipbus_ctrl)
    ipb_to_follower   : in    ipb_wbus;
    ipb_from_follower : out   ipb_rbus;
    -- follower-side
    ipctrl_reg_mm     : inout ipctrl_reg_mm_t
  );
end ipb_to_avalon_mm;

architecture rtl of ipb_to_avalon_mm is

  type state_t is (
    STATE_IDLE,
    STATE_READ,
    STATE_READ_WAIT_ACK,
    STATE_READ_CHECK_MORE_CYCLES,
    STATE_WRITE_WAIT_NOT_BUSY,
    STATE_WRITE,
    STATE_WRITE_ACK,
    STATE_WRITE_CHECK_MORE_CYCLES
  );
  signal state_s : state_t;

  constant MSB_NULL_VEC : unsigned(IPBUS_MSB_SEL_WIDTH - 1 downto 0) := (others => '0');

  signal write_ack_s : std_logic;

begin
  state_machine : process (clk_100)
  begin
    if rising_edge(clk_100) then
      if rst_100 = '1' then
        state_s                   <= STATE_IDLE;
        ipctrl_reg_mm.read_o      <= '0';
        ipctrl_reg_mm.write_o     <= '0';
        ipctrl_reg_mm.address_o   <= (others => '0');
        ipctrl_reg_mm.writedata_o <= (others => '0');
        write_ack_s               <= '0';
      else
        case state_s is

          when STATE_IDLE =>
            write_ack_s <= '0';
            -- Wait for incoming strobe signal
            if ipb_to_follower.ipb_strobe = '1' then
              -- Raise read or write signal
              if ipb_to_follower.ipb_write = '1' then
                ipctrl_reg_mm.writedata_o <= ipb_to_follower.ipb_wdata;
                if ipctrl_reg_mm.waitrequest_i = '1' then
                  state_s <= STATE_WRITE_WAIT_NOT_BUSY;
                else
                  ipctrl_reg_mm.write_o <= '1'
                                        -- pragma translate_off
                                           after 1 ns
                                        -- pragma translate_on
;
                  state_s <= STATE_WRITE;
                end if;
              else
                ipctrl_reg_mm.read_o <= '1'
-- pragma translate_off
                                        after 1 ns
-- pragma translate_on
;
                state_s <= STATE_READ;
              end if;
              -- Set address
              ipctrl_reg_mm.address_o <= MSB_NULL_VEC & unsigned(ipb_to_follower.ipb_addr(32 - IPBUS_MSB_SEL_WIDTH - 1 downto 0));
            else
              ipctrl_reg_mm.address_o <= (others => '0');
            end if;

          when STATE_READ =>
            -- check for timeout/end of cycle
            if ipb_to_follower.ipb_strobe = '0' then
              ipctrl_reg_mm.read_o <= '0'
-- pragma translate_off
                                      after 1 ns
-- pragma translate_on
;
              state_s <= STATE_IDLE;
            else
              -- As long as waitrequest is '1', keep read signal, otherwise wait for an acknowledge unless already there
              if ipctrl_reg_mm.waitrequest_i = '0' then
                ipctrl_reg_mm.read_o <= '0'
-- pragma translate_off
                                        after 1 ns
-- pragma translate_on
;
                state_s <= STATE_READ_WAIT_ACK;
              end if;
            end if;

          when STATE_READ_WAIT_ACK =>
            -- check for timeout/end of cycle
            if ipb_to_follower.ipb_strobe = '0' then
              state_s <= STATE_IDLE;
            else
              -- Wait for acknowledge
              if ipctrl_reg_mm.readdatavalid_i = '1' then
                state_s <= STATE_READ_CHECK_MORE_CYCLES;
              end if;
            end if;

          when STATE_READ_CHECK_MORE_CYCLES =>
            if ipb_to_follower.ipb_strobe = '1' then
              ipctrl_reg_mm.read_o <= '1'
-- pragma translate_off
                                      after 1 ns
-- pragma translate_on
;
              state_s                 <= STATE_READ;
              -- Set address
              ipctrl_reg_mm.address_o <= MSB_NULL_VEC & unsigned(ipb_to_follower.ipb_addr(32 - IPBUS_MSB_SEL_WIDTH - 1 downto 0));
            else
              state_s <= STATE_IDLE;
            end if;

          when STATE_WRITE_WAIT_NOT_BUSY =>
            if ipctrl_reg_mm.waitrequest_i = '0' then
              ipctrl_reg_mm.write_o <= '1'
-- pragma translate_off
                                       after 1 ns
-- pragma translate_on
;
              state_s <= STATE_WRITE;
            end if;

          when STATE_WRITE =>
            -- check for timeout/end of cycle
            if ipb_to_follower.ipb_strobe = '0' then
              ipctrl_reg_mm.write_o <= '0'
-- pragma translate_off
                                       after 1 ns
-- pragma translate_on
;
              write_ack_s <= '0';
              state_s     <= STATE_IDLE;
            else
              -- As long as waitrequest is '1', keep write signal
              if ipctrl_reg_mm.waitrequest_i = '0' then
                ipctrl_reg_mm.write_o <= '0'
-- pragma translate_off
                                         after 1 ns
-- pragma translate_on
;
                write_ack_s <= '1';
                state_s     <= STATE_WRITE_ACK;
              end if;
            end if;

          when STATE_WRITE_ACK =>
            write_ack_s <= '0';
            state_s     <= STATE_WRITE_CHECK_MORE_CYCLES;

          when STATE_WRITE_CHECK_MORE_CYCLES =>
            -- check for timeout/end of cycle
            if ipb_to_follower.ipb_strobe = '0' then
              ipctrl_reg_mm.write_o <= '0'
-- pragma translate_off
                                       after 1 ns
-- pragma translate_on
;
              write_ack_s <= '0';
              state_s     <= STATE_IDLE;
            else
              write_ack_s <= '0';
              if ipb_to_follower.ipb_strobe = '1' then
                ipctrl_reg_mm.writedata_o <= ipb_to_follower.ipb_wdata;
                ipctrl_reg_mm.address_o   <= MSB_NULL_VEC & unsigned(ipb_to_follower.ipb_addr(32 - IPBUS_MSB_SEL_WIDTH - 1 downto 0));
                if ipctrl_reg_mm.waitrequest_i = '0' then
                  ipctrl_reg_mm.write_o <= '1'
-- pragma translate_off
                                           after 1 ns
-- pragma translate_on
;
                  state_s <= STATE_WRITE;
                else
                  state_s <= STATE_WRITE_WAIT_NOT_BUSY;
                end if;
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;

#if IS_SIMULATION
  ipctrl_reg_mm.readdatavalid_i <= 'Z';
  ipctrl_reg_mm.waitrequest_i   <= 'Z';
  ipctrl_reg_mm.readdata_i      <= (others => 'Z');
#endif /* #if IS_SIMULATION */
  ipb_from_follower.ipb_rdata <= ipctrl_reg_mm.readdata_i;
  ipb_from_follower.ipb_ack   <= (ipctrl_reg_mm.readdatavalid_i or write_ack_s)
-- pragma translate_off
                               after 1 ns
-- pragma translate_on
;
  ipb_from_follower.ipb_err <= '0';
  ipctrl_reg_mm.clk_o       <= clk_100;
  ipctrl_reg_mm.rst_o       <= rst_100;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cactus;
use cactus.ipbus.all;

library lli;
use lli.lli_if.all;

library ipctrl;
use ipctrl.ipctrl_if.all;

entity ipbus_wb_amm is
  generic (
    N_FOLLOWER : natural
  );
  port (
    -- clock and reset
    clk_100             : in    std_logic;
    rst_100             : in    std_logic;
    -- to internal packet logic (ipbus_ctrl)
    ipb_in              : in    ipb_wbus;
    ipb_out             : out   ipb_rbus;
    -- follower-side
    ipctrl_reg_mm_array : inout ipctrl_reg_mm_array_t(N_FOLLOWER - 1 downto 0)
  );
end ipbus_wb_amm;


architecture rtl of ipbus_wb_amm is

  signal ipb_to_follower   : ipb_wbus_array(N_FOLLOWER - 1 downto 0);  -- in
  signal ipb_from_follower : ipb_rbus_array(N_FOLLOWER - 1 downto 0);  -- out

  component ipb_to_avalon_mm is
    port(
      -- clock and reset
      clk_100           : in    std_logic;
      rst_100           : in    std_logic;
      -- to internal packet logic (ipbus_ctrl)
      ipb_to_follower   : in    ipb_wbus;
      ipb_from_follower : out   ipb_rbus;
      -- follower-side
      ipctrl_reg_mm     : inout ipctrl_reg_mm_t
    );
  end component ipb_to_avalon_mm;

begin

  fabric : entity cactus.ipbus_fabric
    generic map (
      NSLV => N_FOLLOWER
    )
    port map (
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      ipb_to_slaves   => ipb_to_follower,
      ipb_from_slaves => ipb_from_follower
    );

  con_gen : for i in (N_FOLLOWER - 1) downto 0 generate
  begin

    if_ipb_to_avalon_mm : ipb_to_avalon_mm
      port map(
        clk_100           => clk_100,
        rst_100           => rst_100,
        ipb_to_follower   => ipb_to_follower(i),
        ipb_from_follower => ipb_from_follower(i),
        ipctrl_reg_mm     => ipctrl_reg_mm_array(i)
      );

  end generate;

end rtl;
