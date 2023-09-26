----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.04.2019 22:11:24
-- Design Name: 
-- Module Name: 2blocksha256 - Behavioral
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

entity dblblocksha256 is
  Port ( clk : in std_logic;
  enable : in std_logic;
  blockheader : in std_logic_vector(0 to 639);
  reset : in std_logic;
  rdy : out std_logic := '0';
  Hash : out std_logic_vector(0 to 255)
  );
end dblblocksha256;

architecture Behavioral of dblblocksha256 is
-- Defines the function Majority here
function Maj(x,y,z : std_logic_vector) return std_logic_vector is
begin
return ((x and y) xor (x and z) xor (y and z));
end function;

-- Defines the function choose here
function choose(x,y,z : std_logic_vector) return std_logic_vector is
begin
return ((x and y) xor ((not x) and z));
end function;

-- Defines the function uppercase sigma 0 here
-- Have to convert x into unsigned since rotate_right function only accepts unsigned
function usig0(x : std_logic_vector) return std_logic_vector is
begin
--return std_logic_vector(ROTATE_RIGHT(unsigned(x), 2)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 13)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 22));
return std_logic_vector(rotate_right(unsigned(x), 2) xor rotate_right(unsigned(x), 13) xor rotate_right(unsigned(x), 22));
end function;

-- Defines the function uppercase sigma 1 here 
function usig1(x : std_logic_vector) return std_logic_vector is
begin
return std_logic_vector(rotate_right(unsigned(x), 6) xor rotate_right(unsigned(x), 11) xor rotate_right(unsigned(x), 25));
--return std_logic_vector(ROTATE_RIGHT(unsigned(x), 6)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 11)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 25));
end function;

-- Defines the function lowercase sigma 0 here

function lsig0(x : std_logic_vector) return std_logic_vector is
begin
--return std_logic_vector(ROTATE_RIGHT(unsigned(x), 7)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 18)) xor std_logic_vector(SHIFT_RIGHT(unsigned(x), 3));
return std_logic_vector(rotate_right(unsigned(x), 7) xor rotate_right(unsigned(x), 18) xor shift_right(unsigned(x), 3));
end function;


-- Defines the function uppercase sigma 1 here

function lsig1(x : std_logic_vector) return std_logic_vector is
begin
--return std_logic_vector(ROTATE_RIGHT(unsigned(x), 17)) xor std_logic_vector(ROTATE_RIGHT(unsigned(x), 19)) xor std_logic_vector(SHIFT_RIGHT(unsigned(x), 10));
return std_logic_vector(rotate_right(unsigned(x), 17) xor rotate_right(unsigned(x), 19) xor shift_right(unsigned(x), 10));
end function;





-- Define an array called K with 64 slots, each corresponding to the 32 first bits of the fractional parts of the cube roots
-- of the first 64 prime numbers

type K is ARRAY(0 to 63) of std_logic_vector(31 downto 0);
signal constants : K := (
			x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
			x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
			x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
			x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
			x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
			x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
			x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
			x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
		);
		
-- Block decomposition of the incoming message
-- M holds 64 words of 32 bits each. The first 16 words are obtained by simply splitting the
-- 512 bit message block into 16 words, 32 bits each. These values are added after the begin declaration of the architecture 			
type M is array (0 to 63) of std_logic_vector(31 downto 0);

signal Message : M;
-- This computes the next M(i) value after the 16th index of M
 function messageBlock(mBlock : M; i : integer) return std_logic_vector is
begin

return std_logic_vector(unsigned(lsig1(mBlock(i-2))) + unsigned(mBlock(i-7)) + unsigned(lsig0(mBlock(i-15))) + unsigned(mBlock(i-16)));
--return x"01010101";
  end function;


-- function which takes in the Message block and the iteration number
-- and outputs the new Mess



-- Test input of 512 bit to be hashed
   --signal input : std_logic_vector(0 to 511) := x"2a19f8a396959e87a0607a7eae4abb941135e49b8d342e7bb923a7ca33b09ff78000000000000000000000000000000000000000000000000000000000000100";
--signal input : std_logic_vector(0 to 511) := x"61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
--signal input : std_logic_vector(0 to 511) := x"68692074686572658000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040";


--signal blockheader : std_logic_vector(0 to 639) := x"1a65600ea6c8cb4db3936a1ae314399180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000";
--signal blockheader : std_logic_vector(0 to 639) := x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1AE3143991"; 

signal input : std_logic_vector(0 to 511);

-- Block incrementer
signal mBlockIncrementer : integer := 16;

-- Hash variables, given by the first 32 bits of the fractional part of the square roots of the first 8 prime numbers
signal h1 : std_logic_vector(31 downto 0) := x"6a09e667";
signal h2 : std_logic_vector(31 downto 0) := x"bb67ae85";
signal h3 : std_logic_vector(31 downto 0) := x"3c6ef372";
signal h4 : std_logic_vector(31 downto 0) := x"a54ff53a";
signal h5 : std_logic_vector(31 downto 0) := x"510e527f";
signal h6 : std_logic_vector(31 downto 0) := x"9b05688c";
signal h7 : std_logic_vector(31 downto 0) := x"1f83d9ab";
signal h8 : std_logic_vector(31 downto 0) := x"5be0cd19";

-- Intermediate values
signal a : std_logic_vector(31 downto 0) := x"6a09e667";
signal b : std_logic_vector(31 downto 0) := x"bb67ae85";
signal c : std_logic_vector(31 downto 0) := x"3c6ef372";
signal d : std_logic_vector(31 downto 0) := x"a54ff53a";
signal e : std_logic_vector(31 downto 0) := x"510e527f";
signal f : std_logic_vector(31 downto 0) := x"9b05688c";
signal g : std_logic_vector(31 downto 0) := x"1f83d9ab";
signal h : std_logic_vector(31 downto 0) := x"5be0cd19";
    

signal T1 : std_logic_vector(31 downto 0);
signal T2 : std_logic_vector(31 downto 0);

-- State B intermediate incrementer
-- Does 64 rounds, so 6 bit value is enoug
signal Binc : integer := 0;


-- Debug signals
signal htest : std_logic_vector(31 downto 0);
signal sig1test : std_logic_vector(31 downto 0);
signal chtest : std_logic_vector(31 downto 0);
signal ktest : std_logic_vector(31 downto 0);
signal wtest : std_logic_vector(31 downto 0);

-- States to determine the stage of the algorithm
TYPE State_type IS (StateA, StateB, StateC, StateD, StateE);  -- Define the states, A for initialising message block, B for hashing to begin
SIGNAL state : State_Type := StateA;    -- Create a signal that uses 

-- Ready signal
signal ready : std_logic := '1';
signal blockNo : integer := 0;
-- Hash output

--signal Hash : std_logic_vector(0 to 255);
begin



process(clk, reset)
begin

if reset = '1' then 
rdy <= '0';
ready <= '1';
Message <= (others=> (others=>'0'));
T1 <= (others=>'0');
T2 <= (others=>'0');
state <= stateA;


  h1<= x"6a09e667";
  h2 <= x"bb67ae85";
  h3 <= x"3c6ef372";
  h4 <= x"a54ff53a";
  h5 <= x"510e527f";
  h6 <= x"9b05688c";
  h7 <= x"1f83d9ab";
  h8 <= x"5be0cd19";

  a <= x"6a09e667";
  b <= x"bb67ae85";
  c <= x"3c6ef372";
  d <= x"a54ff53a";
  e <= x"510e527f";
  f <= x"9b05688c";
  g <= x"1f83d9ab";
  h <= x"5be0cd19";
  
  mBlockIncrementer <= 16;

  Binc <= 0;
  blockNo <= 0;
  Hash <=(others=>'0');

 
-- Else continue with normal operations
else 

if enable = '1' then
if(ready <= '1' and blockNo = 0) then
 input(0 to 511) <= blockheader(0 to 511); -- !! new important put it back here if messed up

ready <= '0';
elsif(ready <= '1' and blockNo = 1) then

end if;

if(ready <= '0' and state <= stateA) then
-- Initialize the first 16 blocks of this Message block signal variable 
Message(0) <= input(0 to 31);
Message(1) <= input(32 to 63);
Message(2) <= input(64 to 95);
Message(3) <= input(96 to 127);
Message(4) <= input(128 to 159);
Message(5) <= input(160 to 191);
Message(6) <= input(192 to 223);
Message(7) <= input(224 to 255);
Message(8) <= input(256 to 287);
Message(9) <= input(288 to 319);
Message(10) <= input(320 to 351);
Message(11) <= input(352 to 383);
Message(12) <= input(384 to 415);
Message(13) <= input(416 to 447);
Message(14) <= input(448 to 479);
Message(15) <= input(480 to 511);
state <= stateB;
end if;

T1 <= std_logic_vector(unsigned(h) + unsigned(usig1(e)) + unsigned(choose(e, f, g)) + unsigned(Message(Binc)) + unsigned(constants(Binc))); 
T2 <= std_logic_vector(unsigned(usig0(a)) + unsigned(Maj(a, b, c)));

htest <= h;
sig1test <= usig1(e);
chtest <= choose(e, f, g);
ktest <= constants(Binc);
wtest <= Message(Binc);

if rising_edge(clk) then

-- State A 
-- This takes 64-16 clock cycles to initialise the message block
if(mBlockIncrementer < 64 and state = stateB) then
	Message(mBlockIncrementer) <= messageBlock(Message, mBlockIncrementer);
	mBlockIncrementer <= mBlockIncrementer + 1;

	if(mBlockIncrementer = 63) then
	state <= stateC;
	--std_logic_vector(unsigned(lsig1(mBlock(i-2))) + unsigned(mBlock(i-7)) + unsigned(lsig0(mBlock(i-15))) + unsigned(mBlock(i-16)));
	a <= h1;
	b <= h2;
	c <= h3;
	d <= h4;
	e <= h5;
	f <= h6;
	g <= h7;
	h <= h8;
	
	
	--T1 <= std_logic_vector(unsigned(h) + unsigned(lsig1(e)) + unsigned(choose(e, f, g)) + unsigned(Message(0)) + unsigned(constants(0))); 
	--T2 <= std_logic_vector(unsigned(usig0(a)) + unsigned(Maj(a, b, c)));
	end if;
end if;

if(state = stateC and Binc < 63) then

h <= g;
g <= f;
f <= e;
e <= std_logic_vector(unsigned(d)+unsigned(T1));
d <= c;
c <= b;
b <= a;
a <= std_logic_vector(unsigned(T1) + unsigned(T2));
Binc <= Binc + 1;

elsif(state = stateC and Binc = 63) then
h <= g;
g <= f;
f <= e;
e <= std_logic_vector(unsigned(d)+unsigned(T1));
d <= c;
c <= b;
b <= a;
a <= std_logic_vector(unsigned(T1) + unsigned(T2));
state <= stateD;
end if;

end if;

if(state = stateD) then
h1 <= std_logic_vector(unsigned(h1) + unsigned(a));
h2 <= std_logic_vector(unsigned(h2) + unsigned(b));
h3 <= std_logic_vector(unsigned(h3) + unsigned(c));
h4 <= std_logic_vector(unsigned(h4) + unsigned(d));
h5 <= std_logic_vector(unsigned(h5) + unsigned(e));
h6 <= std_logic_vector(unsigned(h6) + unsigned(f));
h7 <= std_logic_vector(unsigned(h7) + unsigned(g));
h8 <= std_logic_vector(unsigned(h8) + unsigned(h));
state <= stateE;

end if;

if(state = stateE and blockNo <= 0) then
state <= stateA;
blockNo <= 1;
Binc <= 0;
mBlockIncrementer <= 16;


Message(0) <= (others => '0');
Message(1) <= (others => '0');
Message(2) <= (others => '0');
Message(3) <= (others => '0');
Message(4) <= (others => '0');
Message(5) <= (others => '0');
Message(6) <= (others => '0');
Message(7) <= (others => '0');
Message(8) <= (others => '0');
Message(9) <= (others => '0');
Message(10) <= (others => '0');
Message(11) <= (others => '0');
Message(12) <= (others => '0');
Message(13) <= (others => '0');
Message(14) <= (others => '0');
Message(15) <= (others => '0');
input(0 to 127) <= blockheader(512 to 639);
input(128) <= '1';
input(129 to 448) <= (others=>'0');
input(448 to 511) <= x"0000000000000280";

elsif(state = stateE and blockNo <= 1) then
state <= stateE;
rdy <= '1';
end if;
--output <= Hash;
Hash <= h1&h2&h3&h4&h5&h6&h7&h8;

end if;
end if;

end process;



end Behavioral;
