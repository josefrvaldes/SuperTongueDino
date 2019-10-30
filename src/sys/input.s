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
;; INPUT SYSTEMS
;;
.include "cpctelera.h.s"
.include "man/entity.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "cpct_functions.h.s"
;.include "sys/colisions.h.s"
.include "physics.h.s"
.include "man/game.h.s"
.include "man/sprite.h.s"
.include "man/state.h.s"

.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"
.include "sys/sys_music.h.s"
.include "man/man_invisibility.h.s"

.include "sys/ai_control.h.s"

;; //////////////////
;; SYS_Input Init
sys_input_init::
	ret


;; //////////////////
;; Sys_Input update
;; Input: IX -> pointer to entity[0]
;; Destroy: AF, BC, DE, HL, IX
sys_input_update::
	;; Reset velocities
	ld	a, e_vx(ix)
	dec 	a
	inc	a
	jr	z, no_guardar_VX
	call guardar_VX
no_guardar_VX:

	ld	e_vx(ix), #0
	ld 	e_vy(ix), #0

	call cpct_scanKeyboard_f_asm


	ld	hl, #Joy0_Left		;; JoyStick
	call cpct_isKeyPressed_asm
	jr	nz, O_Pressed
Joy0_Left_NotPressed:

	ld	hl, #Key_O
	call cpct_isKeyPressed_asm
	jr	z, O_NotPressed
O_Pressed:
	call get_hero_jump_right   ;; colisionamos por la derecha
		ld	b, a
		or	a
		jr	z, O_NotPressed   ;; si da 0, estamos haciendo el salto lateral con la jump talbr
			ld	e_vx(ix), #-1
O_NotPressed:


	ld	hl, #Joy0_Right		;; JoyStick
	call cpct_isKeyPressed_asm
	jr	nz, P_Presed
Joy0_Right_NotPressed:

	ld	hl, #Key_P
	call cpct_isKeyPressed_asm
	jr	z, P_NotPressed
P_Presed:
	call get_hero_jump_left   ;; colisionamos por la derecha
		ld	b, a
		or	a
		jr	z, P_NotPressed   ;; si da 0, estamos haciendo el salto lateral con la jump talbr
			ld	e_vx(ix), #1
P_NotPressed:


	ld	hl, #Key_L
	call cpct_isKeyPressed_asm
	jr	z, L_NotPressed
L_Presed:
	; TEMPORAL!! SOLO PARA COMPROBAR QUE FUNCIONA EL CAMBIO DE NIVEL
      call man_level_load_next
      call man_tilemap_load
      call man_tilemap_render
      call man_level_render
      call setDificultadEnemigos
      ; FIN TEMPORAL
L_NotPressed:

;	ld 	e_ai_aim_x(ix), #0		;; comprueba si se ha pulsado el espacio para cambiar la IA
;	ld	hl, #Key_Space
;	call cpct_isKeyPressed_asm
;	jr	z, Space_NotPressed
;Space_Pressed:
;	ld 	e_ai_aim_x(ix), #1
;Space_NotPressed:


	ld	hl, #Joy0_Fire1		;; JoyStick
	call cpct_isKeyPressed_asm
	jr	nz, Q_Pressed
Joy0_Fire1_NotPressed:

	ld	hl, #Key_Q
	call cpct_isKeyPressed_asm
	jr	z, Q_NotPressed
Q_Pressed:

	ld 	a, (ent_input_Q_pressed)  ;; se comprueba si estaba pulsada anteriormente
	dec	a
	jr	z, jumping

	call start_jump
	;call sys_music_sonar_Salto
	

	ld	a, #1
	ld	(ent_input_Q_pressed), a
	jr	jumping
Q_NotPressed:
	call not_jump
	ld	a, #0
	ld	(ent_input_Q_pressed), a
jumping:




	ld	hl, #Key_Esc
	call cpct_isKeyPressed_asm
	jr	z, ESC_NotPressed
ESC_Pressed:
	ld 	a, (ent_input_ESC_pressed)  ;; se comprueba si estaba pulsada anteriormente
	dec	a
	jr	z, ESC_Holded_OrPressed

	call abrir_cerrar_menuIngame

	ld	a, #1
	ld	(ent_input_ESC_pressed), a
	jr	ESC_Holded_OrPressed
ESC_NotPressed:
	ld	a, #0
	ld	(ent_input_ESC_pressed), a
ESC_Holded_OrPressed:




	ld	hl, #Joy0_Fire2		;; JoyStick
	call cpct_isKeyPressed_asm
	jr	nz, A_Pressed
Joy0_Fire2_NotPressed:

	ld	hl, #Key_A
	call cpct_isKeyPressed_asm
	jr	z, A_NotPressed
A_Pressed:
	ld 	a, (ent_input_A_pressed)  ;; se comprueba si estaba pulsada anteriormente
	dec	a
	jr	z, A_Holded_OrPressed

	;; Para activar la invisibilidad ponemos a 1 el parametro de la entidad
	ld  a, (cargadorInvisibilidad)
    	cp  #1
    	jr  nz, invisibilidad_yaUsada          ; en caso de haberse usado no se puede volver a pulsar
    	ld  	a,  #1
    	ld  	e_invisi(ix), a
    	invisibilidad_yaUsada:

	ld	(ent_input_A_pressed), a
	jr	A_Holded_OrPressed
A_NotPressed:
	ld	a, #0
	ld	(ent_input_A_pressed), a
A_Holded_OrPressed:





	ld	hl, #Key_M
	call cpct_isKeyPressed_asm
	jr	z, M_NotPressed
M_Pressed:
	ld 	a, (ent_input_M_pressed)  ;; se comprueba si estaba pulsada anteriormente
	dec	a
	jr	z, M_Holded_OrPressed

	call sys_music_pausarReanudarMusica

	ld  	a,  #1
	ld	(ent_input_M_pressed), a
	jr	M_Holded_OrPressed
M_NotPressed:
	ld	a, #0
	ld	(ent_input_M_pressed), a
M_Holded_OrPressed:



;	ld	hl, #Key_W
;	call cpct_isKeyPressed_asm
;	jr	z, W_NotPressed
;W_Pressed:
;
;			ld	e_vy(ix), #-1
;W_NotPressed:
;
;	ld	hl, #Key_S
;	call cpct_isKeyPressed_asm
;	jr	z, S_NotPressed
;S_Presed:
;			ld	e_vy(ix), #1
;S_NotPressed:


;; COMPROBCION DE LAS MUERTES DE LOS ENEMIGOS
;	ld	hl, #Key_D
;	call cpct_isKeyPressed_asm
;	jr	z, D_NotPressed
;D_Pressed:

;	   	ld bc, #sizeof_e
;   		add   ix, bc

;			ld	a, #1
;			ld	e_dead(ix), a


;	   	ld bc, #sizeof_e
;   		add   ix, bc

;			ld	a, #1
;			ld	e_dead(ix), a

;D_NotPressed:




	ret
