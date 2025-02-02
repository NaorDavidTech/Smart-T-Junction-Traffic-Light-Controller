library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity T_junction_traffic_light is
   Port ( 
       clk      : in  STD_LOGIC;
       reset    : in  STD_LOGIC;
       alarm    : in  STD_LOGIC;
       sensors  : in  STD_LOGIC_VECTOR(1 downto 0);
       r1, y1, g1, r2, y2, g2 : out STD_LOGIC
   );
end T_junction_traffic_light;

architecture Ramzor of T_junction_traffic_light is
   type state_type is (YY, RY, RG, YR, GR, ALARM_YELLOW, ALARM_GREEN);
   signal current_state, next_state : state_type;
   signal counter : INTEGER range 0 to 1000 := 0;
   signal night_mode : STD_LOGIC := '0';
   
   constant YELLOW_TIME : INTEGER := 30;
   constant RED_GREEN_TIME : INTEGER := 80;
   constant ALARM_TIME : INTEGER := 120;
   constant NIGHT_THRESHOLD : INTEGER := 800;
   
begin
   sync_process: process (clk, reset)
   begin
       if reset = '1' then
           current_state <= YY;
           counter <= 0;
           night_mode <= '0';
       elsif clk'event and clk = '1' then
           if counter = 0 then
               current_state <= next_state;
               case next_state is
                   when YY => counter <= YELLOW_TIME;
                   when ALARM_YELLOW | ALARM_GREEN => counter <= ALARM_TIME;
                   when others => 
                       if night_mode = '1' then
                           counter <= RED_GREEN_TIME / 2;
                       else
                           counter <= RED_GREEN_TIME;
                       end if;
               end case;
           else
               counter <= counter - 1;
           end if;
           
           if counter >= NIGHT_THRESHOLD then
               night_mode <= '1';
           else
               night_mode <= '0';
           end if;
       end if;
   end process;

   comb_process: process (current_state, alarm, sensors, night_mode)
   begin
       r1 <= '0'; y1 <= '0'; g1 <= '0';
       r2 <= '0'; y2 <= '0'; g2 <= '0';
       next_state <= current_state;

       case current_state is
           when YY =>
               y1 <= '1'; y2 <= '1';
               next_state <= RY;

           when RY =>
               r1 <= '1'; y2 <= '1';
               if alarm = '1' then
                   next_state <= ALARM_YELLOW;
               elsif sensors(1) = '1' then
                   next_state <= RG;
               else
                   next_state <= YY;
               end if;

           when RG =>
               r1 <= '1'; g2 <= '1';
               if alarm = '1' then
                   next_state <= ALARM_YELLOW;
               elsif sensors(0) = '1' then
                   next_state <= YY;
               else
                   next_state <= RG;
               end if;

           when YR =>
               y1 <= '1'; r2 <= '1';
               next_state <= GR;

           when GR =>
               g1 <= '1'; r2 <= '1';
               if sensors(1) = '1' or night_mode = '1' then
                   next_state <= YY;
               end if;

           when ALARM_YELLOW =>
               y1 <= '1'; y2 <= '1';
               if alarm = '0' then
                   next_state <= YY;
               else
                   next_state <= ALARM_GREEN;
               end if;

           when ALARM_GREEN =>
               g1 <= '1'; r2 <= '1';
               if alarm = '0' then
                   next_state <= YY;
               end if;

           when others =>
               next_state <= YY;
       end case;
   end process;

end Ramzor;