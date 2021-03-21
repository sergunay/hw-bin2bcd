--! @file       bin2bcd.vhd
--! @brief      Binary to BCD converter
--! @details    Converts input data with a request signal to BCD digits.
--!             During conversion, Busy signal is HIGH and requests are ignored.
--!             After DATA_NBITS clock cycle, BCD outputs are ready and Busy is LOW.
--! @author     Selman Ergunay
--! @email      selmanerg@gmail.com
--! @date       2021-03-21
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------
entity bin2bcd is
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
end entity bin2bcd;
----------------------------------------------------------------------------
architecture rtl of bin2bcd is

	signal digit_en     : std_logic := '0';
	signal digit_rst    : std_logic := '0';
	signal data_bit0    : std_logic := '0';
	signal data_bit1    : std_logic := '0';
	signal data_bit2    : std_logic := '0';
	signal data_bit3    : std_logic := '0';

	signal bcd_0        : std_logic_vector(3 downto 0) := (others=>'0');
	signal bcd_1        : std_logic_vector(3 downto 0) := (others=>'0');
	signal bcd_2        : std_logic_vector(3 downto 0) := (others=>'0');

	signal data_load    : std_logic := '0';
	signal data_shift   : std_logic := '0';
	signal data_reg     : std_logic_vector(DATA_NBITS-1 downto 0) := (others=>'0');
	signal dbit_cnt_reg : unsigned(3 downto 0) := (others=>'0');
	signal data_vld     : std_logic := '0';
	signal busy         : std_logic := '0';

	component bcd_digit
		port(
			iClk       : in std_logic;
			iRst       : in std_logic;
			iEn        : in std_logic;
			iData_bit  : in std_logic;
			oData_bit  : out std_logic;
			oBcd       : out std_logic_vector(3 downto 0));
	end component;

----------------------------------------------------------------------------
begin

	-- Datapath

	-- SRwPL
	DATA_SHIFT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				data_reg <= (others=>'0');
			elsif data_load = '1' then
				data_reg <= iData;
			elsif data_shift = '1' then
				data_reg <= data_reg(DATA_NBITS-2 downto 0) & '0';
			end if;
		end if;
	end process DATA_SHIFT_PROC;

	data_bit0 <= data_reg(DATA_NBITS-1);

	I_BCD_DIGIT_0: bcd_digit
		port map(
			iClk       => iClk,
			iRst       => digit_rst,
			iEn        => digit_en,
			iData_bit  => data_bit0,
			oData_bit  => data_bit1,
			oBcd       => bcd_0(3 downto 0));

	I_BCD_DIGIT_1: bcd_digit
		port map(
			iClk       => iClk,
			iRst       => digit_rst,
			iEn        => digit_en,
			iData_bit  => data_bit1,
			oData_bit  => data_bit2,
			oBcd       => bcd_1(3 downto 0));

	I_BCD_DIGIT_2: bcd_digit
		port map(
			iClk       => iClk,
			iRst       => digit_rst,
			iEn        => digit_en,
			iData_bit  => data_bit2,
			oData_bit  => data_bit3,
			oBcd       => bcd_2(3 downto 0));

	-- BCD outputs
	oBcd0 <= bcd_0;
	oBcd1 <= bcd_1;
	oBcd2 <= bcd_2;

	digit_rst <= iRst or data_load;

	-- Control

	DBIT_CNTDN_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or data_vld = '1' then
				dbit_cnt_reg <= to_unsigned(DATA_NBITS-2, 4);
			elsif busy = '1' then
				dbit_cnt_reg <= dbit_cnt_reg - 1;
			end if;
		end if;
	end process DBIT_CNTDN_PROC;

	data_vld <= '1' when dbit_cnt_reg = 0 else
			    '0';

	-- FLAG
	REQ_FLAG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or data_vld = '1' then
				busy <= '0';
			elsif iReq = '1' then
				busy <= '1';
			end if;
		end if;
	end process REQ_FLAG_PROC;

	data_load  <= iReq and not busy;

	data_shift <= busy;
	digit_en   <= busy;
	oBusy      <= busy;

end architecture rtl;
