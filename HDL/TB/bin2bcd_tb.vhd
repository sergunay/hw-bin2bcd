--! @file       bin2bcd_tb
--! @brief      Testbench for bin2bcd module
--! @details    Load test numbers and checks the output
--! @author     Selman Ergunay
--! @email      selmanerg@gmail.com
--! @date       2021-03-21
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
entity bin2bcd_tb is
end entity bin2bcd_tb;

--------------------------------------------------------------------------------
architecture tb of bin2bcd_tb is

	component bin2bcd
	generic(
		DATA_NBITS : natural := 10);
	port(
		iClk  : in std_logic;
		iRst  : in std_logic;
		iReq  : in std_logic;
		iData : in std_logic_vector(DATA_NBITS-1 downto 0);

		oBusy : out std_logic;
		oBcd0 : out std_logic_vector(3 downto 0);
		oBcd1 : out std_logic_vector(3 downto 0);
		oBcd2 : out std_logic_vector(3 downto 0));
	end component;

	constant C_CLK_PER    : time    := 20 ns;
	constant C_DATA_NBITS : natural := 10;

	-- Simulation control signals
	signal sim_clk       : std_logic := '0';
	signal sim_rst       : std_logic := '0';
	signal sim_stop      : boolean 	 := FALSE;		-- stop simulation?
	signal sim_req       : std_logic := '0';
	signal sim_data      : std_logic_vector(C_DATA_NBITS-1 downto 0) := (others=>'0');

	signal duv_busy      : std_logic := '0';
	signal duv_bcd0      : std_logic_vector(3 downto 0) := (others=>'0');
	signal duv_bcd1      : std_logic_vector(3 downto 0) := (others=>'0');
	signal duv_bcd2      : std_logic_vector(3 downto 0) := (others=>'0');

--------------------------------------------------------------------------------
begin

	DUV: bin2bcd
	generic map(
		DATA_NBITS => C_DATA_NBITS)
	port map(
		iClk  => sim_clk,
		iRst  => sim_rst,
		iReq  => sim_req,
		iData => sim_data,

		oBusy => duv_busy,
		oBcd0 => duv_bcd0,
		oBcd1 => duv_bcd1,
		oBcd2 => duv_bcd2);


	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;


	STIM_PROC: process

		variable tv_num       : positive := 1;

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

		procedure load_check(
			constant data    : natural) is
		begin
			report "Loading test vector #" & integer'image(tv_num)& ": " & integer'image(data);
			sim_data  <=  std_logic_vector(to_unsigned(data, C_DATA_NBITS));

			sim_req  <= '1';
			wait for C_CLK_PER;
			sim_req  <= '0';
			wait for 9*C_CLK_PER;

			assert data mod 10 = unsigned(duv_bcd0)
			report "ERROR: Data=" & integer'image(data) &
                   " Digit0=" & integer'image(to_integer(unsigned(duv_bcd0)))
			severity ERROR;

			assert (data-(100*(data/100))) / 10 = unsigned(duv_bcd1)
			report "ERROR: Data=" & integer'image(data) &
                   " Digit0=" & integer'image(to_integer(unsigned(duv_bcd0)))
			severity ERROR;

			assert data/100 = unsigned(duv_bcd2)
			report "ERROR: Data=" & integer'image(data) &
                   " Digit0=" & integer'image(to_integer(unsigned(duv_bcd0)))
			severity ERROR;

			tv_num    := tv_num + 1;
		end procedure load_check;

	begin

		init;

		load_check(365);
		load_check(999);
		wait for 4*C_CLK_PER;
		load_check(836);
		load_check(2);
		load_check(325);
		sim_stop 	<= True;
		wait;
	end process STIM_PROC;

end architecture tb;
