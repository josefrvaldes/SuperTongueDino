;;
;;  ENTITY AI CONTROL SYSTEM
;;
.include "cpctelera.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/entity.h.s"
.include "cpct_functions.h.s"
.include "man/game.h.s"

.module sys_ai_control
 

dificultadRango_1 = 10			;; para cambiar la dificultad de los enemigos dependiendo del nivel
dificultadRango_2 = 15
dificultadRango_3 = 20
dificultad_0 = 0
dificultad_1 = 1
dificultad_2 = 2
dificultad_3 = 3
dificultadEnemigos: .db #0		;; selector dificultad


patrullar_llamaPerseguir: 	.db #0

rebote_control_direcction: 	.db #0
control_direction_X:						;; Tabla de salto normal (hacia arriba)
	.db #1,  #1,  #0, #-1
    	.db #-1, #-1, #0, #1
    	.db #0x80					;; Ultima posicion de la tabla, para saber que he terminado (nunca tendre una velocidad tan alta)
control_direction_Y:					;; Tabla de salto que simula la gravedad
    	.db #0, #-1, #-2, #-1
    	.db #0, #1,  #2,  #1
    	.db #0x80





;; //////////////////
;; Inits AI system
;; Input: IX -> puntero al array de entidades
;; Destroy: A
sys_ai_control_init::
	ld 	(_ent_array_ptr_temp_standby), ix  ;; temporal
	ld 	(_ent_array_ptr_temp_rebotar), ix  ;; temporal
	ld 	(_ent_array_ptr_temp_perseguir), ix  ;; temporal
	ld 	(_ent_array_ptr_temp_defender), ix  ;; temporal
	ld 	(_ent_array_ptr_temp_patrullar), ix  ;; temporal
	ld 	(_ent_array_ptr), ix

	ld 	a, #0
	ld	(dificultadEnemigos), a
	ld	(patrullar_llamaPerseguir), a
	ld	(rebote_control_direcction), a

	call setDificultadEnemigos

	ret




;; //////////////////
;; SAI Stand by
sys_ai_stand_by:
_ent_array_ptr_temp_standby = . + 2
	ld	iy, #0x0000

	ld 	a, e_ai_aim_x(iy)
	or 	a
	ret	z
	;; Cambiar estado si se pulsa una tecla
	ld	a, e_x(iy)
	ld	e_ai_aim_x(ix), a
	ld	a, e_y(iy)
	ld	e_ai_aim_y(ix), a
	ld	e_ai_st(ix), #e_ai_st_move_to

	ret




;; //////////////////
;; Ai Move to
sys_ai_move_to:
	ld	e_vy(ix), #0
	ld	e_vx(ix), #0 ;; IMPORTANTE !!! esto no lo pone en su video pero creo que se debe poner por la linea anterior que si pone

	;;DETECTAR X
	ld	a, e_ai_aim_x(ix)		;; A = obj_x
	sub	e_x(ix)			;; A = obj_x - x
	jr	nc, _objx_greater_or_equal
_objx_lesser:
	ld	e_vx(ix), #-1
	jr	_endif_x
_objx_greater_or_equal:
	jr	z, _arrived_x
	ld	e_vx(ix), #1
	jr	_endif_x
_arrived_x:
	ld	e_vx(ix), #0
_endif_x:
	;; DETECTAR Y
	ld	a, e_ai_aim_y(ix)		;; A = obj_y
	sub	e_y(ix)			;; A = obj_y - y
	jr	nc, _objy_greater_or_equal
_objy_lesser:
	ld	e_vy(ix), #-1
	jr	_endif_y
_objy_greater_or_equal:
	jr	z, _arrived_y
	ld	e_vy(ix), #1
	jr	_endif_y
_arrived_y:
	ld	e_vy(ix), #0
	ld	a, e_vx(ix)
	or	a
	jr	nz, _endif_y
	ld	e_ai_st(ix), #e_ai_st_stand_by	;; la X e Y son 0, por lo que ha llegado
_endif_y:

	ret




;; //////////////////
;; Sys AI CONTROL UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX
;; Stack Use: 2 bytes
sys_ai_control_update::

	ld	(_ent_counter), a

_ent_array_ptr = . + 2
	ld	ix, #0x0000

	

_loop:
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_noAI
	jr	z, _no_AI_ent
_AI_ent:
	cp 	#e_ai_st_stand_by
	call	z, sys_ai_stand_by
	cp 	#e_ai_st_move_to
	call	z, sys_ai_move_to
	cp 	#e_ai_st_rebotar
	call	z, sys_ai_rebotar
	cp 	#e_ai_st_perseguir
	call	z, sys_ai_perseguir
	cp 	#e_ai_st_defender
	call	z, sys_ai_defender
	cp 	#e_ai_st_patrullar
	call	z, sys_ai_patrullar
_no_AI_ent:
_ent_counter = . + 1
	ld 	a, #0
	dec	a
	ret 	z
	ld	(_ent_counter), a
	;; salta a la siguiente entidad
	ld	de, #sizeof_e
	add	ix, de

	jr	_loop




;; //////////////////////////////////////////
;; REBOTAR IA
;; //////////////////////////////////////////
; Entrada: IX -> al enemigo,    IY -> jugador
; Destruye: A
sys_ai_rebotar:
	;; para simular una velocidad de 0,5 entraremos en el metodo la mitad de veces
	ld	a, e_ai_pausaVel(ix)
	cp	#0
	jr	nz, espera_movimiento
	ld	a, #2
	ld	e_ai_pausaVel(ix), a

	_ent_array_ptr_temp_rebotar = . + 2
	ld	iy, #0x0000					;; se almacena el jugador

	ld	a, (dificultadEnemigos)
	cp	#dificultad_0
	ret	z
	;; METODO MOVIMIENTO ALEATORIO
	call movimiento_aleatorio

	ld	a, (dificultadEnemigos)
	cp	#dificultad_1
	ret	z
	call rebotar_elegirCambioEstado
	
 ret
espera_movimiento:
	;; cotraposicion de la velocidad
	ld	a, e_vx(ix)
	neg
	add	e_x(ix)
	ld	e_x(ix), a

	ld	a, e_vy(ix)
	neg
	add	e_y(ix)
	ld	e_y(ix), a

	ld	a, e_ai_pausaVel(ix)
	dec   a
	ld	e_ai_pausaVel(ix), a
 ret


;; puede cambiar el estado de la IA
;; Destruye: A, BC, DE
rebotar_elegirCambioEstado:
	;; Devuelve: A
	ld	d, #15
	call sys_ai_detectarJugador
	dec 	a
	jr nz, patrullar_verJugador
	;; debemos poner el contador de decision a 0 antes
	ld	a, #30
	ld	e_ai_cambioDirecccion(ix), a

	ld	a, (dificultadEnemigos) 	;; elegir ataque si la dificultad es 3 o menos
	cp	#dificultad_2
	jr	z, rebotar_elegirAtaque

	call	rebotar_elegirAtaqueDefensa
	dec 	a
	jr 	z, rebotar_elegirAtaque
	ld	a, #e_ai_st_defender		;; cambia a la IA de defensa
	ld	e_ai_st(ix), a
	ret
	rebotar_elegirAtaque:
	ld	a, #e_ai_st_perseguir		;; cambia a la IA de persecucion
	ld	e_ai_st(ix), a
	ret

	patrullar_verJugador:			;; Comprueba si la IA patrullar lo ha visto
	ld	a, (patrullar_llamaPerseguir)
	dec	a
	ret	nz
	ld	a, #e_ai_st_perseguir		;; cambia a la IA de persecucion en caso de haberlo visto la de patrullar
	ld	e_ai_st(ix), a

	ret



;; Entrada: IX -> al enemigo, IY -> al jugador, D -> el ancho de la zona de deteccion
;; Salida:  A=0 -> no se detecta,  A=1 -> se detecta al jugador
;; Destruye; A, BC, DE
sys_ai_detectarJugador:  ; colision basica luego añadir distancia ESTO ESTA EN PRUEBAS
	ld	a, e_invisi(iy)	
	dec	a
	jr 	z, __no_collision	;; Comprobar si el enemigo es invisible

	ld	a, d   ;; Ancho en X
	add	d
	ld	e, a	 ;; Ancho en Y
;=======================================================================
 ;; X con rango
	ld  	a, e_x(ix) 
	sub   d
	jr  	nc, out_screem_LEFT 
	ld  	a, #0
out_screem_LEFT:
	ld  	b, a            ;; en B tengo la verdade X
	;; ANCHO con rango
	ld  	a, d
	add  	e_x(ix)
	add  	e_w(ix)
	ld  	c	, a            ;; en C tengo el verdadero ancho
;===============================================================================
	ld  	a, c
	sub  	e_x(iy)
	jr  	c, __no_collision

	ld  	a, e_x(iy)
	add  	e_w(iy)
	sub 	b
	jr  	c, __no_collision

;============================================================================
;; Y con rango  
	ld  	a, e_y(ix) 
	sub   e
	jr  	nc, out_screem_UP 
	ld  	a, #0
out_screem_UP:
	ld  	b, a  
	;; ALTO con rango
	ld  	a, e 
	add  	e_y(ix)
	add  	e_h(ix)
	ld  	c, a            ;; en C tengo el verdadero alto
;====================================================================================
	ld  	a, c
	sub  	e_y(iy)
	jr  	c, __no_collision

	ld  	a, e_y(iy)
	add  	e_h(iy)
	sub  	b
	jr  	c, __no_collision

    ld  de,   #0xC000
    ld  a,   #0xFF
    ld  c,    #0x04
    ld  b,    #0x08
        call cpct_drawSolidBox_asm

    	ld	a, #1
ret
__no_collision:
    ld  de,   #0xC000
    ld  a,   #0x00
    ld  c,    #0x04
    ld  b,    #0x08
        call cpct_drawSolidBox_asm

    ld	a, #0
  ret



movimiento_aleatorio:
	ld	a, e_ai_cambioDirecccion(ix)
	cp	#0
	jr	nz, espera_actualizar_velocidad

	;; SOLO AQUI ACTUALIZAMOS VELOCIDAD
	call rebote_tabla_direcciones

	ld	a, #50
	ld	e_ai_cambioDirecccion(ix), a
 ret
espera_actualizar_velocidad:
	dec   a
	ld	e_ai_cambioDirecccion(ix), a
 ret




rebote_tabla_direcciones:
	ld	a, (rebote_control_direcction)
	;; Get jump value
	ld	hl, #control_direction_X 
	ld	e, a
	ld 	d, #0
	add	hl, de

	;; Comprobar final del salto
	ld	a, (hl)
	cp	#0x80
	jr	z, fin_ciclo_velocidades

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	e_vx(ix), a

	ld	a, (rebote_control_direcction)
	ld	hl, #control_direction_Y
	ld	e, a
	ld 	d, #0
	add	hl, de

	ld	a, (hl)
	ld	d, a
	ld	e_vy(ix), a

	;; Cambia el indice actual en la tabla
	ld	a, (rebote_control_direcction)
	inc	a
	ld	(rebote_control_direcction), a
	ret
	;; se reinicia el satlo
fin_ciclo_velocidades:
		ld	a, #0		
		ld	(rebote_control_direcction), a
	ret


;;
;; METODO QUE CALCULA LA MEJOR OPCION ENTRE ATACAR O DEFENDER
;; RETURN: A: -1 defensa // 1 ataque
;; Delete: A, DE
rebotar_elegirAtaqueDefensa:
	ld	a, #76
	sub	e_x(ix)
	ld	d, a    ; almacena en de la distancia a la salida

	ld	a, e_x(ix)
	sub	e_x(iy)
	jr	c, rebotar_perseguirJugador
	cp	d
	jr	c, rebotar_perseguirJugador
	ld	a, #-1
	ret

	rebotar_perseguirJugador:
	ld 	a, #1
	ret











;////////////////////////////////
; Perseguir
;////////////////////////////////
sys_ai_perseguir:
	_ent_array_ptr_temp_perseguir = . + 2
	ld	iy, #0x0000					;; se almacena el jugador

	;; para simular una velocidad de 0,5 entraremos en el metodo la mitad de veces
	ld	a, #0
	ld	e_vx(ix), a
	ld	e_vy(ix), a
	ld	a, e_ai_pausaVel(ix)
	cp	#0
	jr	nz, espera_movimiento2
	ld	a, #2
	ld	e_ai_pausaVel(ix), a

	call atacar_calcularVelocidad
	ld  	a, d
	ld   	e_vx(ix), a
	ld  	a, e
	ld   	e_vy(ix), a

	;; Devuelve: A 
	ld	d, #15
	call sys_ai_detectarJugador
	dec 	a
	ret  	z
	ld	a, #e_ai_st_rebotar		;; cambia a la IA de persecucion
	ld	e_ai_st(ix), a

	ret
espera_movimiento2:
	;; cotraposicion de la velocidad
	dec   a
	ld	e_ai_pausaVel(ix), a
 ret



; Devuelve d -> velocidadX,  c -> velocidadY
; Elimina: AF, DE, C
atacar_calcularVelocidad:
  	ld  d, #0
  	ld  e, #0
	;; PERSECUCION DEL HERO
	ld	a, e_x(ix)		;; en A la posicion X del enemigo
	sub	e_x(iy)
	jr	c, move_enemy_right  ;; tenemos al hero en la parte derecha
	jr	z, move_axisY
		ld	d, #-1
	jr	move_axisY
move_enemy_right:
		ld	d, #1
move_axisY:
	ld	a, e_y(ix)		;; en A la posicion X del enemigo
	sub	e_y(iy)
	jr	c, move_enemy_down  ;; tenemos al hero en la parte derecha
	ret	z
		ld	e, #-1
	ret
move_enemy_down:
		ld	e, #1
	ret











;////////////////////////////////
; Defender
;////////////////////////////////
sys_ai_defender:
  _ent_array_ptr_temp_defender = . + 2
  ld   iy, #0x0000

  ld	 a, #0
  ld   e_vx(ix), a
  ld   e_vy(ix), a
  ld   a, e_ai_pausaVel(ix)
  cp   #0
  jr   nz, defender_reiniciarPausa
  ld   a, #1
  ld   e_ai_pausaVel(ix), a

  call defender_calcularVelocidad  ; Devuelve d -> velocidadX,  e -> velocidadY
  ld   a, d
  ld   e_vx(ix), a
  ld   a, c
  ld   e_vy(ix), a

  ld	 d, #15
  call sys_ai_detectarJugador
  dec  a
  jr   z, defender_seguirEjecutando
  ld   a, #e_ai_st_rebotar    ;; cambia a la IA a rebotar
  ld   e_ai_st(ix), a
  defender_seguirEjecutando:
  ret
defender_reiniciarPausa:
  dec   a
  ld    e_ai_pausaVel(ix), a
  ret


; Devuelve d -> velocidadX,  c -> velocidadY
; Elimina: AF, D, C
defender_calcularVelocidad:
  ld  d, #0
  ld  c, #0
  ld   a, #76
  sub  e_x(iy)
  jr   z, defender_calcularY
  ld  d, #1
  
  defender_calcularY:
  ld   a, e_y(ix)
  sub  e_y(iy)
  jr  c, defender_AbajoY
  ret  z
  ld  c, #-1
  ret
  defender_AbajoY:
  ld  c, #1
  ret








;////////////////////////////////
; PATRULLAR
;////////////////////////////////
sys_ai_patrullar:
	_ent_array_ptr_temp_patrullar = . + 2
	ld	iy, #0x0000

	ld	a, (dificultadEnemigos)
	cp	#dificultad_0
	jr	z, acabar_patrulla

	call sys_ai_patrullar_cambiarGravedad

	ld	a, (dificultadEnemigos)
	cp	#dificultad_3
	jr	nz, acabar_patrulla

	ld	d, #3
	call sys_ai_detectarJugador
	dec	a
	jr	nz, patrullar_noAvisar
	;ld	a, #1						;; descomentar para que las patrullas llamen a perseguir 
	;ld	(patrullar_llamaPerseguir), a
	ret
	patrullar_noAvisar:
	ld	a, #0
	ld	(patrullar_llamaPerseguir), a

acabar_patrulla:
	ret

sys_ai_patrullar_cambiarGravedad:
	;; TEMPORIZADOR
	ld	a, e_ai_reloj1(ix)
	dec  	a
	ld  	e_ai_reloj1(ix), a
	jr  	nz, salto_tempo_patrullar
	ld  	a, #0x20
	ld  	e_ai_reloj1(ix), a

	ld  	a, e_ai_reloj2(ix)
	dec  	a
	ld  	e_ai_reloj2(ix), a
	jr  	nz, salto_tempo_patrullar
	ld  	a, #0x20
	ld  	e_ai_reloj2(ix), a
	ld	a, e_vy(ix)
	neg
	ld	e_vy(ix), a
salto_tempo_patrullar:
	ret




;; Destroy: A, B
setDificultadEnemigos:
	ld	a, (nivel)
	ld	b, a

	ld	a, #dificultadRango_1
	cp	b
	jr	c, probar_Rango2
	ld	a, #dificultad_0
	ld	(dificultadEnemigos), a
	ret

	probar_Rango2:
	ld	a, #dificultadRango_2
	cp	b
	jr	c, probar_Rango3
	ld	a, #dificultad_1
	ld	(dificultadEnemigos), a
	ret

	probar_Rango3:
	ld	a, #dificultadRango_3
	cp	b
	jr	c, probar_Rango4
	ld	a, #dificultad_2
	ld	(dificultadEnemigos), a
	ret

	probar_Rango4:
	ld	a, #dificultad_3
	ld	(dificultadEnemigos), a

	ret