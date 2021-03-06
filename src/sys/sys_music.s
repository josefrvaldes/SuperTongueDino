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


.include "cpctelera.h.s"
.include "cpct_functions.h.s"

.globl _sfx_instrumentos
.globl _song_ingame1
.globl _song_ingame2

contadorVelocidadMusica: .db #12
velocidadMusica:	.db #12			;; suena 1 vez cada 12 interrupciones



; Sonidos sfx
sfx_Salto: .db #0
sfx_explosion: .db #0
sfx_gameComplete: .db #0
sfx_levelComplete: .db #0


pausarMusica: .db #0
pausarMusica_menuAbierto: .db #0
;ArrayCanciones:
;	.dw	#_song_ingame
;
;cancion1 == 0
;cancion2 == 2
;cancion3 == 4
;cancion4 == 6




;; Input: A -> numero cancion
sys_music_ponerMusica::
	call cpct_removeInterruptHandler_asm  ; elimina el interruptor por si hay una cancion antes
	;call cpct_akp_stop_asm

	call	sys_music_selectSong		; Elige la cancion a reproducir
	
	call	sys_music_init_sfx		; Inicializa la cancion para el sfx	

	ld	hl, #isr
	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor

	ret


; Input: A -> numero de la cancion
sys_music_selectSong:
	dec	a
	jr	nz, comprobarCancion2	
	ld	a, #10
	ld	(contadorVelocidadMusica), a
	ld	(velocidadMusica), a 
	ld	de, #_song_ingame1
	call	cpct_akp_musicInit_asm	;; Inicializa la cancion
	jr 	continuarReproduciendo

	comprobarCancion2:
	dec	a
	jr	nz, comprobarCancion3	
	ld	a, #10
	ld	(contadorVelocidadMusica), a
	ld	(velocidadMusica), a 
	ld	de, #_song_ingame2
	call	cpct_akp_musicInit_asm	
	jr 	continuarReproduciendo

	comprobarCancion3:

	continuarReproduciendo:
	ret

; Destroy: DE, HL
;sys_music_init::
;	call sys_music_pararMusica
;	ld 		de, #_song_ingame
;	call	cpct_akp_musicInit_asm	;; Inicializa la cancion
;
;	ld		hl, #isr
;	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor
;	ret



; plays Sound every one time every 12 interruptions
isr:
	ex	af, af'
	exx
	push af
	push bc
	push de
	push hl
	push iy

	ld	a, (contadorVelocidadMusica)
	dec	a
	ld	(contadorVelocidadMusica), a
	jr	nz, return_interrumpir


	ld	a, (pausarMusica)
	dec	a
	jr	z, musicaPausada
	call cpct_akp_musicPlay_asm
	call	detectarSonido_Sfx
	musicaPausada:
	
	

	ld	a, (velocidadMusica)
	ld	(contadorVelocidadMusica), a

	return_interrumpir:
	pop iy
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex	af, af'

	ret



; pausa y reanuda la musica
sys_music_pausarReanudarMusica::
	ld	a, (pausarMusica)
	dec	a
	jr	nz, pausarLaMusica
	ld	a, #0
	ld	(sfx_Salto), a
	ld	(sfx_explosion), a
	ld	(sfx_levelComplete), a
	ld	(sfx_gameComplete), a
	ld	(pausarMusica), a
	ret
	pausarLaMusica:
	ld	a, #1
	ld	(pausarMusica), a

	ex	af, af'
	push af
	push bc
	push de
	push hl
	push iy
	push ix
	call cpct_akp_stop_asm
	pop ix
	pop iy
	pop hl
	pop de
	pop bc
	pop af
	ex	af, af'

	ret




sys_music_pausarReanudarMusica_abirMenuIngame::
	ld	a, (pausarMusica)
	cp	#1
	jr	z, continuar_abirMenuIngame
	call sys_music_pausarReanudarMusica
	ret

	continuar_abirMenuIngame:
	ld	a, #1
	ld	(pausarMusica_menuAbierto), a
	ret


sys_music_pausarReanudarMusica_cerrarMenuIngame::
	ld	a, (pausarMusica_menuAbierto)
	cp	#1
	jr	z, continuar_cerrarMenuIngame
	call sys_music_pausarReanudarMusica
	ret

	continuar_cerrarMenuIngame:
	ld	a, #0
	ld	(pausarMusica_menuAbierto), a
	ret




; para el interruptor por lo que no se escucha ningun sonido
sys_music_detenerSonidos::
	call cpct_removeInterruptHandler_asm

	ex	af, af'
	push af
	push bc
	push de
	push hl
	push iy
	push ix
	call cpct_akp_stop_asm
	pop ix
	pop iy
	pop hl
	pop de
	pop bc
	pop af
	ex	af, af'

	ret


;; Cancion con la que se realicen los efectos de sonido
sys_music_init_sfx:
	push 	de
	ld	de, #_sfx_instrumentos			;; solo coge la cancion con el conjunto de instrumentos, las notas se hacen luego
	call cpct_akp_SFXInit_asm
	pop 	de
	ret



; Destruye: A
sys_music_sonar_Salto::
	ld	a, #1
	ld	(sfx_Salto), a
	ret

; Destruye: A
sys_music_sonar_Explosion::
	ld	a, #1
	ld	(sfx_explosion), a
	ret

; Destruye: A
sys_music_sonar_levelComplete::
	ld	a, #1
	ld	(sfx_levelComplete), a
	ret

; Destruye: A
sys_music_sonar_gameComplete::
	ld	a, #1
	ld	(sfx_gameComplete), a
	ret





; Destruye: AF, BC, DE, HL
detectarSonido_Sfx:
	ld	a, (sfx_Salto)
	cp	#1
	jr	nz, try_explotar1_sfx

	ld	l, #01				; sfx_num		 Number of the instrument in the SFX Song (>0), same as the number given to the instrument in Arkos Tracker.
	ld	h, #12				; volume		 Volume [0-15], 0 = off, 15 = maximum volume.
	ld	e, #40				; note		 Note to be played with the given instrument [0-143]
	ld	d, #0					; speed		 Speed (0 = As original, [1-255] = new Speed (1 is fastest))
	ld	bc, #0			; inverted_pitch	 Inverted Pitch (-0xFFFF -> 0xFFFF).  0 is no pitch.  The higher the pitch, the lower the sound.
	ld	a, #0x04  ; -> binario 010    ; channel_bitmask	 Bitmask representing channels to use for reproducing the sound (Ch.A = 001 (1), Ch.B = 010 (2), Ch.C = 100 (4))
	call cpct_akp_SFXPlay_asm
	ld	a, #0
	ld	(sfx_Salto), a
	jr 	return_salir_sfx



	try_explotar1_sfx:
	ld	a, (sfx_explosion)
	cp	#1
	jr	nz, try_explotar2_sfx

	ld	l, #07					; sfx_num		 Number of the instrument in the SFX Song (>0), same as the number given to the instrument in Arkos Tracker.
	ld	h, #14				; volume		 Volume [0-15], 0 = off, 15 = maximum volume.
	ld	e, #24				; note		 Note to be played with the given instrument [0-143]
	ld	d, #0					; speed		 Speed (0 = As original, [1-255] = new Speed (1 is fastest))
	ld	bc, #0				; inverted_pitch	 Inverted Pitch (-0xFFFF -> 0xFFFF).  0 is no pitch.  The higher the pitch, the lower the sound.
	ld	a, #0x04  ; -> binario 010    ; channel_bitmask	 Bitmask representing channels to use for reproducing the sound (Ch.A = 001 (1), Ch.B = 010 (2), Ch.C = 100 (4))
	call cpct_akp_SFXPlay_asm
	ld	a, #2
	ld	(sfx_explosion), a
	jr 	return_salir_sfx

	try_explotar2_sfx:
	ld	a, (sfx_explosion)
	cp	#2
	jr	nz, return_salir_sfx

	ld	l, #1				
	ld	h, #14					
	ld	e, #12				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #0
	ld	(sfx_explosion), a
	jr 	return_salir_sfx


	return_salir_sfx:
	call sonido_levelComplete
	call sonido_endGame

	ret






;////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////
; sonidos al completar un nivel
sonido_levelComplete:
	ld	a, (sfx_levelComplete)
	cp	#0
	ret	z

	ld	a, (sfx_levelComplete)
	cp	#1
	jr	nz, try_levelComplete2_sfx

	ld	l, #06				; sfx_num		 Number of the instrument in the SFX Song (>0), same as the number given to the instrument in Arkos Tracker.
	ld	h, #10				; volume		 Volume [0-15], 0 = off, 15 = maximum volume.
	ld	e, #61				; note		 Note to be played with the given instrument [0-143]
	ld	d, #0					; speed		 Speed (0 = As original, [1-255] = new Speed (1 is fastest))
	ld	bc, #0				; inverted_pitch	 Inverted Pitch (-0xFFFF -> 0xFFFF).  0 is no pitch.  The higher the pitch, the lower the sound.
	ld	a, #0x04  ; -> binario 010    ; channel_bitmask	 Bitmask representing channels to use for reproducing the sound (Ch.A = 001 (1), Ch.B = 010 (2), Ch.C = 100 (4))
	call cpct_akp_SFXPlay_asm
	ld	a, #2
	ld	(sfx_levelComplete), a
	ret

	try_levelComplete2_sfx:
	ld	a, (sfx_levelComplete)
	cp	#5
	jr	nz, try_levelComplete3_sfx

	ld	l, #06			
	ld	h, #10				
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #6
	ld	(sfx_levelComplete), a
	ret

	try_levelComplete3_sfx:
	ld	a, (sfx_levelComplete)
	cp	#9
	jr	nz, try_levelComplete4_sfx

	ld	l, #06			
	ld	h, #10					
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #10
	ld	(sfx_levelComplete), a
	ret

	try_levelComplete4_sfx:
	ld	a, (sfx_levelComplete)
	cp	#13
	jr	nz, incrementar_levelComplete

	ld	l, #05				
	ld	h, #10					
	ld	e, #69				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #0
	ld	(sfx_levelComplete), a

	ret
	incrementar_levelComplete:
	ld	a, (sfx_levelComplete)
	inc	a
	ld	(sfx_levelComplete), a
	ret
;////////////////////////////////////////////////////////////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////


; sonidos al completar el juego
sonido_endGame:
	jr sonido_endGame_part1



sonido_endGame_part1:
	ld	a, (sfx_gameComplete)
	cp	#0
	ret	z

	ld	a, (sfx_gameComplete)
	cp	#1
	jr	nz, try_gameComplete2_sfx

	ld	l, #06				
	ld	h, #11				
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #2
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete2_sfx:
	ld	a, (sfx_gameComplete)
	cp	#5
	jr	nz, try_gameComplete3_sfx

	ld	l, #06			
	ld	h, #11					
	ld	e, #62				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #6
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete3_sfx:
	ld	a, (sfx_gameComplete)
	cp	#9
	jr	nz, try_gameComplete4_sfx

	ld	l, #06			
	ld	h, #11					
	ld	e, #64				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #10
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete4_sfx:
	ld	a, (sfx_gameComplete)
	cp	#13
	jr	nz, sonido_endGame_part2

	ld	l, #06				
	ld	h, #11					
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #14
	ld	(sfx_gameComplete), a
	ret


sonido_endGame_part2:
	ld	a, (sfx_gameComplete)
	cp	#17
	jr	nz, try_gameComplete6_sfx

	ld	l, #06			
	ld	h, #11					
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #18
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete6_sfx:
	ld	a, (sfx_gameComplete)
	cp	#21
	jr	nz, try_gameComplete7_sfx

	ld	l, #06			
	ld	h, #11					
	ld	e, #62				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #22
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete7_sfx:
	ld	a, (sfx_gameComplete)
	cp	#25
	jr	nz, try_gameComplete8_sfx

	ld	l, #06				
	ld	h, #11					
	ld	e, #61				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #26
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete8_sfx:
	ld	a, (sfx_gameComplete)
	cp	#29
	jr	nz, try_gameComplete9_sfx

	ld	l, #06			
	ld	h, #11					
	ld	e, #62				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #30
	ld	(sfx_gameComplete), a
	ret

	try_gameComplete9_sfx:
	ld	a, (sfx_gameComplete)
	cp	#33
	jr	nz, incrementar_gameComplete

	ld	l, #05				
	ld	h, #11					
	ld	e, #69				
	ld	d, #0					
	ld	bc, #0				
	ld	a, #0x04  ; -> binario 010    
	call cpct_akp_SFXPlay_asm
	ld	a, #0
	ld	(sfx_gameComplete), a
	ret

	incrementar_gameComplete:
	ld	a, (sfx_gameComplete)
	inc	a
	ld	(sfx_gameComplete), a
	ret










