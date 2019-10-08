;;
;; GESTOR ESTADOS
;;
.include "man/game.h.s"
.include "man/mainMenu.h.s"



estado: .db #0
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
	jr z, entrar_menu_init
	dec a
	jr z, entrar_juego_init	
	;call finJuego_init
	ret
entrar_menu_init:
	call man_mainMenu_init
	ret
entrar_juego_init:
	call man_game_init

	ret





man_state_update::
	ld a, (#estado)
	or a
	jr z, entrar_menu_update
	dec a
	jr z, entrar_juego_update	
	;call finJuego_update
	ret
entrar_menu_update:
	call man_mainMenu_update
	ret
entrar_juego_update:
	call man_game_update
	
	ret







man_state_render::
	ld a, (#estado)
	or a
	jr z, entrar_menu_render
	dec a
	jr z, entrar_juego_render	
	;call finJuego_render
	jr final_state_render
entrar_menu_render:
	call man_mainMenu_render
	jr final_state_render
entrar_juego_render:
	call man_game_render
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
	call man_game_init 
	jr no_hayCambioEstado
cambio_a_mainMenu:
	call man_mainMenu_init 
	jr no_hayCambioEstado
no_hayCambioEstado:

	ret