;;
;; MENU PRINCIPAL
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sys/render.h.s"
.include "man/state.h.s"



man_deadAnimation_init::
	call sys_eren_clearScreen
	
	ld	a, #1
	ld	(ent_input_ESC_pressed), a   
	ret



man_deadAnimation_update::
	call man_deadAnimation_input
	ret



man_deadAnimation_render::
	ret





man_deadAnimation_input:
	call cpct_scanKeyboard_f_asm

	ld	hl, #Key_Esc
	call cpct_isKeyPressed_asm
	jr	z, Esc_NotPressed_deadA
Esc_Pressed_deadA:
	ld 	a, (ent_input_ESC_pressed)  ;; se comprueba si estaba pulsada anteriormente
	dec	a
	jr	z, ESC_Holded_OrPressed_deadA

	ld a, #0
	call man_state_setEstado

	ld	a, #1
	ld	(ent_input_ESC_pressed), a
	ret
Esc_NotPressed_deadA:
	ld	a, #0
	ld	(ent_input_ESC_pressed), a
ESC_Holded_OrPressed_deadA:

	ret