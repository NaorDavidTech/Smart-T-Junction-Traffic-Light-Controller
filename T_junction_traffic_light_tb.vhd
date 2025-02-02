library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity T_junction_traffic_light_tb is
end T_junction_traffic_light_tb;

architecture behavior of T_junction_traffic_light_tb is
   component T_junction_traffic_light
       Port ( 
           clk      : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           alarm    : in  STD_LOGIC;
           sensors  : in  STD_LOGIC_VECTOR(1 downto 0);
           r1, y1, g1, r2, y2, g2 : out STD_LOGIC
       );
   end component;
   
   signal clk_tb      : std_logic := '0';
   signal reset_tb    : std_logic := '0';
   signal alarm_tb    : std_logic := '0';
   signal sensors_tb  : std_logic_vector(1 downto 0) := "00";
   signal r1_tb, y1_tb, g1_tb, r2_tb, y2_tb, g2_tb : std_logic;
   
   constant CLK_PERIOD : time := 10 ns;
   
begin
   UUT: T_junction_traffic_light port map (
       clk => clk_tb,
       reset => reset_tb,
       alarm => alarm_tb,
       sensors => sensors_tb,
       r1 => r1_tb,
       y1 => y1_tb,
       g1 => g1_tb,
       r2 => r2_tb,
       y2 => y2_tb,
       g2 => g2_tb
   );

   clk_process: process
   begin
       clk_tb <= '0';
       wait for CLK_PERIOD/2;
       clk_tb <= '1';
       wait for CLK_PERIOD/2;
   end process;
   
   stim_proc: process
   begin
       reset_tb <= '1';
       wait for CLK_PERIOD*2;
       reset_tb <= '0';
       wait for CLK_PERIOD*2;
       
       -- Normal operation test
       wait for CLK_PERIOD*50;
       
       -- Sensors test
       sensors_tb <= "01";
       wait for CLK_PERIOD*100;
       sensors_tb <= "10";
       wait for CLK_PERIOD*100;
       sensors_tb <= "00";
       
       -- Alarm mode test
       wait for CLK_PERIOD*50;
       alarm_tb <= '1';
       wait for CLK_PERIOD*200;
       alarm_tb <= '0';
       
       -- Night mode test
       wait for CLK_PERIOD*1000;
       
       -- Reset during operation test
       reset_tb <= '1';
       wait for CLK_PERIOD*2;
       reset_tb <= '0';
       
       wait;
   end process;

   monitor_proc: process
   begin
       wait for CLK_PERIOD;
       if rising_edge(clk_tb) then
           -- Check for illegal states
           if (g1_tb = '1' and g2_tb = '1') then
               report "ERROR: Both traffic lights are green simultaneously" severity error;
           end if;
           
           if (g1_tb = '1' and y1_tb = '1') then
               report "ERROR: Green and yellow lights are on simultaneously in traffic light 1" severity error;
           end if;
           
           if (g2_tb = '1' and y2_tb = '1') then
               report "ERROR: Green and yellow lights are on simultaneously in traffic light 2" severity error;
           end if;
           
           -- Check state transitions
           if (g1_tb'event or g2_tb'event) then
               report "Traffic light state transition detected" severity note;
           end if;
       end if;
   end process;

end behavior;