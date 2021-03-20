--! @file 			uart_tx_tb.vhd
--! @brief 			Testbench of uart_tx module
--! @details 		This testbench reads the test vector file tv_in.txt
--!                 which lists data and control signals in 8-bit binary
--!                 format.
--! @author 		Selman Ergunay
--! @date 			20.10.2020
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------
entity bcd_digit_tb is
end entity;
----------------------------------------------------------------------------

architecture tb of bcd_digit_tb is
----------------------------------------------------------------------------
	component bcd_digit
		port(
			iClk       : in std_logic;
			iRst       : in std_logic;
			iEn        : in std_logic;
			iData_bit  : in std_logic;
			oData_bit  : out std_logic;
			oBcd       : out std_logic_vector(3 downto 0));
	end component;

	-- Simulation constants
	constant C_CLK_PER   : time    := 83.33 ns;

	-- Simulation control signals
	signal sim_clk       : std_logic := '0';
	signal sim_rst       : std_logic := '0';
	signal sim_stop      : boolean 	:= FALSE;		-- stop simulation?
	signal sim_en        : std_logic := '0';
	signal sim_data      : std_logic := '0';

	signal bcd_data_bit  : std_logic := '0';
	signal bcd_bcd       : std_logic_vector(3 downto 0) := (others=>'0');

begin
----------------------------------------------------------------------------

	DUV: bcd_digit
		port map(
			iClk       => sim_clk,
			iRst       => sim_rst,
			iEn        => sim_en,
			iData_bit  => sim_data,
			oData_bit  => bcd_data_bit,
			oBcd       => bcd_bcd);

	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;

	STIM_PROC: process

		variable data_us : unsigned(3 downto 0);
		variable tv_num  : positive := 1;

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

		procedure load(
			constant data    : natural) is
		begin
			report "Loading test vector #" & integer'image(tv_num)& ": " & integer'image(data);
			data_us  := to_unsigned(data, 4);

			sim_rst  <= '0';
			sim_en   <= '1';
			for bit_idx in 3 downto 0 loop
				sim_data <= data_us(bit_idx);
				wait for C_CLK_PER;
			end loop;
			sim_en   <= '0';

			sim_rst  <= '1';

			wait for C_CLK_PER;
			tv_num   := tv_num + 1;
		end procedure load;


	begin
		init;

		for load_num in 0 to 15 loop
			load(load_num);
		end loop;

		wait for 10*C_CLK_PER;

		sim_stop 	<= True;
		wait;
	end process STIM_PROC;
----------------------------------------------------------------------------
end architecture tb;
----------------------------------------------------------------------------
