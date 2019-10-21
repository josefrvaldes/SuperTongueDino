.include "cpctelera.h.s"
.include "cpct_functions.h.s"

.globl _song_ingame1
.globl _song_ingame2

contadorVelocidadMusica: .db #12
velocidadMusica:	.db #12			;; suena 1 vez cada 12 interrupciones

pulsadoSaltoSonar: .db #0


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
	call	sys_music_init_sfx		; Inicializa sfx	

	ld	hl, #isr
	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor

	ret


sys_music_selectSong:
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
	call	detectarSonido_Sfx

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


sys_music_init_sfx:
	push 	de
	ld	de, #_song_ingame1			;; solo coge la cancion con el conjunto de instrumentos, las notas se hacen luego
	call cpct_akp_SFXInit_asm
	pop 	de
	ret



; Destruye: AF, BC, DE, HL
detectarSonido_Sfx:
	ld	a, (pulsadoSaltoSonar)
	dec	a
	jr	nz, return_interrumpir_sfx

	ld	l, #1
	ld	h, #9
	ld	e, #40
	ld	d, #0
	ld	bc, #0
	ld	a, #0x04  ; -> binario 010
	call cpct_akp_SFXPlay_asm
	ld	a, #0
	ld	(pulsadoSaltoSonar), a

	return_interrumpir_sfx:

	ret


; Destruye: A
sys_music_sonar_Salto::
	ld	a, #1
	ld	(pulsadoSaltoSonar), a
	ret




;sys_music_init_sfx::
;	push 	de
;	ld	de, #_song_ingame1			;; solo coge el instrumento, las notas se hacen luego
;	call cpct_akp_SFXInit_asm
;	pop 	de
;
;	ld	a, #12
;	ld	(contadorVelocidadMusica), a
;	ld	(velocidadMusica), a 
;	ld	hl, #sys_music_jump
;	call 	cpct_setInterruptHandler_asm   ; Coloca un interruptor
;	ret



;sys_music_jump:
;	
;
;	push af
;	push bc
;	push de
;	push hl
;
;	ld	a, (contadorVelocidadMusica)
;	dec	a
;	ld	(contadorVelocidadMusica), a
;	jr	nz, return_interrumpir_sfx
;
;	ld	a, (pulsadoSaltoSonar)
;	dec	a
;	jr	nz, return_interrumpir_sfx1
;	;(1B L ) sfx_num	Number of the instrument in the SFX Song (>0), same as the number given to the instrument in Arkos Tracker.
;	;(1B H ) volume	Volume [0-15], 0 = off, 15 = maximum volume.
;	;(1B E ) note	Note to be played with the given instrument [0-143]
;	;(1B D ) speed	Speed (0 = As original, [1-255] = new Speed (1 is fastest))
;	;(2B BC) inverted_pitch	Inverted Pitch (-0xFFFF -> 0xFFFF).  0 is no pitch.  The higher the pitch, the lower the sound.
;	;(1B A ) channel_bitmask	Bitmask representing channels to use for reproducing the sound (Ch.A = 001 (1), Ch.B = 010 (2), Ch.C = 100 (4))
;
;	ld	l, #1
;	ld	h, #10
;	ld	e, #120
;	ld	d, #0
;	ld	bc, #0
;	ld	a, #2  ; -> binario 010
;	call cpct_akp_SFXPlay_asm
;
;	
;
;	ld	a, #0
;	ld	(pulsadoSaltoSonar), a
;
;	return_interrumpir_sfx1:
;	ld	a, (velocidadMusica)
;	ld	(contadorVelocidadMusica), a
;	
;	return_interrumpir_sfx:
;
;	pop hl
;	pop de
;	pop bc
;	pop af
;
;	
;	ret


