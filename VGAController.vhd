----------------------------------------------------------------------------------
-- Autor: Juan Manuel Portillo López
-- Nombre de Proyecto: Ping-Pong
-- Descripción: El módulo superior del proyecto recibe su entrada de la placa, 
-- 		genera las salidas utilizando sus submódulos y las envía al monitor desde la placa. 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGAController is
  Port (clock, centerButton, leftButton, rightButton: in std_logic;
        difficultyControl: in std_logic_vector(1 downto 0);
        hSync, vSync: out std_logic;
        VGARed, VGAGreen, VGABlue: out std_logic_vector(3 downto 0));
end VGAController;

architecture Behavioral of VGAController is
--Declaración de los componentes
component ClockDivider is
    Port (clockIn: in std_logic;
          clockOut: out std_logic);
end component;  
component Sync is
    Port (clock, left, right, start: in std_logic;
          difficultyControl: in std_logic_vector(1 downto 0);
          hSync, vSync: out std_logic; 
          r, g, b: out std_logic_vector(3 downto 0));
end component;
--Señal ´portadora intermedia   
signal VGAClock: std_logic;   
begin
    --port-mapeos
    Component1: ClockDivider 
                    port map(clockIn => clock,
                             clockOut => VGAClock);
    Component2: Sync
                    port map(clock => VGAClock,
                             left => leftButton,
                             right => rightButton,
                             start => centerButton,
                             difficultyControl => difficultyControl,
                             hSync => hSync,
                             vSync => vSync,
                             r => VGARed,
                             g => VGAGreen,
                             b => VGABlue);
end Behavioral;
