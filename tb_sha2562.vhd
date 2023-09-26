----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.03.2019 19:34:27
-- Design Name: 
-- Module Name: tb_sha2562 - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_sha2562 is
-- CLock signal
	signal clk : std_logic;
	constant clk_period : time := 10 ns;
	signal rst : std_logic := '1';
	
-- Input Signals
signal data_ready : std_logic := '0'; -- sends a signal when to hash input data
signal msg_block_in : std_logic_vector(511 downto 0);

-- Output Signals
signal finished : std_logic := '0';
signal data_out : std_logic_vector(255 downto 0);


end tb_sha2562;

architecture Behavioral of tb_sha2562 is

begin

uut: entity work.sha_256_core
          port map(
          clk => clk,
          rst => rst,
          data_ready => data_ready,
          n_blocks => 1,
          msg_block_in => msg_block_in,
          finished => finished,
          data_out => data_out);
          

	
	
stimulus : process
begin
   msg_block_in <= X"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
   
   
   wait for clk_period;
   rst <= '1';
   data_ready <= '1';
   wait for clk_period;
   data_ready <= '0';
   wait until finished = '1';
   msg_block_in <= X"61626180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
   wait for clk_period;
   data_ready <= '1';
   --rst <= '0';
   rst <= '1';
   wait for clk_period;
   data_ready <= '0';
   rst <= '1';
   wait until finished = '1';
   
end process;

	clock: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clock;
	
end Behavioral;
