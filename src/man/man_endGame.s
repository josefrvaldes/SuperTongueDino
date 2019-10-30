;;----------------------------------LICENSE NOTICE-----------------------------------------------------
;;    Super Tongue Dino is a challenging platform game
;;    Copyright (C) 2019  Carlos de la Fuente / Jose Martinez / Jose Francisco Valdes / (@clover_gs)
;;
;;    This program is free software: you can redistribute it and/or modify
;;    it under the terms of the GNU General Public License as published by
;;    the Free Software Foundation, either version 3 of the License, or
;;    (at your option) any later version.
;;
;;    This program is distributed in the hope that it will be useful,
;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;    GNU General Public License for more details.
;;
;;    You should have received a copy of the GNU General Public License
;;    along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;------------------------------------------------------------------------------------------------------


;;
;; MENU END GAME
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/game.h.s"
.include "sys/render.h.s"
.include "sys/sys_music.h.s"
.include "man/state.h.s"
.include "sys/sys_deathCounter.h.s"

.globl _menu_you_win_pack_end
;//////////// INTI
; Elimina: HL, DE, BC, IY
man_endGame_init::
   ;call sys_eren_clearScreen
   ld hl, #_menu_you_win_pack_end
   ld de, #0xFFFF
   call cpct_zx7b_decrunch_s_asm

   ld a, #1
   ld (ent_input_Q_pressed), a   ;; se utiliza para evitar que al abrir el menu se vaya al menu principal al tener pulsada la tecla

   ;call sys_music_pausarReanudarMusica
   call sys_print_death_endGame
   call sys_music_sonar_gameComplete
   ret



	
man_endGame_update::
   call man_endGame_input
   ret



man_endGame_render::
   ret



;///// INPUT /////////
; Elimina: HL, A
man_endGame_input::
   call cpct_scanKeyboard_f_asm

   ld hl, #Joy0_Fire1
   call cpct_isKeyPressed_asm
   jr nz, Q_Pressed_endGame
Joy0_Fire1_NotPressed_endGame:

   ld hl, #Key_Q
   call cpct_isKeyPressed_asm
   jr z, Q_NotPressed_endGame
Q_Pressed_endGame:
   ld    a, (ent_input_Q_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, Q_Holded_OrPressed_endGame

   ld a, #0
   call man_state_setEstado ; salir menu principal
   ;call sys_music_pausarReanudarMusica

   ld (ent_input_Q_pressed), a
   jr Q_Holded_OrPressed_endGame
Q_NotPressed_endGame:
   ld a, #0
   ld (ent_input_Q_pressed), a
Q_Holded_OrPressed_endGame:






   ld hl, #Key_M
   call cpct_isKeyPressed_asm
   jr z, M_NotPressed_endGame
M_Pressed_endGame:
   ld    a, (ent_input_M_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, M_Holded_OrPressed_endGame

   call sys_music_pausarReanudarMusica

   ld    a,  #1
   ld (ent_input_M_pressed), a
   jr M_Holded_OrPressed_endGame
M_NotPressed_endGame:
   ld a, #0
   ld (ent_input_M_pressed), a
M_Holded_OrPressed_endGame:
   ret