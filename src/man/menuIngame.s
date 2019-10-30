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
;; MENU INGAME
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/game.h.s"
.include "sys/render.h.s"
.include "sys/sys_music.h.s"
.include "man/state.h.s"
.include "sys/sys_deathCounter.h.s"

.globl _menu_ingame_pack_end
;//////////// INTI
; Elimina: HL, DE, BC, IY
menuIngame_init::
   ;call sys_eren_clearScreen


   ;call sys_eren_init  ;; va a dibujar el mapa, CORREGIR!!!
   ld hl, #_menu_ingame_pack_end
   ld de, #0xFFFF
   call cpct_zx7b_decrunch_s_asm

   ld a, #1
   ld (ent_input_ESC_pressed), a   ;; se utiliza para evitar que al abrir el menu se vaya al menu principal al tener pulsada la tecla
   ld (ent_input_Q_pressed), a   ;; se utiliza para evitar que al abrir el menu se vaya al menu principal al tener pulsada la tecla


    ;call sys_music_pausarReanudarMusica
    call sys_music_pausarReanudarMusica_abirMenuIngame
    ;; PINTAR MUERTES
    call sys_print_death_menuIngame

   ret



	
menuIngame_update::
   ret



menuIngame_render::
   ret



;///// INPUT /////////
; Elimina: HL, A
menuIngame_input::
   call cpct_scanKeyboard_f_asm


   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   jr z, ESC_NotPressed_menuIngame
ESC_Pressed_menuIngame:
   ld    a, (ent_input_ESC_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, ESC_Holded_OrPressed_menuIngame

   call abrir_cerrar_menuIngame
	call sys_music_pausarReanudarMusica_cerrarMenuIngame

   ld a, #1
   ld (ent_input_ESC_pressed), a
   jr fin_mainMenu_Input
ESC_NotPressed_menuIngame:
   ld a, #0
   ld (ent_input_ESC_pressed), a
ESC_Holded_OrPressed_menuIngame:


   ld hl, #Joy0_Fire2      ;; JoyStick
   call cpct_isKeyPressed_asm
   jr nz, Q_Pressed_menuIngame
Joy0_Fire2_NotPressed_menuIngame:

   ld hl, #Key_Q
   call cpct_isKeyPressed_asm
   jr z, Q_NotPressed_menuIngame
Q_Pressed_menuIngame:
   ld    a, (ent_input_Q_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, Q_Holded_OrPressed_menuIngame

   ld a, #0
   call man_state_setEstado
   call man_game_cerrarMenuIngame ;; modificar
	call sys_music_pausarReanudarMusica_cerrarMenuIngame

   ld a, #1
   ld (ent_input_Q_pressed), a
   jr fin_mainMenu_Input
Q_NotPressed_menuIngame:
   ld a, #0
   ld (ent_input_Q_pressed), a
Q_Holded_OrPressed_menuIngame:




fin_mainMenu_Input:
   ret