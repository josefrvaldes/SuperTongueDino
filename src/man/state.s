;;
;; GESTOR ESTADOS
;;
.include "man/game.h.s"
.include "man/mainMenu.h.s"
.include "man/man_deadAnimation.h.s"


ent_input_M_pressed:: .db 0
ent_input_Q_pressed:: .db 0
ent_input_A_pressed:: .db 0
ent_input_ESC_pressed:: .db 0



estado: .db #0   ; 1 -> Game,  0 -> main menu, 2 -> muerte guinyo
estado_anterior: .db #0




;; ///////////////////
;; Entra: A -> valor del estado
;; 
man_state_setEstado::
	ld	(#estado_anterior), a
	ret





man_state_init::
	
	ld a, (#estado)
	or a
	jr z, entrar_menu_init  ;; en caso de ser 0
	dec a
	jr z, entrar_juego_init	 ;; en caso de ser 1
	dec a
	jr z, entrar_deadAnimation_init  ;; en caso de ser 2
	;call finJuego_init -> en caso de ser 3
	ret

entrar_menu_init:
	call man_mainMenu_init
	ret
entrar_juego_init:
	call man_game_init
	ret
entrar_deadAnimation_init:
	call man_deadAnimation_init


	ret





man_state_update::
	ld a, (#estado)
	or a
	jr z, entrar_menu_update
	dec a
	jr z, entrar_juego_update
	dec a
	jr z, entrar_deadAnimation_update  ;; en caso de ser 2	
	;call finJuego_update
	ret
entrar_menu_update:
	call man_mainMenu_update
	ret
entrar_juego_update:
	call man_game_update
	ret
entrar_deadAnimation_update:
	call man_deadAnimation_update
	
	ret







man_state_render::
	ld a, (#estado)
	or a
	jr z, entrar_menu_render
	dec a
	jr z, entrar_juego_render
	dec a
	jr z, entrar_deadAnimation_render  ;; en caso de ser 2		
	;call finJuego_render
	jr final_state_render
entrar_menu_render:
	call man_mainMenu_render
	jr final_state_render
entrar_juego_render:
	call man_game_render
	jr final_state_render
entrar_deadAnimation_render:
	call man_deadAnimation_render
	jr final_state_render
final_state_render:

	call administrarEstados
	ret




; ///////////////
;; DESTRUYE: A,  B
;; cambia el estado finalmente y llama a los init
administrarEstados:
	ld	a, (#estado)
	ld 	b, a
	ld 	a, (#estado_anterior)
	cp	b				;; comprueba si ha habido cambio de estado
	jr	z, no_hayCambioEstado

	ld	(#estado), a
	or a
	jr z, cambio_a_mainMenu
	dec a
	jr z, cambio_a_game
	dec a
	jr z, cambio_a_deadAnimation  ;; en caso de ser 2		
	;call finJuego_render
	jr no_hayCambioEstado

cambio_a_mainMenu:
	call man_mainMenu_init 
	ret
cambio_a_game:
	call man_game_init
	ret
cambio_a_deadAnimation:
	call man_deadAnimation_init
	ret
no_hayCambioEstado:

	ret