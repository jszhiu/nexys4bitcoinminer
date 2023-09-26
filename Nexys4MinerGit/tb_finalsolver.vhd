----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.05.2019 07:48:39
-- Design Name: 
-- Module Name: tb_finalsolver - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_finalsolver is
--  Port ( );
end tb_finalsolver;

architecture Behavioral of tb_finalsolver is
-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;

signal enable : std_logic := '0';
signal ready : std_logic := '0';
signal reset : std_logic := '0';
signal output : std_logic_vector(0 to 255);
signal output2 : std_logic_vector(0 to 255);
signal rdy2b : std_logic;
signal rdy1 : std_logic;

signal nonceIter : std_logic_vector(31 downto 0) := x"E314398C";

signal checked : std_logic := '0';

COMPONENT blocksolver is
  Port ( 
  clk : in std_logic;
  blockheader : in std_logic_vector(0 to 639);
  enable : in std_logic;
  reset : in std_logic;
  finalrdy : out std_logic;
  readytest1 : out std_logic;
  readytest2 : out std_logic;
  output : out std_logic_vector(0 to 255);
  output2 : out std_logic_vector(0 to 255)
  
  );
end component;
signal blockheader : std_logic_vector(0 to 639);
--signal blockheader : std_logic_vector(0 to 639):= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1AE3143991";
signal blockheaderNo : std_logic_vector(0 to 607):= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1A";
begin

solve : blocksolver PORT MAP(
         clk => clk,
         blockheader => blockheader,
         enable => enable,
         reset => reset,
         finalrdy => ready,
         readytest1 => rdy2b,
         readytest2 => rdy1,
         output => output,
         output2 => output2 
         );



process(clk)
begin
blockheader <= blockheaderNo&nonceIter;
     
     if(rising_edge(clk)) then

          
          if(enable = '0' and ready = '1') then
          checked <= '0';
          reset <= '0';

          elsif(ready /= '1') then
          reset <= '0';
          enable <= '1';
          elsif(ready = '1' and checked = '0') then

          nonceIter <= std_logic_vector(  unsigned(nonceIter) + 1  );
          --blockheader <= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1AE3145555";
          
          enable <= '0';
          reset <= '1';
          checked <= '1';
          end if;
          
          
          
          
          end if;
end process;

clk <= not clk after clk_period;
end Behavioral;
