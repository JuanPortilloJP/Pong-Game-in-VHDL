----------------------------------------------------------------------------------
-- Autor: Juan Manuel Portillo López
-- Nombre de Proyecto: Ping-Pong
-- Descripción: Este módulo implica conectar en serie T-flip flops para reducir el
-- 		frecuencia del reloj DE10-lite. Transfiere el reloj dividido
-- 		señal al módulo de sincronización.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockDivider is
    Port (clockIn: in std_logic;
          clockOut: out std_logic);
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal firstDivider, secondDivider: std_logic:= '0';
    begin
        process(clockIn, firstDivider) 
        begin
            if clockIn'event and clockIn = '1' then --T-flip flop 1
                firstDivider <= not firstDivider;
            end if;
        end process;
        clockOut <= firstDivider;
end Behavioral;
