---------------------------------------------------------------------------------- 
-- Autor: Juan Manuel Portillo López
-- Nombre de Proyecto: Ping-Pong
-- Descripción: Este es un módulo para calcular y devolver la posición de la pelota según
-- 		a las entradas que se le dan (posiciones de las paletas). El módulo interactúa
-- 		con el módulo Sync para informarle sobre la posición de las pelotas. También maneja
-- 		la lógica del juego e informa a Sync sobre qué dibujar en la pantalla.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Constants.all;

entity BallController is
  Port (start, move: in std_logic;
        paddleWidth: in integer;
        paddlePos, paddleAIPos: in integer range TOT_H - VIS_H + 1 to TOT_H - PADDLE_WIDTH;
        xPos: out integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE;
        yPos: out integer range TOT_V - VIS_V + 1 to TOT_V;
        newGame, play, AIWon, PlayerWon: out std_logic);
end BallController;

architecture Behavioral of BallController is
--Señales intermedias
signal currentX: integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE:= BALL_INITIAL_X;
signal currentY: integer range TOT_V - VIS_V + 1 to TOT_V:= BALL_INITIAL_Y;
signal playingCurrent: std_logic:= '0';
signal resetCurrent: std_logic:= '1';
signal playerWins, AIWins: std_logic:= '0';	
begin
 process(move)
 variable wallHorizontalBounce, paddleSideBounce, paddleSurfaceBounce, paddleAISideBounce, paddleAISurfaceBounce: boolean := false; --variables que indican colisiones
 variable horizontalVelocity: integer:= -1; -- -1: Izquierda y arriba 1: derecha y abajo
 variable verticalVelocity: integer:= -1; -- -1: izquierda y arriba 1: derecha y abajo
    begin
        if move'event and move = '1' then --Las señales dentro del proceso solo se actualizan en los flancos ascendentes de la señal de movimiento.
            --Condiciones de victoria y derrota
            if currentY <= FP_V + SP_V + BP_V + 1 then
                playerWins <= '1';
            elsif start = '1' then
                playerWins <= '0';
            end if;
            if currentY >= TOT_V then
                AIWins <= '1';
            elsif start = '1' then
                AIWins <= '0';
            end if;
            --Reseteo de Lógica
            if AIWins = '1' or playerWins = '1' then
                currentX <= BALL_INITIAL_X;
                currentY <= BALL_INITIAL_Y;
                playingCurrent <= '0';
                resetCurrent <= '1';
            elsif start = '1' then
                playingCurrent <= '1';
                resetCurrent <= '0';
            end if;
            --Declaraciones de detección de colisiones (busca las intersecciones entre la pelota y los objetos especificados)
            wallHorizontalBounce := currentX <= FP_H + SP_H + BP_H + 1 or currentX >= TOT_H - BALL_SIDE;
            paddleSurfaceBounce := currentY >= TOT_V - PADDLE_HEIGHT - BALL_SIDE and 
                                   currentX >= paddlePos and 
                                   currentX <= paddlePos + paddleWidth - BALL_SIDE;
            paddleSideBounce := ((currentX = paddlePos - 9 or currentX = paddlePos - 8 or currentX = paddlePos + paddleWidth or currentX = paddlePos + paddleWidth - 1)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 10)) or
                                ((currentX = paddlePos - 8 or currentX = paddlePos - 7 or currentX = paddlePos + paddleWidth - 1 or currentX = paddlePos + paddleWidth - 2)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 9)) or
                                ((currentX = paddlePos - 7 or currentX = paddlePos - 6 or currentX = paddlePos + paddleWidth - 2 or currentX = paddlePos + paddleWidth - 3)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 8)) or
                                ((currentX = paddlePos - 6 or currentX = paddlePos - 5 or currentX = paddlePos + paddleWidth - 3 or currentX = paddlePos + paddleWidth - 4)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 7)) or
                                ((currentX = paddlePos - 5 or currentX = paddlePos - 4 or currentX = paddlePos + paddleWidth - 4 or currentX = paddlePos + paddleWidth - 5)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 6)) or
                                ((currentX = paddlePos - 4 or currentX = paddlePos - 3 or currentX = paddlePos + paddleWidth - 5 or currentX = paddlePos + paddleWidth - 6)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 5)) or
                                ((currentX = paddlePos - 3 or currentX = paddlePos - 2 or currentX = paddlePos + paddleWidth - 6 or currentX = paddlePos + paddleWidth - 7)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 4)) or
                                ((currentX = paddlePos - 2 or currentX = paddlePos - 1 or currentX = paddlePos + paddleWidth - 7 or currentX = paddlePos + paddleWidth - 8)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 3)) or
                                ((currentX = paddlePos - 1 or currentX = paddlePos or currentX = paddlePos + paddleWidth - 8 or currentX = paddlePos + paddleWidth - 9)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 2)) or
                                ((currentX = paddlePos or currentX = paddlePos + 1 or currentX = paddlePos + paddleWidth - 9 or currentX = paddlePos + paddleWidth - 10)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 1)) or
                                ((currentX = paddlePos + 1 or currentX = paddlePos + 2 or currentX = paddlePos + paddleWidth - 10 or currentX = paddlePos + paddleWidth - 11)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE));
            paddleAISurfaceBounce := currentY <= FP_V + SP_V + BP_V + PADDLE_HEIGHT and 
                                     currentX >= paddleAIPos and 
                                     currentX <= paddleAIPos + PADDLE_WIDTH - BALL_SIDE;
            paddleAISideBounce := ((currentX = paddleAIPos - 9 or currentX = paddleAIPos - 8 or currentX = paddleAIPos + PADDLE_WIDTH or currentX = paddleAIPos + PADDLE_WIDTH - 1)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 10)) or
                                  ((currentX = paddleAIPos - 8 or currentX = paddleAIPos - 7 or currentX = paddleAIPos + PADDLE_WIDTH - 1 or currentX = paddleAIPos + PADDLE_WIDTH - 2)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 9)) or
                                  ((currentX = paddleAIPos - 7 or currentX = paddleAIPos - 6 or currentX = paddleAIPos + PADDLE_WIDTH - 2 or currentX = paddleAIPos + PADDLE_WIDTH - 3)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 8)) or
                                  ((currentX = paddleAIPos - 6 or currentX = paddleAIPos - 5 or currentX = paddleAIPos + PADDLE_WIDTH - 3 or currentX = paddleAIPos + PADDLE_WIDTH - 4)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 7)) or
                                  ((currentX = paddleAIPos - 5 or currentX = paddleAIPos - 4 or currentX = paddleAIPos + PADDLE_WIDTH - 4 or currentX = paddleAIPos + PADDLE_WIDTH - 5)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 6)) or
                                  ((currentX = paddleAIPos - 4 or currentX = paddleAIPos - 3 or currentX = paddleAIPos + PADDLE_WIDTH - 5 or currentX = paddleAIPos + PADDLE_WIDTH - 6)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 5)) or
                                  ((currentX = paddleAIPos - 3 or currentX = paddleAIPos - 2 or currentX = paddleAIPos + PADDLE_WIDTH - 6 or currentX = paddleAIPos + PADDLE_WIDTH - 7)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 4)) or
                                  ((currentX = paddleAIPos - 2 or currentX = paddleAIPos - 1 or currentX = paddleAIPos + PADDLE_WIDTH - 7 or currentX = paddleAIPos + PADDLE_WIDTH - 8)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 3)) or
                                  ((currentX = paddleAIPos - 1 or currentX = paddleAIPos or currentX = paddleAIPos + PADDLE_WIDTH - 8 or currentX = paddleAIPos + PADDLE_WIDTH - 9)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 2)) or
                                  ((currentX = paddleAIPos or currentX = paddleAIPos + 1 or currentX = paddleAIPos + PADDLE_WIDTH - 9 or currentX = paddleAIPos + PADDLE_WIDTH - 10)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 1)) or
                                  ((currentX = paddleAIPos + 1 or currentX = paddleAIPos + 2 or currentX = paddleAIPos + PADDLE_WIDTH - 10 or currentX = paddleAIPos + PADDLE_WIDTH - 11)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT));
            --Lógica de los siguientes estados para la posición y velocidad de la pelota.                      
            if wallHorizontalBounce or paddleSideBounce then
               horizontalVelocity := - horizontalvelocity;
            elsif playingCurrent = '0' then
               horizontalVelocity := -1; 
            end if;
            if paddleSurfaceBounce or paddleSideBounce or paddleAISurfaceBounce or paddleAISideBounce then
                verticalVelocity :=  - verticalVelocity;
            elsif playingCurrent = '0' then
                verticalVelocity := -1;
            end if;
            if playingCurrent = '1' then
                currentX <= currentX + horizontalVelocity;
                currentY <= currentY + verticalVelocity;
            end if;
        end if;
    end process;
    --Registro para actualizar las señales principales
    xPos <= currentX;
    yPos <= currentY;
    play <= playingCurrent;
    newGame <= resetCurrent;
    AIWon <= AIWins;
    playerWon <= playerWins;
end Behavioral;
