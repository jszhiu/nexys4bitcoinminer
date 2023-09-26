-- 3-bit mux2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_3b is
	port( s: in std_logic;
	      a : in std_logic_vector(2 downto 0);
	      b : in std_logic_vector(2 downto 0);
		  q : out std_logic_vector(2 downto 0)
		 );			
end mux2_3b;

architecture arch_when of mux2_3b is
begin
	q <= a when s='0' else 
		  b;
end arch_when;

