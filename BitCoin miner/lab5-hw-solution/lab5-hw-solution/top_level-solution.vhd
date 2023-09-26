-- Processor template
-- Daniel Roggen, 2016

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;
--USE ieee.std_logic_arith.ALL;


entity top_level is
    Port (
				-- Board 100MHz clock
				clk : in STD_LOGIC;

                -- UART
                RsRx : in std_logic;
                RsTx : out std_logic;

				-- Some buttons and LEDs may be handy
				led : out  STD_LOGIC_VECTOR (15 downto 0);
				sw : in STD_LOGIC_VECTOR(15 downto 0);
				btnU : in  STD_LOGIC;
				btnD : in  STD_LOGIC;
				btnC : in  STD_LOGIC;
				btnL : in  STD_LOGIC;
				btnR : in  STD_LOGIC;
				btnCpuReset : in STD_LOGIC;
				seg : out STD_LOGIC_VECTOR(6 downto 0);
				an : out STD_LOGIC_VECTOR(7 downto 0)

                );
end top_level;


architecture Behavioral of top_level is
 -- Declaration of component clock buffer
   component BUFG 
             port (O : out STD_ULOGIC; 
             I : in STD_ULOGIC); 
   end component;
   
   -- Declaration of component PLL
   component PLLE2_BASE
       generic (
           BANDWIDTH : string := "OPTIMIZED";
           CLKFBOUT_MULT : integer := 5;
           CLKFBOUT_PHASE : real := 0.000;
           CLKIN1_PERIOD : real := 0.000;
           CLKOUT0_DIVIDE : integer := 1;
           CLKOUT0_DUTY_CYCLE : real := 0.500;
           CLKOUT0_PHASE : real := 0.000;
           CLKOUT1_DIVIDE : integer := 1;
           CLKOUT1_DUTY_CYCLE : real := 0.500;
           CLKOUT1_PHASE : real := 0.000;
           CLKOUT2_DIVIDE : integer := 1;
           CLKOUT2_DUTY_CYCLE : real := 0.500;
           CLKOUT2_PHASE : real := 0.000;
           CLKOUT3_DIVIDE : integer := 1;
           CLKOUT3_DUTY_CYCLE : real := 0.500;
           CLKOUT3_PHASE : real := 0.000;
           CLKOUT4_DIVIDE : integer := 1;
           CLKOUT4_DUTY_CYCLE : real := 0.500;
           CLKOUT4_PHASE : real := 0.000;
           CLKOUT5_DIVIDE : integer := 1;
           CLKOUT5_DUTY_CYCLE : real := 0.500;
           CLKOUT5_PHASE : real := 0.000;
           DIVCLK_DIVIDE : integer := 1;
           REF_JITTER1 : real := 0.010;
           STARTUP_WAIT : string := "TRUE"
       );
       port (
           CLKFBOUT : out std_ulogic;
           CLKOUT0 : out std_ulogic;
           CLKOUT1 : out std_ulogic;
           CLKOUT2 : out std_ulogic;
           CLKOUT3 : out std_ulogic;
           CLKOUT4 : out std_ulogic;
           CLKOUT5 : out std_ulogic;
           LOCKED : out std_ulogic;
           CLKFBIN : in std_ulogic;
           CLKIN1 : in std_ulogic;
           PWRDWN : in std_ulogic;
           RST : in std_ulogic
       );
   end component PLLE2_BASE;

    -- Clock and PLL
    signal clk25 : STD_LOGIC;
    signal pll_fb : std_logic;
    signal pll_locked : std_logic;
    signal pll_clk : std_logic_vector(5 downto 0);
    signal reset : std_logic := '0';   
       
    -- Display signals
    signal display_d7 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d6 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d5 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d4 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d3 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d2 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d1 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_d0 : STD_LOGIC_VECTOR(3 downto 0);
    signal display_blink : STD_LOGIC_VECTOR(7 downto 0);       
       
    -- CPU I/O
    signal gpi_int : std_logic;
    signal fit_toggle,fit_interrupt : std_logic;
    signal cpu_addr_strobe : STD_LOGIC;
    signal cpu_read_strobe : STD_LOGIC;
    signal cpu_write_strobe : STD_LOGIC;
    signal cpu_address : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_byte_enable : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal cpu_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cpu_ready : STD_LOGIC;
    
    
    signal gpo1 : std_logic_vector(31 downto 0);
    signal gpo2 : std_logic_vector(31 downto 0);
    signal gpo3 : std_logic_vector(31 downto 0);
    signal gpo4 : std_logic_vector(31 downto 0);
    signal gpi1 : std_logic_vector(31 downto 0);
    signal gpi2 : STD_LOGIC_VECTOR(31 downto 0);
    
    signal checked : std_logic := '0';
    signal debug : std_logic_vector(3 downto 0);


    
    -- Custom IO
    signal register_data : std_logic_vector(31 downto 0);
    signal register_addr : std_logic_vector(31 downto 0);

    -- RAM
    signal ram_addressA, ram_addressB : std_logic_vector(13 downto 0);
    signal ram_datain,ram_dataoutA,ram_dataoutB : std_logic_vector(7 downto 0);
    signal ram_weA : std_logic;    
    
    -- Block Header values
    signal version : std_logic_vector(31 downto 0);
    signal prevBlock : std_logic_vector(255 downto 0);
    signal merkleroot : std_logic_vector(255 downto 0);
    signal bits : std_logic_vector(0 to 31) := x"1a6a93b3";
    signal timestamp : std_logic_vector(31 downto 0);
    signal nonce : std_logic_vector(31 downto 0);
    
    -- Target value
    signal target : std_logic_vector(0 to 255) := (others => '0');
    signal blockheaderNo : std_logic_vector(0 to 607):= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB3936A1A";
   --signal blockheaderNo : std_logic_vector(0 to 607):= x"010000009500c43a25c624520b5100adf82cb9f9da72fd2447a496bc600b0000000000006cd862370395dedf1da2841ccda0fc489e3039de5f1ccddef0e834991a65600eA6C8CB4DB393AAAA";
   
   signal parsedBlockheader : std_logic_vector(0 to 607);
    signal blockheader : std_logic_vector(0 to 639);
    
    signal nonceIter : std_logic_vector(0 to 31) := x"E314398C";

    
    -- The miner inputs
    signal enable : std_logic := '0';
    signal ready : std_logic := '0';
    signal output : std_logic_vector(0 to 255);
   
   signal solved : std_logic := '0';
   
   signal dd7 : std_logic_vector(3 downto 0);
    
    -- Microblaze
COMPONENT microblaze_mcs_0
      PORT (
        Clk : IN STD_LOGIC;
        Reset : IN STD_LOGIC;
        IO_addr_strobe : OUT STD_LOGIC;
        IO_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        IO_byte_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        IO_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        IO_read_strobe : OUT STD_LOGIC;
        IO_ready : IN STD_LOGIC;
        IO_write_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        IO_write_strobe : OUT STD_LOGIC;
        UART_rxd : IN STD_LOGIC;
        UART_txd : OUT STD_LOGIC;
        GPIO1_tri_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO1_tri_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO2_tri_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO2_tri_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO3_tri_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        GPIO4_tri_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;

    

begin  
    ----------------------------------------------------------------------------
    -- Default projects - modify starting from PART 1
    ----------------------------------------------------------------------------
    -- Create a 25MHz clock

    pll_inst : PLLE2_BASE
    generic map (
        CLKIN1_PERIOD => 10.0,      -- 100MHz = 10ns
        CLKFBOUT_MULT => 8,         -- Multiplier
        CLKOUT0_DIVIDE => 32,    
        CLKOUT1_DIVIDE => 32,    
        CLKOUT2_DIVIDE => 32,    
        CLKOUT3_DIVIDE => 32,    
        CLKOUT4_DIVIDE => 32,    
        CLKOUT5_DIVIDE => 32,       -- Clock output divider. This circuit uses only CLKOUT5 
        DIVCLK_DIVIDE => 1 )        -- General divider. 
    port map ( 
        CLKIN1 => clk,
        CLKFBOUT => pll_fb,
        CLKFBIN => pll_fb,
        CLKOUT0 => pll_clk(0),
        CLKOUT1 => pll_clk(1),
        CLKOUT2 => pll_clk(2),
        CLKOUT3 => pll_clk(3),
        CLKOUT4 => pll_clk(4),
        CLKOUT5 => pll_clk(5),     -- This circuit uses only CLKOUT5
        LOCKED => pll_locked,
        PWRDWN => '0',
        RST => '0' );    
    clk25<=pll_clk(5);
    

    
    -- Reset active high
    --reset<=not btnCpuReset;
    

     
    -- Display multiplexers: toggle between register_addr and register_data
    display_blink <= "00000000";
    
    display_d7 <= gpo1(31 downto 28) when sw(15 downto 14) = "00" else
                  gpo2(31 downto 28) when sw(15 downto 14)= "01" else
                  gpo3(31 downto 28) when sw(15 downto 14)= "10" else
                  gpo4(31 downto 28) when sw(15 downto 14)= "11" else
                  "1111";
    
    display_d6 <= gpo1(27 downto 24) when sw(15 downto 14) = "00" else
                  gpo2(27 downto 24) when sw(15 downto 14)= "01" else
                  gpo3(27 downto 24) when sw(15 downto 14)= "10" else
                  gpo4(27 downto 24) when sw(15 downto 14)= "11" else
                  "1111";
    
    display_d5 <= gpo1(23 downto 20) when sw(15 downto 14) = "00" else
                   gpo2(23 downto 20) when sw(15 downto 14)= "01" else
                   gpo3(23 downto 20) when sw(15 downto 14)= "10" else
                   gpo4(23 downto 20) when sw(15 downto 14)= "11" else
                   "1111";
    
    display_d4 <= gpo1(19 downto 16) when sw(15 downto 14) = "00" else
                  gpo2(19 downto 16) when sw(15 downto 14)= "01" else
                  gpo3(19 downto 16) when sw(15 downto 14)= "10" else
                  gpo4(19 downto 16) when sw(15 downto 14)= "11" else
                  "1111";
    
    
    display_d3 <= gpo1(15 downto 12) when sw(15 downto 14) = "00" else
                  gpo2(15 downto 12) when sw(15 downto 14)= "01" else
                  gpo3(15 downto 12) when sw(15 downto 14)= "10" else
                  gpo4(15 downto 12) when sw(15 downto 14)= "11" else
                  "1111";
    
    display_d2 <= gpo1(11 downto 8) when sw(15 downto 14) = "00" else
                  gpo2(11 downto 8) when sw(15 downto 14)= "01" else
                  gpo3(11 downto 8) when sw(15 downto 14)= "10" else
                  gpo4(11 downto 8) when sw(15 downto 14)= "11" else
                  "1111";
    
    
    display_d1 <= gpo1(7 downto 4) when sw(15 downto 14) = "00" else
                  gpo2(7 downto 4) when sw(15 downto 14)= "01" else
                  gpo3(7 downto 4) when sw(15 downto 14)= "10" else
                  gpo4(7 downto 4) when sw(15 downto 14)= "11" else
                  "1111";
    
    display_d0 <= gpo1(3 downto 0) when sw(15 downto 14) = "00" else
                  gpo2(3 downto 0) when sw(15 downto 14)= "01" else
                  gpo3(3 downto 0) when sw(15 downto 14)= "10" else
                  gpo4(3 downto 0) when sw(15 downto 14)= "11" else
                  "1111";




    
   -- Instantiaise microblaze with 4 GPO output ports
    mcs : microblaze_mcs_0
  PORT MAP (
    Clk => Clk25,
    Reset => Reset,
    IO_addr_strobe => open,
    IO_address => open,
    IO_byte_enable => open,
    IO_read_data => (others=>'0'),
    IO_read_strobe => open,
    IO_ready => '0',
    IO_write_data => open,
    IO_write_strobe => open,
    UART_rxd => RsRx,
    UART_txd => RsTx,
    GPIO1_tri_i => gpi1,
    GPIO1_tri_o => gpo1,
    GPIO2_tri_i => gpi2,
    GPIO2_tri_o => gpo2,
    GPIO3_tri_o => gpo3,
    GPIO4_tri_o => gpo4
  );

  
  
-- Instantiate the 7-segment display
       comp_h27s: entity work.hexto7seg port map(clk=>Clk25,
           --d7=> nonceIter(0 to 3), 
           d7 => dd7,
           --d6=> nonceIter(4 to 7), 
           d6 => output(252 to 255),
           --d5=> nonceIter(8 to 11),
           d5 => debug,
           d4=> nonceIter(12 to 15),
           d3=> nonceIter(16 to 19),
           d2=> nonceIter(20 to 23),
           d1=> nonceIter(24 to 27),
           d0=> nonceIter(28 to 31),
           blink=>display_blink,
           q=>seg,
           active=>an);
           
           dd7 <= enable&reset&ready&checked;



blockSolver: entity work.blocksolver port map(clk=>Clk25,
blockheader => blockheader,
enable => enable,
reset => reset, 
finalrdy => ready,
readytest1 => open,
readytest2 => open,
output => output,
output2 => open);



--signal bits : std_logic_vector(31 downto 0) := x"1a6a93b3";

-- Should blockheader be updated in process(clk) or not?
blockheader <= blockheaderNo&nonceIter;


process(clk25)
begin
--blockheader <= blockheaderNo&nonceIter;

--target(natural(bits(7 downto 0))) <= x"22";


--target(unsigned(unsigned(bits(31 downto 23))+unsigned(24)) to unsigned(bits(31 downto 23))) <= bits(23 downto 0);


if clk25'event and clk25='1' then


          
          if(enable = '0' and ready = '1') then
          checked <= '0';
          reset <= '0';
          debug <= "0001";

          elsif(ready /= '1') then
          reset <= '0';
          enable <= '1';
          debug <= "0010";
          elsif(ready = '1' and checked = '0') then
          
            if(nonceIter /= x"e3143991") then
                nonceIter <= std_logic_vector(  unsigned(nonceIter) + 1  );
                debug <= "1000";
            end if;
          debug <= "0100";

          enable <= '0';
          reset <= '1';
          checked <= '1';
          end if;
          
          
          
          
          end if;
          


end process;
            
            
            




-- Instantiate 1024 bit input SHA256 


    cpu_ready<='1';

    
        
    
    
    
    
    process(clk25)
    begin
         if clk25'event and clk25='1' then
         
         if( gpo4(3 downto 0) = "0000" ) then
            version(0 downto 31) <= gpo1;
            timestamp(0 downto 31) <= gpo2;
            bits(0 downto 31) <= gpo3;
         elsif( gpo4(3 downto 0) < "0001" ) then
            parsedBlockheader(0 to 95) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0010" ) then
            parsedBlockheader(96 to 191) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0011" ) then
            parsedBlockheader(192 to 287) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0100" ) then
            parsedBlockheader(288 to 383) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0101" ) then
            parsedBlockheader(384 to 479) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0110" ) then
            parsedBlockheader(480 to 575) <= gpo3&gpo2&gpo1;
         elsif( gpo4(3 downto 0) < "0111" ) then
            parsedBlockheader(576 to 607) <= gpo1;
         end if;

         
         end if;
    end process;
    
    
    process(clk25)
    begin
        if clk25'event and clk25='1' then
            if cpu_write_strobe='1' then
                register_data <= cpu_write_data;
            end if;
        end if;
    end process;        
    

    
    process(clk25)
    begin
       if clk25'event and clk25='1' then
           if cpu_write_strobe='1' then
               register_addr <= cpu_address;
           end if;
       end if;
    end process;    
    


    ram_datain<=cpu_write_data(7 downto 0);
    ram_weA<=cpu_write_strobe;
    cpu_read_data(7 downto 0)<=ram_dataoutA;
    cpu_read_data(31 downto 8)<=(others=>'0');

    ram_addressA<=cpu_address(15 downto 2);
    

	
end Behavioral;








