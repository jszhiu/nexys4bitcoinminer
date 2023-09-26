----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.03.2019 03:29:24
-- Design Name: 
-- Module Name: tb_sha256test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_sha256test is
constant clk_period : time := 10 ns;
signal clk : bit;
signal rst : bit := '0';
signal init : bit := '1';
signal ld : bit := '1';
signal m : bit_vector(31 downto 0);



signal md : bit_vector(31 downto 0);
signal v : bit;

signal word_address : std_logic_vector(5 downto 0) := "000000";

end tb_sha256test;

architecture Behavioral of tb_sha256test is

begin

uut: entity work.sha256test
          port map(
          m => m,
          init => init,
          ld => ld,
          md => md,
          v => v,
          clk => clk,
          rst => rst);
          
          
     stimulus : process(clk)
begin     


if word_address = b"000000" then
					m <= x"61626380"; -- "abc" and a 1 bit at the end
					word_address <= word_address + "000001";

				elsif word_address = b"001111" then
					m <= x"00000018"; -- message length is 24 bits
					word_address <= word_address + "000001";
					elsif word_address = b"010000" then
					ld <= '0';
					init <= '0';
				else
					m <= (others => '0');
					word_address <= word_address + "000001";
					
				end if;
				
				end process;
          
 	clock: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clock;         

end Behavioral;
