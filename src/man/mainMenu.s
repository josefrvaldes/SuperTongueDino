;;
;; MENU PRINCIPAL
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sys/render.h.s"
.include "man/state.h.s"
.include "man/man_level.h.s"
.include "sys/sys_music.h.s"
.include "man/entity.h.s"

.globl _hero_pal
.globl _menu_principal_pack_end
;string_menuIngame_info: .asciz "MAIN MENU"
;string_menuIngame_jugar: .asciz "Press Q to play"


;//////////// INTI
; Elimina: HL, DE, BC, IY
man_mainMenu_init::
   ld c, #0
   call cpct_setVideoMode_asm
   ld hl, #_hero_pal
   ld de, #16
   call cpct_setPalette_asm
   ;cpctm_setBorder_asm HW_WHITE
   
   ;call sys_eren_init  ;; va a dibujar el mapa, CORREGIR!!!
   ld hl, #_menu_principal_pack_end
   ld de, #0xFFFF
   call cpct_zx7b_decrunch_s_asm
      
   ld a, #1
   ld (ent_input_Q_pressed), a   ;; se utiliza para evitar que al iniciar el juego se entre al juego al tener pulsada la tecla y no se vea el menu


   ld    hl, #0
   ld    (deathsPlayer), hl

   ld a, #0
   ld (num_current_level), a

   ld iy, (memory_firstLevel)
   ld  (iy_current_level), iy

   ld a, #cancion1
	call sys_music_ponerMusica ;; Inicializar una cancion
   ret




man_mainMenu_update::
   call mainMenu_input
   ret



man_mainMenu_render::
   ret



; Elimina: HL, A
mainMenu_input:
   call cpct_scanKeyboard_f_asm

   ld hl, #Joy0_Fire1
   call cpct_isKeyPressed_asm
   jr nz, Q_Pressed_mainMenu
Joy0_Fire1_NotPressed_mainMenu:

   ld hl, #Key_Q
   call cpct_isKeyPressed_asm
   jr z, Q_NotPressed_mainMenu
Q_Pressed_mainMenu:
   ld    a, (ent_input_Q_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, Q_Holded_OrPressed_mainMenu

   ld a, #1
   call man_state_setEstado  ;; cambia el estado
   ld a, #cancion2
   call sys_music_ponerMusica ;; Inicializar una cancion

   ld (ent_input_Q_pressed), a
   jr Q_Holded_OrPressed_mainMenu
Q_NotPressed_mainMenu:
   ld a, #0
   ld (ent_input_Q_pressed), a
Q_Holded_OrPressed_mainMenu:




   ld hl, #Key_M
   call cpct_isKeyPressed_asm
   jr z, M_NotPressed_mainMenu
M_Pressed_mainMenu:
   ld    a, (ent_input_M_pressed)  ;; se comprueba si estaba pulsada anteriormente
   dec   a
   jr z, M_Holded_OrPressed_mainMenu

   call sys_music_pausarReanudarMusica

   ld    a,  #1
   ld (ent_input_M_pressed), a
   jr M_Holded_OrPressed_mainMenu
M_NotPressed_mainMenu:
   ld a, #0
   ld (ent_input_M_pressed), a
M_Holded_OrPressed_mainMenu:


   ret