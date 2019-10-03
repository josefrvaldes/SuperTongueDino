;;
;; ENTITY PHYSICS MOVEMENTS
;;
.include "cpctelera.h.s"
.include "cmp/entity.h.s"
.include "man/entity.h.s"
;.include "sys/colisions.h.s"
.include "sys/collisions.h.s"



.module sys_entity_physics

;; //////////////////
;; Physics system constants
screen_width  = 80
screen_height = 200


;;
;; VARIABLES CONTROL DEL SALTO Y REBOTES
;;
V_jumpControlVY_gravity:	.db #-1 ;; -1 GRAVITY // 0 JUMP CONTROL
V_jumpControlVX_keyboardO: 	.db #1 ;; -1 GRAVITY // 0 JUMP CONTROL
V_jumpControlVX_keyboardP:	.db #1 ;; -1 GRAVITY // 0 JUMP CONTROL
hero_jump: 			.db #-1         	;; -1 NO SALTANDO
hero_jump_left:		.db #-1
hero_jump_right:		.db #-1
hero_gravity: 		.db #0
press_now_W:		.db #-1	;; variable que nos indica si estamos saltando justo en ese momento
;;
;;TABLAS DE SALTO Y GRAVEDAD
;;
jump_table:
	.db #-7, #-5, #-4, #-3
    	.db #-2, #-2, #-2, #-1
    	.db #-1, #-1, #-1
    	.db #0x80
gravity_table:
    	.db #00, #00, #00
    	.db #1, #1, #1, #1
    	.db #2, #2, #2, #3
	.db #5, #7 
    	.db #0x80
jump_table_right:  		;; POSITIVO: RIGHT
	.db #2, #2, #1, #1, #1
	.db #0x80
jump_table_left:  
	.db #-2, #-2, #-1, #-1, #-1	;; NEGATIVO: LEFT
	.db #0x80
;;
;; METODO QUE DEVUELVE SI ESTAMOS UTILIZANDO LA TABLA DE SALTO O NO
;; 	RETURN: A - valor de salto lateral
;;	DESTROY: AF
;;
get_hero_jump_left::
	ld	a, (hero_jump_left)
ret

get_hero_jump_right::
	ld	a, (hero_jump_right)
ret



;; INITR RENDER SYSTEM
sys_physics_init::
	ret

;;
;; SYS_PHYSICS UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX
;; Stack Use: 2 bytes
sys_physics_update::
	ld	(_ent_counter), a

;; CONTROLAMOS SI ESTAMOS SALTANDO O ESTAMOS CAYENDO CON GRAVEDAD
	ld	a, (V_jumpControlVY_gravity)
	cp	#-1

	jr	z, aplicate_gravity	;; SI EL VALOR ERA -1 APLICAMOS GRAVEDAD
		call jump_control
		jr	no_gravity
aplicate_gravity:
	call	gravedad_hero
no_gravity:

;; CONTROLAMOS SI ESTAMOS SALTANDO LATERALMENTE POR LA DERECHA
	ld	a, (V_jumpControlVX_keyboardO)
	cp	#-1
	jr	z, not_aplicate_jump_table_right 	;; SI EL VALOR ERA -1 NO TABLA DE SALTO DERECHA
		call jump_control_right
not_aplicate_jump_table_right:

;; CONTROLAMOS SI ESTAMOS SALTANDO LATERALMENTE POR LA IZQUIERDA
	ld	a, (V_jumpControlVX_keyboardP)
	cp	#-1
	jr	z, not_aplicate_jump_table_left	;; SI EL VALOR ERA -1 NO TABLA DE SALTO IZQUIERDA
		call jump_control_left
not_aplicate_jump_table_left:


;; BUCLE QUE RECORRE TODAS LAS ENTIDADES CON FISICAS 
_update_loop:

;; COLISIONES CON LOS OBJETOS
	call sys_check_collision
	;; tenemos en D = VX en E = VY
	;; si colisionamos por arriba, salto normal

	ld	a, d
	add	e
	jr	z,	no_jump	;Si !=0 uno de nuestros saltos seguro la jum_table normal 

    		ld  a, e_y(ix)
    		add e_vy(ix)
    		ld  c, a
    		ld  a, e_vy(ix)
    		sub c
    		jr	z, no_mas_saltos
    		jr  nc, parar_salto_vetical  ;; velocidad positiva

    			;; vamos a ver si justo ahora esta pulsada la tecla W
    			ld	a, (press_now_W)
    			cp	#-1
    			jr 	z, no_jump  ;; ya no saltamos ni para arriba ni lateralmente
			call activar_salto_normal

			;; en la D tengo la variabilidad de la velocidad
			;; si es positiva, llevamos velocidad NEGATIVA = nos movemos con O = right
			;; si es negativa, llevamos velocidad POSITIVA = nos movemos con P = left
    			ld	a, #0
    			add	d      ;; VX corregida

    			jr z, no_jump		;; 0, SIN VELOCIDIAD

	    			ld  a, e_x(ix)
	    			add e_vx(ix)
	    			ld  c, a
	    			ld  a, e_vx(ix)
	    			sub c
	    			jr  z, no_jump    
	    			jr  c, jump_left  ;; velocidad positiva
	        		;;velocidad negativa
	        			call active_jump_right ;; activamos la jump table right
	        		jr no_jump

jump_left:				;; velocidad positiva
	        			call active_jump_left  ;; activamos la jump table left
;======================================================================
		;jr	no_mas_saltos

no_jump:
;; COLISIONES CON LAS ESQUINAS DE LOS OBJETOS
	call sys_check_collision_corner

	jr no_parar_salto_vertical
;; DEBEMOS PARAR EL SALTO VERTICAL
parar_salto_vetical:
	call	end_of_jump
no_parar_salto_vertical:
;; COLISIONES CON LOS BORDES DE LA PANTALLA
no_mas_saltos:
	call sys_check_borderScreem

	_ent_counter = . + 1
	ld	b, #0
	dec 	b
	ret	z

	ld	de, #sizeof_e
	add 	ix, de
	jr	_update_loop


;======================================================================================
sys_check_borderScreem:
;; CHOQUES CON LOS BORDES DE LA PANTALLA
	;; UPDATE X
	ld	a, #screen_width + 1
	sub	e_w(ix)
	ld	c, a

	ld	a, e_x(ix)
	add	e_vx(ix)
	cp	c
	jr	nc, invalid_x
valid_x:
	ld	e_x(ix), a
	jr endif_x
invalid_x:
	ld	a, e_vx(ix)
	neg				;; para cambiar a negativo
	ld	e_vx(ix), a
endif_x:


	;; UPDATE Y
	ld	a, #screen_height + 1
	sub	e_h(ix)
	ld	c, a

	ld	a, e_y(ix)
	add	e_vy(ix)
	cp	c
	jr	nc, invalid_y
valid_y:
	ld	e_y(ix), a
	jr endif_y
invalid_y:
	ld	a, e_vy(ix)
	neg				;; para cambiar a negativo
	ld	e_vy(ix), a
endif_y:

	ret

;======================================================================================
sys_check_collision:
	;; RETURN: - IY puntero a obstaculos
	;;	     - A numero de obstaculos
	call man_obstacle_getArray
	;; RETURN: - D modificacion en e_x
	;;         - E modificacion en e_y
	call check_collisions

	ld	a, d
	add	#0     ;; si no hat colision se debe de quedar en 0
	jr z, no_colision_X
		;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d
            ld    e_x(ix), a   
no_colision_X:

	ld	a, e
	add	#0	;; si no hay colision se debe de quedar en 0 ( -1 + 1 = 0)

	jr z, no_colision_Y
		;; COLISION EN Y
            ld    a, e_y(ix)
            sub    e
            ld    e_y(ix), a   
no_colision_Y:
	ret

;==========================================================================================
sys_check_collision_corner:
	;; Si no nos da colisiones por ningun lado puede ser que las tengamos en las diagonales
	ld	a, d
	add	e

	jr	nz,	no_collision_corner
	;; si PUEDE collision
	;; HAGO EL SUPUESTO DE SUMAR LA VELOCIAD EN Y
	ld	a, e_y(ix)
	add	e_vy(ix)
	ld	e_y(ix), a

	call man_obstacle_getArray
	;; RETURN: - D modificacion en e_x
	call check_collisions_corner

	ld	a, d
	add	#0		     ;; si no hat colision se debe de quedar en 0
	jr z, no_colision_X_corner
		;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d
            ld    e_x(ix), a   
no_colision_X_corner:
	;; haya o no colision, vuelvo a dejar la VY como estaba ya que se modifica despues
	ld	a, e_y(ix)
	sub	e_vy(ix)
	ld	e_y(ix), a
no_collision_corner:
	ret




;====================================================================0
;   			¡¡¡¡¡¡¡¡¡  SALTO !!!!!!!!!!
;=====================================================================

;; destruye A
gravedad_hero:

	ld	a, (hero_gravity)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

	;; Get jump value
	ld	hl, #gravity_table  ;; hl primer valor de jump_table
	ld	e, a
	ld 	d, #0
	add	hl, de

	;; Comprobar final del salto
	ld	a, (hl)
	cp	#0x80
	jr	z, max_gravity

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	a, e_vy(ix)
	add	d
	ld	e_vy(ix), a

	;; Cambia el indice actual en la tabla
	ld	a, (hero_gravity)
	inc	a
	ld	(hero_gravity), a
	ret
	;; se reinicia el satlo
max_gravity:
		ld	a, #7			;; gravedad maxima = 7

		ld	(hero_gravity), a
	ret

;; destruye A
jump_control_right:

	ld	a, (hero_jump_right)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

	;; Get jump value
	ld	hl, #jump_table_right  ;; hl primer valor de jump_table
	ld	e, a
	ld 	d, #0
	add	hl, de

	;; Comprobar final del salto
	ld	a, (hl)
	cp	#0x80
	jr	z, end_of_jump_right

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	a, e_vx(ix)
	add	d
	ld	e_vx(ix), a

	;; Cambia el indice actual en la tabla
	ld	a, (hero_jump_right)
	inc	a
	ld	(hero_jump_right), a
	ret
	;; se reinicia el satlo
end_of_jump_right:
		ld	a, #-1			;; gravedad maxima = 7

		ld	(hero_jump_right), a
		ld	(V_jumpControlVX_keyboardO), a
	ret

jump_control_left:

	ld	a, (hero_jump_left)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

	;; Get jump value
	ld	hl, #jump_table_left  ;; hl primer valor de jump_table
	ld	e, a
	ld 	d, #0
	add	hl, de

	;; Comprobar final del salto
	ld	a, (hl)
	cp	#0x80
	jr	z, end_of_jump_left

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	a, e_vx(ix)
	add	d
	ld	e_vx(ix), a

	;; Cambia el indice actual en la tabla
	ld	a, (hero_jump_left)
	inc	a
	ld	(hero_jump_left), a
	ret
	;; se reinicia el satlo
end_of_jump_left:
		ld	a, #-1			;; gravedad maxima = 7

		ld	(hero_jump_left), a
		ld	(V_jumpControlVX_keyboardP), a
	ret


jump_control:
	ld	a, (hero_jump)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

	;; Get jump value
	ld	hl, #jump_table  ;; hl primer valor de jump_table
	ld	e, a
	ld 	d, #0
	add	hl, de

	;; Comprobar final del salto
	ld	a, (hl)
	cp	#0x80
	jr	z, end_of_jump

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	a, e_vy(ix)
	add	d
	ld	e_vy(ix), a

	;; Cambia el indice actual en la tabla
	ld	a, (hero_jump)
	inc	a
	ld	(hero_jump), a
	ret
	;; se reinicia el satlo
end_of_jump:
		ld	a, #-1

		ld	(hero_jump), a
		ld 	(V_jumpControlVY_gravity), a

		ld	a, #0
		ld	(hero_gravity), a
		ld	a, #1
		;; cuando acabo del salto, la vuelvo a poner a 1 para volverlo a hacer
		ld	(V_jumpControlVX_keyboardO), a
		ld	(V_jumpControlVX_keyboardP), a
	ret

;; Modifica A
start_jump::

	ld	a, (press_now_W)
	cp	#-1
	jr	nz,  continue_start_jump	;; ya se habia pulsado el salto, me voy

		ld	a, #0
		ld (press_now_W), a

continue_start_jump:

	ld	a, (hero_jump)
	cp	#-1
	ret	nz	;; ya se habia pulsado el salto, me voy
	ld	a, #0
	ld	(hero_jump), a

	ret
not_jump::
	ld	a, (press_now_W)
	cp	#0
	ret	nz	;; ya se habia pulsado el salto, me voy

		ld	a, #-1
		ld (press_now_W), a

	ret
;;
;; SI ENTRAMOS AQUI ES QUE ESTAMOS COLISIONANDO CON UN OBJETO
;; Y SI A LA VEZ EL HER0_JUMP ESTA A 0, ES QUE HEMOS PULSADO 
;; TECLA DE SALTO, POR LO QUE ACTIVAMOS EL SALTO NORMAL
;; RECORDAR TENER VELOCIDAD NEGATIVA
;;
activar_salto_normal:

	ld	a, (hero_jump)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando
	;; SI  LLEGAMOS HASTA AQUI ES QUE:
		;; 1 - SE HA PULSADO LA TECLA DE SALTAR
		;; 2 - ESTAMOS COLISIONANDO
		;; 3 - MI VELOCIDAD EN EL EJE Y ES NEGATIVA
		ld	a, #0
		;ld	(hero_jump_active), a    ;; a 0 es que esta ACTIVO
		;; LE DAMOS EL CONTROL AL JUMP COMTRL
		ld (V_jumpControlVY_gravity), a
	ret

active_jump_left:
	ld	a, (V_jumpControlVY_gravity)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

	ld	a, (V_jumpControlVX_keyboardP)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando
		ld	a, #0
		;; el control deja de estar en el usuario y se le pasa a la jump table
		ld	(hero_jump_left), a    ;; a 0 es que esta ACTIVO
		ld	(V_jumpControlVX_keyboardP), a    ;; a 0 es que esta ACTIVO
	ret

active_jump_right:
	ld	a, (V_jumpControlVY_gravity)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto estamos en gravedad
	;; ERROR, NO NOS COGE LA GRAVEDAD EN ESE INSTANTE... .SE ACTUALIZARA DESPUES?

	ld	a, (V_jumpControlVX_keyboardO)
	cp	#-1
	ret	z	;; el valor era -1 y po lo tanto no se esta saltando

		ld	a, #0
		;; el control deja de estar en el usuario y se le pasa a la jump table
		ld	(hero_jump_right), a    ;; a 0 es que esta ACTIVO
		ld	(V_jumpControlVX_keyboardO), a    ;; a 0 es que esta ACTIVO
	ret


