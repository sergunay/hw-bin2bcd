library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------
entity bcd_digit is
	port(
		iClk       : in std_logic;
		iRst       : in std_logic;
		iEn        : in std_logic;
		iData_bit  : in std_logic;
		oData_bit  : out std_logic;
		oBcd       : out std_logic_vector(3 downto 0));
end entity bcd_digit;

architecture rtl of bcd_digit is

	signal data_reg   : unsigned(2 downto 0) := (others=>'0');
	signal data_next  : unsigned(2 downto 0) := (others=>'0');
	signal digit      : unsigned(3 downto 0) := (others=>'0');
	signal data_shift : std_logic := '0';
	signal carry      : std_logic := '0';
begin
----------------------------------------------------------------------------

	-- Datapath

	-- SRLwPL
	DATA_SHIFT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				data_reg <= (others=>'0');
				carry    <= '0';
			elsif iEn = '1' then
				if data_shift = '1' then
					data_reg <= data_reg(1 downto 0) & iData_bit;
					carry    <= '0';
				else
					data_reg <= data_next;
					carry    <= '1';
				end if;
			end if;
		end if;
	end process DATA_SHIFT_PROC;

	digit <= data_reg & iData_bit;

	-- Control

	data_next <= "000" when digit = 5 else
	             "001" when digit = 6 else
                 "010" when digit = 7 else
                 "011" when digit = 8 else
                 "100" when digit = 9 else
                 "000";

	data_shift <= '1' when digit < 5 else
				  '0';

	oBcd       <= std_logic_vector(digit);
	oData_bit  <= carry;

----------------------------------------------------------------------------
end architecture rtl;
----------------------------------------------------------------------------

