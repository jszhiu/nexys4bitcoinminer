----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.05.2019 07:39:36
-- Design Name: 
-- Module Name: blocksolver - Behavioral
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

entity blocksolver is
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
end blocksolver;

architecture Behavioral of blocksolver is

	-- Declaring the 512 bit SHA-256 module
	COMPONENT blocksha256 
	    PORT ( 
	        clk : IN std_logic;
	        enable : IN std_logic;
	        input : in std_logic_vector(0 to 511) := (others => '0');
	        reset : in std_logic;
	        ready : out std_logic;
	        output : out std_logic_vector(0 to 255);
	        debug1 : out std_logic_vector(0 to 31);
            debug2 : out std_logic_vector(0 to 31);
            debug3 : out std_logic_vector(0 to 31);
            debug4 : out std_logic_vector(0 to 31)
	        );
	END COMPONENT;
	
	-- Declaring the 1024 bit SHA-256 module
    COMPONENT dblblocksha256
        PORT ( clk : in std_logic;
            enable : in std_logic;
            blockheader : in std_logic_vector(0 to 639);
            reset : in std_logic;
            rdy : out std_logic;
            Hash : out std_logic_vector(0 to 255)
            );
    END COMPONENT;
    
    signal ready : std_logic;
   signal enable2 : std_logic := '0';
   signal sglenable : std_logic := '0';
   signal rdy2 : std_logic;
	signal dbloutput : std_logic_vector(0 to 255);
	signal input : std_logic_vector(0 to 511);
begin

-- Instantiates 1024 bit input SHA256
    doublesha: dblblocksha256
        PORT MAP(
             clk => clk,
             enable => enable,
             blockheader => blockheader,
             reset => reset,
             rdy => rdy2,
             Hash => dbloutput
             );
             
             
-- Instantiates 512 bit input SHA256
	onesha: blocksha256
		PORT MAP (
          clk => clk,
          enable => sglenable,
          input => input,
          reset => reset,
          ready => ready,
          output => output,
          debug1 => open,
          debug2 => open,
          debug3 => open,
          debug4 => open
          );
          
          process(clk)
          
          
                   begin 
                   
                  -- if rdy2 = '1' then
                                  input(0 to 255) <= dbloutput;
                                  input(256 to 511) <= x"8000000000000000000000000000000000000000000000000000000000000100";
                   --          end if;
                   if(rising_edge(clk)) then
                   
                   output2 <= dbloutput;

                   finalrdy <= rdy2 and ready;

                   readytest1 <= rdy2;
                   readytest2 <= ready;
                   if(reset = '1') then
                   sglenable <= '0';
                   end if;
                   
                   
                   if rdy2 = '1' then
                   sglenable <= '1';
                   input(0 to 255) <= dbloutput;
                   input(256 to 511) <= x"8000000000000000000000000000000000000000000000000000000000000100";
                   end if;
                   
                   end if;
                  end process;
          
          
end Behavioral;
