-- Distributed dual port RAM with asynchronous read, asynchronous write
-- Port A is read/write, port B is read-only
-- Daniel Roggen, 2016

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY dpram IS
	generic(AN : integer;
	        DN : integer);
   PORT
   (
      clk: IN   std_logic;
      addressA:  IN   STD_LOGIC_VECTOR(AN-1 downto 0);
	  dataA:  IN   STD_LOGIC_VECTOR(DN-1 downto 0);
      weA:    IN   std_logic;
      addressB:  IN   STD_LOGIC_VECTOR(AN-1 downto 0);
      qA:     OUT  STD_LOGIC_VECTOR(DN-1 DOWNTO 0);
      qB:     OUT  STD_LOGIC_VECTOR(DN-1 DOWNTO 0)
   );
END dpram;


ARCHITECTURE rtl OF dpram IS
   TYPE mem IS ARRAY(0 TO 2**AN-1) OF std_logic_vector(DN-1 DOWNTO 0);
   SIGNAL ram_block : mem
                ; 
-- Or put the initial content of the memory here. Note: provide exactly the right size 32 bytes
--                := (	
											

--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00",
--											X"00", X"00"
--										);

BEGIN
   PROCESS(clk)
   BEGIN
      IF rising_edge(clk) THEN
         IF weA = '1' THEN
            ram_block(to_integer(unsigned(addressA))) <= dataA;
         END IF;
      END IF;
   END PROCESS;
   qA <= ram_block(to_integer(unsigned(addressA)));
   qB <= ram_block(to_integer(unsigned(addressB)));

END rtl;

