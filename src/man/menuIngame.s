;;
;; MENU INGAME
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/game.h.s"
.include "sys/render.h.s"
.include "man/state.h.s"

string_menuIngame_info: .asciz "Estamos en el menu"
string_menuIngame_continuar: .asciz "C para continuar"
string_menuIngame_salir: .asciz "ESC para salir"


;//////////// INTI
; Elimina: HL, DE, BC, IY
menuIngame_init::
	call sys_eren_clearScreen

	;; Set up draw char colours before calling draw string ;; Pone colores de fondo y letra
	ld    l, #3         ;; D = Background PEN (0)
	ld    h, #0         ;; E = Foreground PEN (3)
	call cpct_setDrawCharM0_asm   ;; Set draw char colours


	;////////// Texto 1 ////////////////
	;; Calculate a video-memory location for printing a string
	ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
	ld    b, #24                  ;; B = y coordinate (24 = 0x18)
	ld    c, #2                  ;; C = x coordinate (16 = 0x10)
	call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

	;; Print the string in video memory
	;; HL already points to video memory, as it is the return
	;; value from cpct_getScreenPtr_asm
	ld   IY, #string_menuIngame_info    ;; IY = Pointer to the string 
	call cpct_drawStringM0_asm  ;; Draw the string


	;////////// Texto 2 ////////////////
	;; Calculate a video-memory location for printing a string
	ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
	ld    b, #48                 ;; B = y coordinate (24 = 0x18)
	ld    c, #2                  ;; C = x coordinate (16 = 0x10)
	call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

	;; Print the string in video memory
	;; HL already points to video memory, as it is the return
	;; value from cpct_getScreenPtr_asm
	ld   IY, #string_menuIngame_continuar    ;; IY = Pointer to the string 
	call cpct_drawStringM0_asm  ;; Draw the string


	;////////// Texto 3 ////////////////
	;; Calculate a video-memory location for printing a string
	ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
	ld    b, #72                  ;; B = y coordinate (24 = 0x18)
	ld    c, #2                  ;; C = x coordinate (16 = 0x10)
	call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

	;; Print the string in video memory
	;; HL already points to video memory, as it is the return
	;; value from cpct_getScreenPtr_asm
	ld   IY, #string_menuIngame_salir    ;; IY = Pointer to the string 
	call cpct_drawStringM0_asm  ;; Draw the string

	ret



menuIngame_update::
	ret



menuIngame_render::
	ret



;///// INPUT /////////
; Elimina: HL, A
menuIngame_input::
	call cpct_scanKeyboard_f_asm

	ld	hl, #Key_C
	call cpct_isKeyPressed_asm
	jr	z, C_NotPressed_menuIngame
C_Pressed_menuIngame:
	call abrir_cerrar_menuIngame
	jr fin_mainMenu_Input
C_NotPressed_menuIngame:

	ld	hl, #Key_Esc
	call cpct_isKeyPressed_asm
	jr	z, Esc_NotPressed_menuIngame
Esc_Pressed_menuIngame:
	ld a, #0
	call man_state_setEstado
	call man_game_cerrarMenuIngame ;; modificar
Esc_NotPressed_menuIngame:

fin_mainMenu_Input:
	ret