.include "cpctelera.h.s"
.include "cmp/entity.h.s"
.include "sys/collisions.h.s"

;;
;; IMPUT:   IY: puntero a los obstaculos
;;           A: total de obstaculos
;; DESTROY: AF, IY, BC
check_collisions::
	ld	(_obs_counter), a

	ld	d, #0             ;; si A = 0 NO modifico
    ld  e, #0             ;; si A = 0 NO modifico
_update_loop:



    ld  a, e_x(ix)
    add e_vx(ix)
    ld  c, a
    ld  a, e_vx(ix)
    sub c
    jr  z, no_collision_VX    
    jr  c, check_collision_left  ;; velocidad positiva
        ;;velocidad negativa
        call sys_colision_right
        jr no_collision_VX

check_collision_left:
        call sys_colision_left

no_collision_VX:

    ld  a, e_y(ix)
    add e_vy(ix)
    ld  c, a
    ld  a, e_vy(ix)
    sub c
    jr  z, no_collision_VY  
    jr  c, check_collision_top  ;; velocidad positiva
        ;;velocidad negativa
        call sys_colision_bottom
        jr no_collision_VY

check_collision_top:
        call sys_collision_Top
        
no_collision_VY:



	;call sys_collision_Top
	 ;  jr	z, no_puede_haber_collision_bottom

	;call sys_colision_bottom
;no_puede_haber_collision_bottom:

;	call sys_colision_left
 ;       jr  z, no_puede_haber_collision_right

;	call sys_colision_right
;no_puede_haber_collision_right:

	_obs_counter = . + 1
		ld	a, #0  ;; 1
		dec	a      ;; 0
		ret 	z

		ld	(_obs_counter), a
		ld	bc, #sizeof_obs
		add	iy, bc
		jr	_update_loop

ret




;;
;; IMPUT:   IY: puntero a los obstaculos
;;           A: total de obstaculos
;; DESTROY: AF, IY, BC
check_collisions_corner::
    ld  (_obs_counter_corner), a

    ld  d, #0             ;; si A = 0 NO modifico
_update_loop_corner:

    call sys_colision_left
        jr  z, no_puede_haber_collision_right_corner

    call sys_colision_right
no_puede_haber_collision_right_corner:

    _obs_counter_corner = . + 1
        ld  a, #0  ;; 1
        dec a      ;; 0
        ret     z

        ld  (_obs_counter_corner), a
        ld  bc, #sizeof_obs
        add iy, bc
        jr  _update_loop_corner

ret



;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_collision_Top:
    ld    	a, e_y(ix)
    add    	e_h(ix)
    add    	e_vy(ix)
    sub    	obs_y(iy)    ;; e_y + e_h + e_vy - obs_y  72+8+2 - 80 = 2 HAY COLISION -- deberia de corregir a 83 -1 = 82

    ret	c            ;; Si es negativo NO HAY COLISION
    ret	z            ;; Si es 0, NO HAY COLISION

    cp	obs_h(iy)
    ret	nc	
    ;; HAY COLISION EN EJE  Y
    call sys_collision_Y    ;; comprobamos si hay colision en eje x tambien

    ret
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_colision_bottom:
	ld    	a, e_y(ix)
    add    	e_vy(ix)
    sub    	obs_y(iy)    ;; e_y + e_h + e_vy - obs_y  72+8+2 - 80 = 2 HAY COLISION -- deberia de corregir a 83 -1 = 82
    sub		obs_h(iy)

    ret	nc            ;; Si es positivo o 0 NO HAY COLISION

    neg 				;; va a ser positivo
    cp	obs_h(iy)
    ret	nc
    neg
    ;; HAY COLISION EN EJE  Y
    call sys_collision_Y

    ret
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_colision_left:
	ld    	a, e_x(ix)
	add		e_w(ix)
    add    	e_vx(ix)
    sub    	obs_x(iy) 

    ret	c            ;; Si es negativo o 0 NO HAY COLISION
    ret	z

    cp	obs_w(iy)	;; se comprueba si atraviesa
    ret	nc			;; si el resultado es positivo pasa por el otro lado
    ;; HAY COLISION EN EJE  X
    call sys_collision_X

	ret
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_colision_right:
	ld    	a, e_x(ix)
    add    	e_vx(ix)
    sub    	obs_x(iy)
    sub		obs_w(iy)

    ret	nc            ;; Si es positivo o 0 NO HAY COLISION

    neg
    cp	obs_w(iy)	;; se comprueba si atraviesa
    ret	nc			;; si el resultado es positivo pasa por el otro lado
    neg
    ;; HAY COLISION EN EJE  X
    call sys_collision_X

	ret

;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_collision_Y:
    ;; Y tenemos en el Reg A el tamanyo en pixeles de la colision
    ex    af, af'

    ld      a, obs_x(iy)
    sub     e_x(ix)
    sub     e_w(ix)
    ;; Si es mayor o igual a 0 NO hay colision, ESTA POR LA IZQUIERDA
    jr    nc, no_collision_EX
        ;; Cumple 1 condicion
        ld      a, obs_x(iy)
        add     obs_w(iy)
        sub     e_x(ix)
          ;; Si es menor o igual a 0 NO hay colision, ESTA POR LA DERECHA
        jr    c, no_collision_EX
        jr    z, no_collision_EX

            ;; SI COLISION RIGHT
            ex af, af'
            ld  e, a

            xor a      ;; devuelvo 0 para no comprobar en bottom

            ret

no_collision_EX:
    ;; Aun podria colisionar en EX+EW
    ld    a, e_x(ix)
    add    e_w(ix)
    sub    obs_x(iy)
    ;; si es negativo o es 0, ESTA POR LA DERECHA
    jr    c, no_collision_EX_EW
    jr    z, no_collision_EX_EW
        ;; Cumple una condicion
        ld    a, e_x(ix)
        sub   obs_x(iy)
        sub    obs_w(iy)
          ;; Si es menor o igual a 0 NO hay colision, ESTA POR LA DERECHA
        jr    nc, no_collision_EX_EW
            ;; SI COLISION RIGHT
            ex af, af'
            ld e, a

            xor a      ;; devuelvo 0 para no comprobar en bottom

no_collision_EX_EW:
    ret
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sys_collision_X:
    ;; Y tenemos en el Reg A el tamanyo en pixeles de la colision
    ex    af, af'

    ld      a, obs_y(iy)
    sub     e_y(ix)
    sub     e_h(ix)
    ;; Si es mayor o igual a 0 NO hay colision, ESTA POR LA IZQUIERDA
    jr    nc, no_collision_EY
        ;; Cumple 1 condicion
        ld      a, obs_y(iy)
        add     obs_h(iy)
        sub     e_y(ix)
          ;; Si es menor o igual a 0 NO hay colision, ESTA POR  abajo
        jr    c, no_collision_EY
        jr    z, no_collision_EY

            ;; SI COLISION RIGHT
            ex af, af'
            ld    d, a

            xor a      ;; devuelvo 0 para no comprobar en right

            ret

no_collision_EY:
    ;; Aun podria colisionar en EY+EW
    ld    a, e_y(ix)
    add    e_h(ix)
    sub    obs_y(iy)
    ;; si es negativo o es 0, ESTA POR Arriba
    jr    c, no_collision_EY_EW
    jr    z, no_collision_EY_EW
        ;; Cumple una condicion
        ld    a, e_y(ix)
        sub   obs_y(iy)
        sub    obs_h(iy)
          ;; Si es menor o igual a 0 NO hay colision, ESTA POR  abajo
        jr    nc, no_collision_EY_EW
            ;; SI COLISION RIGHT
            ex af, af'
            ld    d, a

            xor a      ;; devuelvo 0 para no comprobar en right

no_collision_EY_EW:
    ret


