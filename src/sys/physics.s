;;
;; ENTITY PHYSICS MOVEMENTS
;;
.include "cpctelera.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/entity.h.s"
.include "man/man_obstacle.h.s"
.include "sys/collisions.h.s"


.module sys_entity_physics

;; Physics system constants
screen_width  = 80
screen_height = 200
;;
;; VARIABLES CONTROL DEL SALTO Y REBOTES
;;
V_jumpControlVY_gravity:	.db #-1 		;; -1 GRAVITY     // 0 JUMP CONTROL
V_jumpControlVX_keyboardO: 	.db #1 		;; -1 KEYBOARD    // 0 JUMP CONTROL           // 1 PRIMER SALTO
V_jumpControlVX_keyboardP:	.db #1 		;; -1 KEYBOARD    // 0 JUMP CONTROL          // 1 PRIMER SALTO
hero_jump: 				.db #-1         	;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_left:			.db #-1		;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_right:			.db #-1		;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_gravity: 			.db #0		;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
press_now_W:			.db #-1		;; variable que nos indica si estamos saltando justo en ese momento
;spittle:				.db #6      	;; el numero de saliva es lo que le restamos a la gravedad 
;;
;;TABLAS DE SALTO Y GRAVEDAD
;;
jump_table:						;; Tabla de salto normal (hacia arriba)
	.db #-7, #-5, #-4, #-3
    	.db #-2, #-2, #-2, #-1
    	.db #-1, #-1, #-1
    	.db #0x80					;; Ultima posicion de la tabla, para saber que he terminado (nunca tendre una velocidad tan alta)
gravity_table:					;; Tabla de salto que simula la gravedad
    	.db #00, #00, #00
    	.db #1, #1, #1, #2
    	.db #2, #3, #4
    	.db #0x80
jump_table_right:  				;; Tabla hacia la IZQUIERDA cuando colisionamos por la DERECHA
	.db #2, #2, #1, #1, #1, #00
	.db #0x80
jump_table_left:  				;; Tabla hacia la DERECHA cuando colisionamos por la IZQUIERDA
	.db #-2, #-2, #-1, #-1, #-1,#00	
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
;; Destroy: AF, BC, DE, IX, IY, HL -- TODOS
;; Stack Use: 2 bytes
sys_physics_update::
	ld	(_ent_counter), a

	;; commprobamos si somos el HEROE o un ENEMIGO para pocesar el salto
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_noAI	;; comparamos si no tiene IA
	jr	nz, _update_loop
		;; SOMOS EL HEROE
		call check_jump_tables_init

;; BUCLE QUE RECORRE TODAS LAS ENTIDADES CON FISICAS 
_update_loop:
	;; COLISIONES CON LOS OBJETOS
	call sys_check_collision

	;; tenemos en D = VX en E = VY
	ld	a, d
	add	e										;; sumo variacion en D y variacion en E
	jr	nz,	equals								;Si !=0 es que NO HAY COLISION EN LAS ESQUINAS

		ld	a, #0
		add	d
		jr	z, only_collision_corner   					;; SI UNA DE LAS DOS ES 0, LAS DOS LO ERAN (D y E) y por tanto comprobar colisiones en las esquinas
equals:	;; si no son iguales HA HABIDO COLISION SEGURO
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_noAI
	jr	z, continuar_saltando




	;; colisiones enemigo ///////////////////////////////////////////////////////////
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_rebotar

	ld a, (#col_hay_colision_top)
	dec a
	jr nz, comprobar_vel_Y
	;jr	nz, no_mas_saltos  ;; se comprueba si el enemigo rebota
	;ld a, d
	;or a
	;jr z, comprobar_vel_Y   ;; se comprueba si colisiona en X, en caso afirmativo se le niega la vx
	ld  a, e_vx(ix)
	neg
	ld  e_vx(ix), a
	comprobar_vel_Y:
	ld a, (#col_hay_colision_left)
	dec a
	jr nz, no_mas_saltos
	;ld a, c
	;or a
	;jr z, no_mas_saltos	;; se comprueba si colisiona en Y, en caso afirmativo se le niega la vy
	ld  a, e_vy(ix)
	neg
	ld  e_vy(ix), a
	jr no_mas_saltos
	; /////////////////////////////////////////////////////////////////////////




continuar_saltando:
    		ld  a, e_y(ix)
    		add e_vy(ix)
    		ld  c, a
    		ld  a, e_vy(ix)
    		sub c
    		jr	z, no_mas_saltos
    		jr  nc, parar_salto_vetical  						;; velocidad positiva

		call check_jump_table_update

	jr	no_mas_saltos


only_collision_corner:
	;; COLISIONES CON LAS ESQUINAS DE LOS OBJETOS
	call sys_check_collision_corner
		jr no_mas_saltos
parar_salto_vetical:
	call	end_of_jump
no_mas_saltos:
	;; COLISIONES CON LOS BORDES DE LA PANTALLA
	call sys_check_borderScreem

	_ent_counter = . + 1
	ld	a, #0
	dec 	a
	ret	z

	ld	(_ent_counter), a
	ld	de, #sizeof_e
	add 	ix, de
	jr	_update_loop
;; FIN  -- sys_physics_update --
;; ---------------------------------------------------------------------------------------------------------------------------------------------------- ;;



;;
;; METODO QUE COMPRUEBA LAS VARIABLES DE SALTO
;;
check_jump_tables_init:
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
	ret
;;
;; METODO QUE COMPRUEBA LAS VARIABLES DE SALTO
;;
check_jump_table_update:

    	;; vamos a ver si justo ahora esta pulsada la tecla W
    	ld	a, (press_now_W)
    	cp	#-1
    	ret 	z  					;; ya no saltamos ni para arriba ni lateralmente
	call activar_salto_normal

	;; en la D tengo la variabilidad de la velocidad
	;; si es positiva, llevamos velocidad NEGATIVA = nos movemos con O = right
	;; si es negativa, llevamos velocidad POSITIVA = nos movemos con P = left
    	ld	a, #0
    	add	d      ;; VX corregida

    	ret z						;; 0, SIN VELOCIDIAD

	    	ld  a, e_x(ix)
	    	add e_vx(ix)
	    	ld  c, a
	    	ld  a, e_vx(ix)
	    	sub c
	    	ret  z    
	    	jr  c, jump_left  ;; velocidad positiva
	        ;;velocidad negativa
	        	call active_jump_right 				;; activamos la jump table right
	        ret

jump_left:				;; velocidad positiva
	        	call active_jump_left  				;; activamos la jump table left

	ret

;;
;; METODO QUE NOS CALCULA LOS LIMITES DE PANTALLA Y APLICA VARIABLES VX y vy
;; IMPUT   :  IX: entidad actual
;; DESTROY :  AF, BC
;;
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

;;
;; METODO QUE NOS CALCULA LAS COLISIONES EN LOS 4 EJES
;; IMPUT   :  IX: entidad actual
;; DESTROY :  AF, DA
;; AL SALIR: D y E siguen teniendo el valor que hay que modifcar, lo que nos servira para calcular los saltos en el caso de ser el HEROE
;;
sys_check_collision:

	call man_obstacle_getArray				;; RETURN: - IY puntero a obstaculos
									;;	     - A numero de obstaculos
	call check_collisions					;; RETURN: - D modificacion en e_x
									;;         - E modificacion en e_y

	ld	a, d   						;;tenemos la variacion en el eje X
	add	#0     						;; si no hat colision se debe de quedar en 0
	jr z, no_colision_X
		;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d						;; al tener colision:
            ld    e_x(ix), a   				;; anyadimos esa modicion para que se quede en el borde
no_colision_X:

	ld	a, e							;; tenemos la variacion en el EJE Y
	add	#0							;; si no hay colision se debe de quedar en 0 ( -1 + 1 = 0)

	jr z, no_colision_Y
		;; COLISION EN Y
            ld    a, e_y(ix)
            sub    e						;; al tener colision:
            ld    e_y(ix), a   				;; anyadimos esa modificacion para que se quede en el borde
no_colision_Y:
	ret

;;
;; METODO QUE NOS CALCULA LAS COLISIONES EN LAS 4 ESQUINAS
;; IMPUT   :  IX: entidad actual
;; DESTROY :  AF, BC
;;
sys_check_collision_corner:
	;; si "PUEDE" collision
	;; HAGO EL SUPUESTO DE SUMAR LA VELOCIAD EN Y
	ld	a, e_y(ix)						;; guardo en A la posicion Y de la entidad
	add	e_vy(ix)						;; le sumo la VY
	ld	e_y(ix), a                                ;; se lo aplico a la variable/dato posicion Y de la entidad

	call man_obstacle_getArray				;; Apunto al primer obstaculo
	call check_collisions_corner				;; y al igual que en la colision normal los recorro con: UN EJE YA SUMADO, en este caso el Y

	ld	a, d							;; como la colision por las esquinas las DOS  se modifican (D y E) cojo una y compruebo si es 0 o no
	add	#0		     					;; le anyado 0 para activar el FLAG Z
	jr z, no_colision_X_corner				;; COLLISION = 0 // NO COLLISION != 0
		;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d
            ld    e_x(ix), a   				;; Al aplicarselo en X siempre que entremos por UNA ESQUINA, nos dejara por debajo la cantidad de pixles que hemos entrado simulando la caida dela gravedad
no_colision_X_corner:					
	ld	a, e_y(ix)						;; haya o no colision, vuelvo a dejar la VY como estaba ya que se modifica despues en sys_check_borderScreem
	sub	e_vy(ix)
	ld	e_y(ix), a

	ret




;=====================================================================
;   			¡¡¡¡¡¡¡¡¡  SALTO !!!!!!!!!!
;=====================================================================

;; destruye A
;; Recorremos la tabla de GRAVEDAD
gravedad_hero:

	ld	a, (hero_gravity)					;; guardamos en A la variable gravedad
	cp	#-1
	ret	z							;; si A = -1 NO SALTAR // si A != -1 SI SALTAR/SALTANDO

	;; Get jump value
	ld	hl, #gravity_table  				;; hl primer valor de jump_table
	ld	e, a
	ld 	d, #0
	add	hl, de						;; Se le suma al primer valor de la tabla (HL) el indice actual (A

	;; Comprobar final del salto
	ld	a, (hl)					
	cp	#0x80							;; Comprobamos el indice actual con el ultimo (SIEMPRE ES 0x80 ya que es el maximo numero negativo)
	jr	z, max_gravity					;; si A = 0x80 ESTAMOS EN GRAVEDAD MAXIMA // si A != 0x80 SEGUIMOS RECORRIENDO

	;; Cambia la velocidad segun la tabla
	ld	d, a
	ld	a, e_vy(ix)
	add	d							;; SUMAMOS EN D el indice actual+ VY
	ld	e_vy(ix), a						;; APLICAMOS LA GRAVEDAD ACTUAL A NUESTRA VARIABLE VY (es decir, en el eje Y)

	;; Cambia el indice actual en la tabla
	ld	a, (hero_gravity)					;; COGEMOS EL INDICE ACTUAL
	inc	a							;; LO AUMENTAMOS EN 1
	ld	(hero_gravity), a					;; Y SE LO APLICAMOS 
	ret								;; SALIMOS
	;; se reinicia el satlo
max_gravity:

		ld	a, #4						;; SUMAMOS EN D el indice actual+ VY
		ld	e_vy(ix), a	
		;; MALA PROGRAMACION -- VALOR PUESTO A PELO
		ld	a, #9					;; GUARDAMOS EN A EL INDICE ULTIMO DE NUESTRA TABLA = GRAVEDAD MAXIMA

		ld	(hero_gravity), a
	ret

;; destruye A
;; Recorremos la tabla de salto DERECHA
jump_control_right:

	ld	a, (hero_jump_right)
	cp	#-1
	ret	z	

	;; Get jump value
	ld	hl, #jump_table_right 
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
		ld	a, #-1		

		ld	(hero_jump_right), a
		ld	(V_jumpControlVX_keyboardO), a
	ret
;; Recorremos la tabla de salto ZIQUIERDA
jump_control_left:

	ld	a, (hero_jump_left)
	cp	#-1
	ret	z	

	;; Get jump value
	ld	hl, #jump_table_left 
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
		ld	a, #-1			

		ld	(hero_jump_left), a
		ld	(V_jumpControlVX_keyboardP), a
	ret

;; Recorremos la tabla de salto normal
jump_control:
	ld	a, (hero_jump)
	cp	#-1
	ret	z	

	;; Get jump value
	ld	hl, #jump_table 
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
; Loc contrario a NOT_JUMP, empezamos a saltar
start_jump::

	ld	a, (press_now_W)
	cp	#-1
	jr	nz,  continue_start_jump				;; ya se habia pulsado el salto, me voy

		ld	a, #0
		ld (press_now_W), a
; Limpiar la variable hero_jump ya que si pulsamos en el aire y NO estamos colisionando se queda activa
continue_start_jump:

	ld	a, (hero_jump)
	cp	#-1
	ret	nz								;; ya se habia pulsado el salto, me voy
	ld	a, #0
	ld	(hero_jump), a

	ret
;; inmediatamente después de pulsar la tecla de salto, reseteamos y nps ponemos en estado "NOT PRESS" = -1
not_jump::
	ld	a, (press_now_W)
	cp	#0
	ret	nz								;; ya se habia pulsado el salto, me voy

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
; Saltamos y colisionamos con velocidad POSITIVA
active_jump_left:
	ld	a, (V_jumpControlVY_gravity)
	cp	#-1
	ret	z								;; el valor era -1 y po lo tanto no se esta saltando

	ld	a, (V_jumpControlVX_keyboardP)
	cp	#-1
	ret	z								;; el valor era -1 y po lo tanto no se esta saltando
		ld	a, #0
		;; el control deja de estar en el usuario y se le pasa a la jump table
		ld	(hero_jump_left), a    				;; a 0 es que esta ACTIVO
		ld	(V_jumpControlVX_keyboardP), a    		;; a 0 es que esta ACTIVO
	ret
;  Saltamos y colisionamos con velocidad NEGATIVA
active_jump_right:
	ld	a, (V_jumpControlVY_gravity)
	cp	#-1
	ret	z								;; el valor era -1 y po lo tanto estamos en gravedad
	;; ERROR, NO NOS COGE LA GRAVEDAD EN ESE INSTANTE... .SE ACTUALIZARA DESPUES?

	ld	a, (V_jumpControlVX_keyboardO)
	cp	#-1
	ret	z								;; el valor era -1 y po lo tanto no se esta saltando

		ld	a, #0
		;; el control deja de estar en el usuario y se le pasa a la jump table
		ld	(hero_jump_right), a    			;; a 0 es que esta ACTIVO
		ld	(V_jumpControlVX_keyboardO), a    		;; a 0 es que esta ACTIVO
	ret


