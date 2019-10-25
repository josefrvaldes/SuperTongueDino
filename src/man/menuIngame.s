;;
;; MENU INGAME
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/game.h.s"
.include "sys/render.h.s"
.include "sys/sys_music.h.s"
.include "man/state.h.s"

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

    call sys_music_pausarReanudarMusica
   ret



	
menuIngame_update::
   ret



menuIngame_render::
   ret



;///// INPUT /////////
; Elimina: HL, A
menuIngame_input::
   call cpct_scanKeyboard_f_asm


   ld hl, #Key_M
   call cpct_isKeyPressed_asm
   jr z, M_NotPressed_menuIngame
M_Pressed_menuIngame:
   ld    a, (ent_input_M_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, M_Holded_OrPressed_menuIngame

   call abrir_cerrar_menuIngame
	call sys_music_pausarReanudarMusica

   ld a, #1
   ld (ent_input_M_pressed), a
   jr fin_mainMenu_Input
M_NotPressed_menuIngame:
   ld a, #0
   ld (ent_input_M_pressed), a
M_Holded_OrPressed_menuIngame:


   ld hl, #Joy0_Fire2      ;; JoyStick
   call cpct_isKeyPressed_asm
   jr nz, Esc_Pressed_menuIngame
Joy0_Fire2_NotPressed_menuIngame:

   ld hl, #Key_Esc
   call cpct_isKeyPressed_asm
   jr z, Esc_NotPressed_menuIngame
Esc_Pressed_menuIngame:
   ld    a, (ent_input_ESC_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, ESC_Holded_OrPressed_menuIngame

   ld a, #0
   call man_state_setEstado
   call man_game_cerrarMenuIngame ;; modificar
	call sys_music_pausarReanudarMusica

   ld a, #1
   ld (ent_input_ESC_pressed), a
   jr fin_mainMenu_Input
Esc_NotPressed_menuIngame:
   ld a, #0
   ld (ent_input_ESC_pressed), a
ESC_Holded_OrPressed_menuIngame:




fin_mainMenu_Input:
   ret