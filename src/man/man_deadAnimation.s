;;
;; MENU PRINCIPAL
;;
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sys/render.h.s"
.include "man/state.h.s"
.include "man/game.h.s"
.include "man/entity.h.s"
.include "ent/entity.h.s"
.include "man/man_level.h.s"

.globl _hero_sp_1
.globl _planta_sp_0
.globl _planta_sp_1
.globl _planta_sp_2
.globl _tierraPlanta_sp

string_frase1: .asciz "DOWN YOU GO!"
string_frase2: .asciz "MMMMMMMHHH!!"

easterEgg: .db #0
endAnimation: .db #0
cont_Animation: .db #0
animationPlantScene: .db #0

man_deadAnimation_maxHeight = 52
initialHeight: .db #0
initialPositionY: .db #137


spritePtrPlanta: .dw _planta_sp_0
spritePtrTierraPlanta: .dw _tierraPlanta_sp

;;//////////////////////////
;; deadAnimation INIT
;; Destroy: A
man_deadAnimation_init::
	ld	a, #0
	ld	(easterEgg), a 
	ld	(endAnimation), a
	ld	(animationPlantScene), a 
	ld	(cont_Animation), a 
	ld	(initialHeight), a
	ld	a, #1
	ld	(ent_input_ESC_pressed), a
	ld	a, #137
	ld	(initialPositionY), a  

	

	call man_entity_getArray
	ld	hl, #_hero_sp_1
	ld	e_pspr_l(ix), l
	ld	e_pspr_h(ix), h


	ld	a, (num_current_level)
	cp	#10
	jr	z, yes_easterEgg
	cp	#15
	jr	z, yes_easterEgg
	cp	#20
	jr	nz, no_easterEgg
yes_easterEgg:					;; en caso de ser un nivel concreto se produce el easterEgg
	call man_deadAnimation_initEGG
no_easterEgg:
	
	ret


;;//////////////////////////
;; deadAnimation UPDATE
;; Destroy: A
man_deadAnimation_update::
	ld	a, (easterEgg)
	dec	a
	jr	nz, saltarEasterEgg
	call man_deadAnimation_EGG
	jr 	man_deadAnimation_continue
saltarEasterEgg:
	call man_deadAnimation_NoEGG

man_deadAnimation_continue:
	call man_deadAnimation_input ;; !Temporal

	ld	a, (endAnimation)
	dec	a
	ret	nz
	;; en acabar reiniciar el nivel cambiando de estado
	ld a, #1
	call man_state_setEstado

	ret



;;//////////////////////////
;; deadAnimation RENDER
;; Destroy: AF, DE, BC, IY
man_deadAnimation_render::
	ld	a, (easterEgg)
	dec	a
	jr	z, EasterEgg_render
	; algo
	jr 	NoEasterEgg_render
EasterEgg_render:
	;; DIBUJAE PLANTA
	ld  	iy, #spritePtrPlanta
	ld	a, (initialPositionY)
	ld	b, a
	ld	a, (initialHeight)
      call sys_eren_drawPlant


      ;; DIBUJAR TIERRA PLANTA
	ld  	iy, #spritePtrTierraPlanta
	call sys_eren_DrawDirtOfPlant


      ld	a, (animationPlantScene)
      cp	#2
      ret	z
      ;; DIBUJAR ENTIDADES
      call man_entity_getArray
      ld	a, #1
	call sys_eren_update ;; pinta tambien los enemigos

NoEasterEgg_render:
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

	ld a, #1
	call man_state_setEstado

	ld	a, #1
	ld	(ent_input_ESC_pressed), a
	ret
Esc_NotPressed_deadA:
	ld	a, #0
	ld	(ent_input_ESC_pressed), a
ESC_Holded_OrPressed_deadA:

	ret





;; Destroy: AF, IX
man_deadAnimation_initEGG:
	call sys_eren_clearScreen	
	call dibujar_Frase1

	ld	a, #1
	ld	(easterEgg), a

	ld 	hl, #_planta_sp_0
	ld 	iy, #spritePtrPlanta
	ld	0(iy), l
	ld	1(iy), h
	;; mover el personaje a una posicion determinada
	call man_entity_getArray
	ld	e_x(ix), #38
	ld	e_y(ix), #90

	ld  iy, #spritePtrPlanta

	ret





;; animacion
man_deadAnimation_EGG:
	ld	a, (animationPlantScene)
	cp	#0
	jr	nz, tryScene1
	call animationScene0
	ret

	tryScene1:
	ld	a, (animationPlantScene)
	cp	#1
	jr	nz, tryScene2
	call animationScene1
	ret
	tryScene2:
	call animationScene2
	ret



man_deadAnimation_NoEGG:
	ld	a, #1
	ld	(endAnimation), a

	;; descontar vidas
	
	ret



animationScene0:
	ld	a, (initialHeight)
	cp	#52
	jr	z, cambiarEscena1
	inc 	a
	ld	(initialHeight), a
	ld	a, (initialPositionY)
	dec 	a
	ld	(initialPositionY), a
	ret

cambiarEscena1:	;; Sale la planta
	ld	hl, #_planta_sp_1
	ld 	iy, #spritePtrPlanta
	ld	0(iy), l
	ld	1(iy), h	

	ld	a, #1
	ld	(animationPlantScene), a 
	ret



animationScene1:	;; Muerde la planta
	ld 	a, (cont_Animation)
	cp	#5
	jr	z, cambiarEscena2
	inc 	a
	ld 	(cont_Animation), a
	ret

	cambiarEscena2:
	ld	hl, #_planta_sp_2
	ld 	iy, #spritePtrPlanta
	ld	0(iy), l
	ld	1(iy), h	

	ld	a, #2
	ld	(animationPlantScene), a 

	call dibujar_Frase2
	ret


animationScene2:	;; Se esconde la planta
	ld	a, (initialHeight)
	cp	#2
	jr	z, finScene2
	dec 	a
	ld	(initialHeight), a
	ld	a, (initialPositionY)
	inc 	a
	ld	(initialPositionY), a
	ret

	finScene2:	;; Permite el cambio de estado
	ld	a, #1
	ld	(endAnimation), a

	ret




dibujar_Frase1:
	ld 	h, #0		
	ld 	l, #2		
	call _mySetDrawCharM0

	ld   	de, #0xC000 		;; DE = Pointer to start of the screen
	ld    b, #160                	;; B = y coordinate 
	ld    c, #18                	;; C = x coordinate
	call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL

	ld   	iy, #string_frase1   	;; IY = Pointer to the string 
	call _myDrawStringM0

	ret


dibujar_Frase2:
	ld 	h, #0		
	ld 	l, #2		
	call _mySetDrawCharM0

	ld	de, #0xC000 
	ld    b, #160                
	ld    c, #18                  
	call cpct_getScreenPtr_asm   

	ld   	iy, #string_frase2    
	call _myDrawStringM0
	ret