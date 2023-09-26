----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2019 22:12:56
-- Design Name: 
-- Module Name: tb_doublesha - Behavioral
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

entity tb_blocksolver is
--  Port ( );
end tb_blocksolver;

architecture Behavioral of tb_blocksolver is
-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;
	
	-- Ready signal
	signal ready : std_logic := '0';
	
	signal reset : std_logic := '0';
	signal dblreset : std_logic := '0';
	-- Declaring the 512 bit SHA-256 module
	COMPONENT blocksha256 
	    PORT ( 
	        clk : IN std_logic;
	        enable : IN std_logic;
	        input : in std_logic_vector(0 to 511);
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
  
	signal output : std_logic_vector(0 to 255);
	signal dbloutput : std_logic_vector(0 to 255);
	signal input : std_logic_vector(0 to 511); --:= x"2a19f8a396959e87a0607a7eae4abb941135e49b8d342e7bb923a7ca33b09ff78000000000000000000000000000000000000000000000000000000000000100";
    signal blockheader : std_logic_vector(0 to 639):= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1AE3143991";
    signal sglenable : std_logic := '0';
    signal enable : std_logic := '0';
    signal rdy : std_logic;
    
    signal debug1 : std_logic_vector(0 to 31);
    signal debug2 : std_logic_vector(0 to 31);
    signal debug3 : std_logic_vector(0 to 31);
    signal debug4 : std_logic_vector(0 to 31);
    signal readyBuffer : std_logic := '0';

begin


-- Instantiates 1024 bit input SHA256
    doublesha: dblblocksha256
        PORT MAP(
             clk => clk,
             enable => enable,
             blockheader => blockheader,
             reset => dblreset,
             rdy => rdy,
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
          debug1 => debug1,
          debug2 => debug2,
          debug3 => debug3,
          debug4 => debug4
          );

         
         process(clk)
         begin 
         
         if(rising_edge(clk)) then
         
         enable <= '1';
         
         if rdy = '1' then
         readyBuffer <= '1';
         end if;
         
         
         if readyBuffer = '1' then
         sglenable <= '1';
         input(0 to 255) <= dbloutput;
         input(256 to 511) <= x"8000000000000000000000000000000000000000000000000000000000000100";
         
         elsif ready = '1' then
         

         end if;
         
         end if;
        end process;


		 clk <= not clk after clk_period;


end Behavioral;
