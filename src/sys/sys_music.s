.include "cpctelera.h.s"
.include "cpct_functions.h.s"

.globl _song_ingame1
.globl _song_ingame2

contadorVelocidadMusica: .db #12
velocidadMusica:	.db #12			;; suena 1 vez cada 12 interrupciones


;ArrayCanciones:
;	.dw	#_song_ingame
;
;cancion1 == 0
;cancion2 == 2
;cancion3 == 4
;cancion4 == 6




;; Input: A -> numero cancion
sys_music_ponerMusica::
	call sys_music_pararMusica
	;ld		ix, #ArrayCanciones
	;ld 		e, a(ix)
	;inc 	a
	;ld 		d, 1(ix)
	dec	a
	jr	nz, comprobarCancion2	
	ld	a, #12
	ld	(contadorVelocidadMusica), a
	ld	(velocidadMusica), a 
	ld	de, #_song_ingame1
	call	cpct_akp_musicInit_asm	;; Inicializa la cancion
	jr 	continuarReproduciendo

	comprobarCancion2:
	ld	a, #12
	ld	(contadorVelocidadMusica), a
	ld	(velocidadMusica), a 
	ld	de, #_song_ingame2
	call	cpct_akp_musicInit_asm	


	continuarReproduciendo:
	ld	hl, #isr
	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor

	ret



; Destroy: DE, HL
sys_music_init::
;	call sys_music_pararMusica
;	ld 		de, #_song_ingame
;	call	cpct_akp_musicInit_asm	;; Inicializa la cancion
;
;	ld		hl, #isr
;	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor
	ret



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

	call cpct_akp_musicPlay_asm
	ld	a, (velocidadMusica)
	ld	(contadorVelocidadMusica), a

	return_interrumpir:
	pop	iy
	pop hl
	pop de
	pop bc
	pop af
	exx
	ex	af, af'

	ret





; Destroy: 
sys_music_pararMusica::
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
	pop	iy
	pop hl
	pop de
	pop bc
	pop af
	ex	af, af'

	ret