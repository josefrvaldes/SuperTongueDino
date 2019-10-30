.include "cpctelera.h.s"
.include "cpct_functions.h.s"


unidades:   .db #0
decenas:	.db #0
centenas:	.db #0



sys_deathCounter::

	;; COMPROBAMOS SI ES 999 (MAXIMO)
	ld	a, (decenas)
	ld	d, a
	ld	a, (centenas)
	ld	c, a
	ld	a, (unidades)
	add	d
	add   c
	cp	#27
	ret	z

	;; COMPROBAMOS UNIDADES
	ld	a, (unidades)
	cp	#9
	jr	z, incrementar_decenas
		;; INCREMENTAMOS CENTENAS
		inc	a
		ld	(unidades), a
	ret 
incrementar_decenas:
	xor	a
	ld	(unidades), a ;; ponemos las centenas a 0

	;; COMPROBAMOS DECENAS
	ld	a, (decenas)
	cp	#9
	jr	z, incrementar_centenas
		;; INCREMENTAMOS LAS DECENAS
		inc	a
		ld	(decenas), a
	ret
incrementar_centenas:
	xor	a
	ld	(decenas), a ;; ponemos las centenas a 0

	;; COMPROBAMOS CENTENAS
	ld	a, (centenas)
	cp	#9
	ret	z
		;; INCREMENTAMOS LAS DECENAS
		inc	a
		ld	(centenas), a
 ret 



sys_death_init::
    xor	a
    ld	(unidades), a
    ld	(decenas), a
    ld	(centenas), a
 ret




sys_print_death_menuIngame::
    ld 	h, #1	
    ld 	l, #12	
    call cpct_setDrawCharM0_asm

    ld	de, #0xC000
    ld    b, #65			; Y
    ld    c, #42              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (unidades)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

    ld	de, #0xC000
    ld    b, #65			; Y
    ld    c, #38              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (decenas)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

    ld	de, #0xC000
    ld    b, #65			; Y
    ld    c, #34              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (centenas)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

 ret




sys_print_death_endGame::
    ld 	h, #1	
    ld 	l, #12	
    call cpct_setDrawCharM0_asm

    ld	de, #0xC000
    ld    b, #186			; Y
    ld    c, #42              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (unidades)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

    ld	de, #0xC000
    ld    b, #186			; Y
    ld    c, #38              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (decenas)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

    ld	de, #0xC000
    ld    b, #186			; Y
    ld    c, #34              ; X 
    call cpct_getScreenPtr_asm   
    ld	a, (centenas)
    add	#48
    ld	e, a
    call cpct_drawCharM0_asm

 ret