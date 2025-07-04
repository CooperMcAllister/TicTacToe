------------------------------------------------------------------------------
--EEGR 3213 Digital Electronics
--Spring 2025 Project
--Team 2 "Bit Benders"
--
--Code written by Cooper McAllister
--May 1, 2025
------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TicTacToe is
    port ( 
        buttons: in std_logic_vector(8 downto 0);
        ledsBlue: out std_logic_vector(8 downto 0);
        ledsRed: out std_logic_vector(8 downto 0);
        clk: in std_logic;
        turnDebug: out std_logic;
        resetButton: in std_logic;
        turnBlue: out std_logic;
        turnRed: out std_logic
    );
end TicTacToe;

architecture Behavioral of TicTacToe is
    signal blue: std_logic_vector(8 downto 0) := (others => '0');
    signal red: std_logic_vector(8 downto 0) := (others => '0');
    -- 0 = Blue, 1 = Red
    signal turn: std_logic := '0';
    signal blueWin: std_logic;
    signal redWin: std_logic;
    signal catsGame: std_logic;
    signal reset: std_logic := '0';
    signal delayCounter: integer := 0;
    constant delayCountMax: integer := 50000000;
    signal delayEnd: std_logic := '0';
    signal clkDivided: std_logic;
    signal clkCount: integer := 0;
    signal clkRollover: integer := 2;
    
begin
    --Main Process
    process (clkDivided, clk, blue, red, buttons, turn)
    begin
    if rising_edge(clkDivided)  then
    if reset = '1' then
        if delayEnd = '1' OR resetButton = '1' then
            --Reset Everything
            blue <= "000000000";
            red <=  "000000000";
            delayEnd <= '0';
        else
            if blueWin = '1' then
                blue <= "111111111";
                red <= "000000000";
            elsif redWin = '1' then
                blue <= "000000000";
                red <= "111111111";
            end if;
            --Wait Timer
            delayCounter <= delayCounter + 1;
            if(delayCounter = delayCountMax) then
                delayEnd <= '1';
                delayCounter <= 0;
            end if;
        end if;
    else
        for i in 0 to 8 loop
          case turn is
          when '0' =>
            --Blue's Turn
            if blue(i) = '0' AND red(i) = '0' AND buttons(i) = '1' then
                turn <= '1';
                blue(i) <= '1';
            end if;
          when '1' =>
            --Red's Turn
            if red(i) = '0' AND blue(i) = '0' AND buttons(i) = '1' then
                turn <= '0';
                red(i) <= '1';
            end if;
          end case;  
        end loop;
    end if;
    end if;
    end process;
    
    -- Clock Divider Process
    process (clk)
    begin
        if rising_edge(clk) then
            clkCount <= clkCount + 1;
            --clkRollover is 2 - divides the clock in half
            if(clkCount = clkRollover) then
                clkDivided <= NOT clkDivided;
                clkCount <= 0;
            end if;
        end if;
    end process;
    
    --Win Conditions
    blueWin <= (blue(0) AND blue(1) AND blue(2)) OR (blue(3) AND blue(4) AND blue(5)) OR (blue(6) AND blue(7) AND blue(8)) 
    OR (blue(0) AND blue(3) AND blue(6)) OR (blue(1) AND blue(4) AND blue(7)) OR (blue(2) AND blue(5) AND blue(8)) 
    OR (blue(0) AND blue(4) AND blue(8)) OR (blue(2) AND blue(4) AND blue(6));
    
    redWin <= (red(0) AND red(1) AND red(2)) OR (red(3) AND red(4) AND red(5)) OR (red(6) AND red(7) AND red(8)) 
    OR (red(0) AND red(3) AND red(6)) OR (red(1) AND red(4) AND red(7)) OR (red(2) AND red(5) AND red(8)) 
    OR (red(0) AND red(4) AND red(8)) OR (red(2) AND red(4) AND red(6));
        
    catsGame <= (blue(0) OR red(0)) AND (blue(1) OR red(1)) AND (blue(2) OR red(2)) AND (blue(3) OR red(3)) AND (blue(4) OR red(4)) 
    AND (blue(5) OR red(5)) AND (blue(6) OR red(6)) AND (blue(7) OR red(7)) AND (blue(8) OR red(8));   
    
    --Reset Bit
    reset <= blueWin OR redWin OR catsGame OR resetButton;
   
    --Output
    LedOutput: for i in 0 to 8 generate
        ledsBlue(i) <= blue(i);
        ledsRed(i) <= red(i);
    end generate LedOutput;
    
    --Turn Display
    turnBlue <= NOT turn;
    turnRed <= turn;
    
    --Debug
    turnDebug <= turn;

end Behavioral;
