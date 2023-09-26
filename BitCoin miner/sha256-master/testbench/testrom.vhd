-- SHA256 Hashing Module - ROM with test data
-- Kristian Klomsten Skordal <kristian.skordal@wafflemail.net>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testrom is
	port(
		clk : in std_logic;
		
		word_address : in std_logic_vector(5 downto 0);
		word_output : out std_logic_vector(31 downto 0)
	);
end entity testrom;

architecture behaviour of testrom is
	type testdata2_array is array(0 to 31) of std_logic_vector(31 downto 0);
	constant testdata2 : testdata2_array := (
	

		x"01000000", x"9500c43a", x"25c62452", x"0b5100ad", x"f82cb9f9", x"da72fd24", x"47a496bc", x"600b0000",x"00000000", 
		x"6cd86237", x"0395dedf", x"1da2841c", x"cda0fc48", x"9e3039de", x"5f1ccdde", x"f0e83499",x"1a65600e", x"a6c8cb4d",
		x"b3936a1a", x"e3143991", x"10000000", x"00000000", x"00000000", x"00000000",  
		x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"40060000", x"00000000");
begin

	readproc: process(clk)
	begin
		if falling_edge(clk) then -- FIXME
			if word_address(5 downto 4) = b"00" then -- Test set 1, "abc"
				if word_address = b"000000" then
					word_output <= x"61626380"; -- "abc" and a 1 bit at the end
				elsif word_address = b"001111" then
					word_output <= x"00000018"; -- message length is 24 bits
				else
					word_output <= (others => '0');
				end if;
			else -- Test set 2, "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
				if word_address(5) = '1' then
					word_output <= testdata2(16 + to_integer(unsigned(word_address(3 downto 0))));
				else
					word_output <= testdata2(to_integer(unsigned(word_address(3 downto 0))));
				end if;
			end if;
		end if;
	end process readproc;

end architecture behaviour;
