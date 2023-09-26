-- VGA Driver Module
-- Daniel Roggen, 2015


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;
--USE ieee.std_logic_arith.ALL;


-- Define our "vga" entity

entity vga is
    Port (
                -- Input signals
				-- Board 100MHz clock
				clk100 : in STD_LOGIC;
				
				-- Signals used to generate the pattern on screen
				signal out_frame : out std_logic_vector(23 downto 0);
				signal out_x : out std_logic_vector(11 downto 0);
				signal out_y : out std_logic_vector(11 downto 0);
				
				-- Desired pixel color; this gets modified in this entity to realize the front/back porches
				signal in_r : in std_logic;
				signal in_g : in std_logic;
				signal in_b : in std_logic;
				
				
				-- Signals to connect to the VGA connector
				-- Pixel color (r,g,b)
				out_r : out  STD_LOGIC;
				out_g : out  STD_LOGIC;
				out_b : out  STD_LOGIC;
				-- Sync signals
				out_hsync : out  STD_LOGIC;
				out_vsync : out  STD_LOGIC
                );
end vga;


architecture Behavioral of vga is
    -- clkdiv is a 4-bit counter that can be used to divide the clock frequency
	signal clkdiv : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	-- clk25 is clk100 downsampled by 4 (i.e. 25MHz if mainclk is connected to clk)
	signal clk25 : std_logic := '0';
	-- This is the pixel counter
    signal counter_x : std_logic_vector(9 downto 0) := (others => '0');
    -- This is the line counter
    signal counter_y : std_logic_vector(9 downto 0) := (others => '0');
    -- Indicates whether the current x,y counter indicate a visible portion of the display
    signal pixel_active : std_logic;	
	-- Internal hsync and vsync signals; use these in your circuit 
    -- (they are automatically assigned to v_hsync and v_vsync at the end of the vhdl file) 
    signal hsync : std_logic;
    signal vsync : std_logic;

	-- counts the currently displayed frame (VGA updates at 60 frames per second)
	signal counter_frame : std_logic_vector(23 downto 0) := (others => '0');
	
begin

    ------------------------------------------------------------------------------------------
    -- 1. Generate a 25MHz clock from the input clk which is 100 MHz
    --    This requires to divide the clock by a factor 4. 
    --    One way to achieve this is with a counter (clkdiv): at each clock cycle the counter is incremented
    --    Therefore, each bit position contains a signal whose frequency is f/2^n with n the bit position.
    --    A counter is already provided below. 
    --    What you need to do is find on which bit of the counter is toggling at 1/4 the frequency of the clock.
    --    The LEDs 15 to 12 show the clkdiv counter. You can use this to help yourself.
    --    Assign the bit oscillating at 1/4th the frequency of mainclk to clk25    

    process(clk100)
    begin
        if rising_edge(clk100) then
            clkdiv<=clkdiv+1;
        end if;
    end process;
    
    -- Modify the line below; assign the right bit of clkdiv to clk25
    -- clk25<=clkdiv(................);
    clk25<=clkdiv(1);
    
    
    
    
    
    ------------------------------------------------------------------------------------------
    -- 2. Generate the pixel counter (counter_x) to generate the hsync signal
    --    This counter is already provided and nothing needs to be done here
    --    It is realized by a register (D flip-flop) incremented by 1 or set to zero based on a comparison (realized with combinational logic)
	process(clk25)
	begin
        -- The pixel counter (counter_x) must count from 0 to 799....
        -- This is how it could be done:
        if rising_edge(clk25) then         
            if counter_x=std_logic_vector(to_unsigned(799,counter_x'length)) then
                counter_x<=(others => '0');
            else 
                counter_x<=counter_x+1;
            end if;
        end if;
	end process;

    ------------------------------------------------------------------------------------------
    -- 3. Generate hsync 
    --    With the pixel counter, you can easily generate the hsync signal....
    --    Assuming we count pixels clocks on the rising edge of hsync, then hsync goes through the following states (duration in pixel clock cycle indicated)
    --    front porch: 48 pclk
    --    display: 640 pclk
    --    back porch: 16 pclk
    --    pulse: 96 pclk
    --
    --    You must set hsync to 0 during the pixels [704;799]
    --    You can generate this using a multiplexer and if instructions
    --    In order to use if instructions you need to put them in a process. 
    --    Remember to put counter on the sensitivity list!
    
    process(counter_x)
    begin
        -- modify this line to set hsync to zero starting from pixel 704
        -- if counter_x............................................
        if counter_x>=std_logic_vector(to_unsigned(704,counter_x'length)) then
            hsync <= '0';
        else
            hsync <= '1';
        end if;
    end process;

    
    
  			
    ------------------------------------------------------------------------------------------
    -- 4. Generate the line counter (counter_y) to generate the vsync signal
    --    It counts from [0;524] inclusive
    --    Take inspiration from the way counter_x is realized: this is an up counter as well
    --    However, it does not count up at each clock cycle! 
    --    It counts up when there is a rising edge of the clock and some other condition involving counter_x is met.
    --    Find what is the condition to increment counter_y.  
    --    Realize counter_y with a register (D flip-flop) incremented by 1 or set to zero based on the comparison that you found.
  
    
    process(clk25)
    begin
        if rising_edge(clk25) then
            -- Modify the line below: when does counter_y need to be incremented?
            -- if counter_x.............................
            if counter_x=std_logic_vector(to_unsigned(799,counter_x'length)) then
                -- Modify the line below: when does counter_y need to be reset?
                --if counter_y..................................
                if counter_y=std_logic_vector(to_unsigned(524,counter_y'length)) then
                    counter_y<=(others => '0');
                else
                    counter_y<=counter_y+1;
                end if;
            end if;
        end if;
    end process;



    ------------------------------------------------------------------------------------------
    -- 5. Generate vsync 
    --    With the line counter you can easily generate the vsync signal....
    --    vsync: assuming we count lines from the rising edge of vsync, then vsync goes through the following states (duration in lines indicated)
    --    front porch: 33 lines
    --    display: 480 lines
    --    back porch: 10 lines
    --    pulse: 2 lines
    --
    --    You must set vsync to 0 during the lines [523;524]
    --    You can implement this similarly to the way hsync was realized


    process(counter_y)
    begin
        -- Fill in the missing logic...............................
		if counter_y>=std_logic_vector(to_unsigned(523,counter_x'length)) then
            vsync <= '0';
        else
            vsync <= '1';
        end if;
    end process;


    ------------------------------------------------------------------------------------------
    -- 6. Pixel active
    --    The red, green, blue outputs must be zero when in the front or back porch
    --    While some displays tolerate pixels not to be zero in the front/back porch, it is 
    --    good practice to respect the VGA standard.
    --    With other displays, the display turns on but does not show anything, as the 
    --    front and back porch are used to calibrate the black level.   
    --   
    --    pixel_active must be 1 when counter_x is in the range [48;687] and counter_y is in the range [33;512]
    --
    --    Using a process and a series of if statements set pixel_active to 1 when counter_x and counter_y
    --    are within the visible range, and 0 when in the front/back porch
    --    Remember to put counter_x and counter_y in the sensitivity list!
    
    
    process(counter_x,counter_y)
    begin
        if counter_x>=std_logic_vector(to_unsigned(48,counter_x'length)) and counter_x<=std_logic_vector(to_unsigned(687,counter_x'length))
            and counter_y>=std_logic_vector(to_unsigned(33,counter_y'length)) and counter_y<=std_logic_vector(to_unsigned(512,counter_y'length)) then
            pixel_active <= '1';
        else
            pixel_active <= '0';
        end if;
    end process;
    


    
	-- Count the currently displayed frame
	process(clk25)
	begin
        if rising_edge(clk25) then 
            if counter_y="0000000000" and counter_x="0000000000" then 
                counter_frame <= counter_frame + 1;
            end if;
        end if;
    end process;


    
	
	
	-- Assign the internal signals to the outputs of the component
	out_hsync <= hsync;
	out_vsync <= vsync;
	out_r <= in_r and pixel_active;
	out_g <= in_g and pixel_active;
	out_b <= in_b and pixel_active;
	out_x(9 downto 0) <= counter_x;
	out_x(11 downto 10) <= "00";
	out_y(9 downto 0) <= counter_y;
	out_y(11 downto 10) <= "00";
	out_frame <= counter_frame;
	
	
end Behavioral;






