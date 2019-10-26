;;
;; ENTITY PHYSICS MOVEMENTS
;;
.include "cpctelera.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/entity.h.s"
.include "man/man_obstacle.h.s"
.include "sys/collisions.h.s"
.include "man/sprite.h.s"
.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"
.include "sys/sys_calc.h.s"
.include "man/game.h.s" ; cambiar por man_obstacles
.include "sys/sys_music.h.s"
.include "sys/ai_control.h.s"


.module sys_entity_physics

;; Physics system constants
screen_width  = 80
screen_height = 200	
;;
;; VARIABLES CONTROL DEL SALTO Y REBOTES
;;
V_jumpControlVY_gravity:      .db #-1     ;; -1 GRAVITY     // 0 JUMP CONTROL
V_jumpControlVX_keyboardO:    .db #1      ;; -1 KEYBOARD    // 0 JUMP CONTROL           // 1 PRIMER SALTO
V_jumpControlVX_keyboardP:    .db #1      ;; -1 KEYBOARD    // 0 JUMP CONTROL          // 1 PRIMER SALTO
hero_jump:                    .db #-1           ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_left:               .db #-1     ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_right:              .db #-1     ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_gravity:                 .db #0      ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
press_now_W:                  .db #-1     ;; variable que nos indica si estamos saltando justo en ese momento
gravity_babosa:               .db #1
;spittle:            .db #6         ;; el numero de saliva es lo que le restamos a la gravedad 
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
;;    RETURN: A - valor de salto lateral
;; DESTROY: AF
;;
get_hero_jump_left::
   ld a, (hero_jump_left)
ret

get_hero_jump_right::
   ld a, (hero_jump_right)
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
   ld (_ent_counter), a


	;call set_sprite_hero
	;; commprobamos si somos el HEROE o un ENEMIGO para pocesar el salto
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_noAI	;; comparamos si no tiene IA
	jr	nz, _update_loop
		;; SOMOS EL HEROE
		call check_jump_tables_init 

   ;call man_obstacle_re_rellenar_array
   ;call man_obstacle_getArray ; como en la llamada anterior hemos consultado los arrays, nos posicionamos de nuevo en la primera posición
   ;call man_entity_getArray
;; BUCLE QUE RECORRE TODAS LAS ENTIDADES CON FISICAS 
_update_loop:

;=============================================================================================================================================
;; SI ESTAMOS MUERTOS NO SE ACTUALIZA EL PHYSICS - UNICAMENTE RENDERIZAREMOS ANIMACION EXPLOSION
;=============================================================================================================================================
   ld    a, e_dead(ix)                 ;; se crean con valor = 0 (vivos), con el valor =1 (muertas)
   cp    #0                            
   jr    nz, continuar_actualizar_pos   ;; lo que implica que pasaremos a la siguiente entidad

   cpctm_setBorder_asm HW_GREEN

   push ix
   call man_obstacle_re_rellenar_array
   call man_obstacle_getArray ; como en la llamada anterior hemos consultado los arrays, nos posicionamos de nuevo en la primera posición
   pop ix

;================================================================================
;; ESTO ES LO TUYO VALDES !!!!!!!!!!!!!!!!!!!!!!!!!1
   call check_diferent_obstacles
;=================================================================================

   cpctm_setBorder_asm HW_RED
   ;; COLISIONES CON LOS OBJETOS
   call sys_check_collision


   ld a, d
   add   e
   jr nz, equals        ; !=0 hay colisiones en las esquinas 

      ld a, #0
      add   d
      jr z, only_collision_corner                  ;; SI UNA DE LAS DOS ES 0, LAS DOS LO ERAN (D y E) y por tanto comprobar colisiones en las esquinas
equals:  ;; si no son iguales HA HABIDO COLISION SEGURO
   ld a, e_ai_st(ix)
   cp #e_ai_st_noAI
   jr z, continuar_saltando



	; ////////////////////////////////////////////////////////////////////////////////
	;; colisiones ENEMIGOS ///////////////////////////////////////////////////////////
	call physics_IA_enemigos
	jr no_mas_saltos
	; ////////////////////////////////////////////////////////////////////////////////
	; ////////////////////////////////////////////////////////////////////////////////


continuar_saltando:
    		ld  a, e_vy(ix)
         cp   #0
    		jr	z, no_mas_saltos
    		;jp  m, parar_salto_vetical  						;; velocidad positiva
         jp m, no_mas_saltos

      call check_jump_table_update


   jr no_mas_saltos


only_collision_corner:
   ;; COLISIONES CON LAS ESQUINAS DE LOS OBJETOS
   call sys_check_collision_corner
      jr no_mas_saltos

;parar_salto_vetical:
   ;call  end_of_jump

no_mas_saltos:
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_patrullar
	jr	z, no_mas_saltos_patrullar


   ld a, e_ai_st(ix)
   cp #e_ai_st_perseguir
   jr z, no_mas_saltos_perseguir
	;; COLISIONES CON LOS BORDES DE LA PANTALLA y actualizar pos
	  call sys_check_borderScreem
	jr continuar_actualizar_pos

no_mas_saltos_patrullar:
	call sys_check_borderScreem_patrullar ;; COLISIONES CON LOS BORDES DE LA PANTALLA y actualizar pos para la IA patrullar
   jr continuar_actualizar_pos
no_mas_saltos_perseguir:
   call sys_check_borderScreem_patrullar2 ;; COLISIONES CON LOS BORDES DE LA PANTALLA y actualizar pos para la IA patrullar
continuar_actualizar_pos:



   ;cpctm_setBorder_asm HW_GREEN


	_ent_counter = . + 1
	ld	a, #0
	dec 	a
	ret	z

   ld (_ent_counter), a
   ld de, #sizeof_e
   add   ix, de
   jr _update_loop
;; FIN  -- sys_physics_update --
;; ---------------------------------------------------------------------------------------------------------------------------------------------------- ;;



;;
;;
;;
check_diferent_obstacles:
   call man_obstacle_get_valor_tile_por_pos_memoria_cargada
   or a
   jr z, todo_fondo
   dec a
   jr z, morir
   dec a
   jr z, pasar_nivel

   pasar_nivel:                  ;; pasa al siguiente nivel
      call comprobarFinalJuego
      dec   a
      jr    z, todo_fondo
      call man_level_load_next
      call man_tilemap_load
      call man_tilemap_render
      call man_level_render
      call setDificultadEnemigos
      jr   todo_fondo

   morir:
      ld e_dead(ix), #1
      call sys_music_sonar_Explosion  ;; jugador con pinchos
   todo_fondo:
   ret



;;
;; METODO QUE COMPRUEBA LAS VARIABLES DE SALTO
;;
check_jump_tables_init:
      ;; CONTROLAMOS SI ESTAMOS SALTANDO O ESTAMOS CAYENDO CON GRAVEDAD
      ld a, (V_jumpControlVY_gravity)
      cp #-1
      jr z, aplicate_gravity  ;; SI EL VALOR ERA -1 APLICAMOS GRAVEDAD
         call jump_control
      jr no_gravity
aplicate_gravity:
      call  gravedad_hero
no_gravity:

      ;; CONTROLAMOS SI ESTAMOS SALTANDO LATERALMENTE POR LA DERECHA
      ld a, (V_jumpControlVX_keyboardO)
      cp #-1
      jr z, not_aplicate_jump_table_right    ;; SI EL VALOR ERA -1 NO TABLA DE SALTO DERECHA
         call jump_control_right
not_aplicate_jump_table_right:

      ;; CONTROLAMOS SI ESTAMOS SALTANDO LATERALMENTE POR LA IZQUIERDA
      ld a, (V_jumpControlVX_keyboardP)
      cp #-1
      jr z, not_aplicate_jump_table_left  ;; SI EL VALOR ERA -1 NO TABLA DE SALTO IZQUIERDA
         call jump_control_left
not_aplicate_jump_table_left:
   ret
;;
;; METODO QUE COMPRUEBA LAS VARIABLES DE SALTO
;;
check_jump_table_update:

      ;; vamos a ver si justo ahora esta pulsada la tecla W
      ld a, (press_now_W)
      cp #-1
      ret   z                 ;; ya no saltamos ni para arriba ni lateralmente
   call activar_salto_normal

   ;; en la D tengo la variabilidad de la velocidad
   ;; si es positiva, llevamos velocidad NEGATIVA = nos movemos con O = right
   ;; si es negativa, llevamos velocidad POSITIVA = nos movemos con P = left
      ld a, #0
      add   d      ;; VX corregida

      ret z                ;; 0, SIN VELOCIDIAD

         ld  a, e_vx(ix)
         cp  #0
         ret  z    
         jp  p, jump_left  ;; velocidad positiva
           ;;velocidad negativa
            call active_jump_right           ;; activamos la jump table right
           ret

jump_left:           ;; velocidad positiva
            call active_jump_left            ;; activamos la jump table left

   ret

;;
;; METODO QUE NOS CALCULA LOS LIMITES DE PANTALLA Y APLICA VARIABLES VX y vy
;; IMPUT   :  IX: entidad actual
;; DESTROY :  AF, BC
;;
sys_check_borderScreem:
   ;; UPDATE X
   ld a, e_x(ix)
   add   e_vx(ix)
   ld e_x(ix), a
   ;; UPDATE Y
   ld a, e_y(ix)
   add   e_vy(ix)
   ld e_y(ix), a


   ret

;;
;; METODO QUE NOS CALCULA LAS COLISIONES EN LOS 4 EJES
;; IMPUT   :  IX: entidad actual
;; DESTROY :  AF, DA
;; AL SALIR: D y E siguen teniendo el valor que hay que modifcar, lo que nos servira para calcular los saltos en el caso de ser el HEROE
;;
sys_check_collision:

   call man_obstacle_getArray          ;; RETURN: - IY puntero a obstaculos
                                       ;;      - A numero de obstaculos
   call check_collisions_VX               ;; RETURN: - D modificacion en e_x
                           ;;         - E modificacion en e_y

   ld a, d                    ;;tenemos la variacion en el eje X
   add   #0                      ;; si no hat colision se debe de quedar en 0
   jr z, no_colision_X
      ;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d                ;; al tener colision:
            ld    e_x(ix), a              ;; anyadimos esa modicion para que se quede en el borde
;===============================================================================================================================
      ;; RESVALAR
      ;; SOLO SI SOMOS EL HERO
      ld    a, e_ai_st(ix)
      cp    #e_ai_st_noAI
      jr    nz, no_colision_X
      ld    a, #2
      cp    e_vy(ix)
      jp    p, no_colision_X
         ld    e_vy(ix), a
;===============================================================================================================================
no_colision_X:
   call man_obstacle_getArray 
   call check_collisions_VY

   ld a, e                    ;; tenemos la variacion en el EJE Y
   add   #0                   ;; si no hay colision se debe de quedar en 0 ( -1 + 1 = 0)

   jr z, no_colision_Y
      ;; COLISION EN Y
            ld    a, e_y(ix)
            sub    e                ;; al tener colision:
            ld    e_y(ix), a              ;; anyadimos esa modificacion para que se quede en el borde
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
   ld a, e_y(ix)                 ;; guardo en A la posicion Y de la entidad
   add   e_vy(ix)                ;; le sumo la VY
   ld e_y(ix), a                                ;; se lo aplico a la variable/dato posicion Y de la entidad

   call man_obstacle_getArray          ;; Apunto al primer obstaculo
   call check_collisions_corner           ;; y al igual que en la colision normal los recorro con: UN EJE YA SUMADO, en este caso el Y

   ld a, d                    ;; como la colision por las esquinas las DOS  se modifican (D y E) cojo una y compruebo si es 0 o no
   add   #0                      ;; le anyado 0 para activar el FLAG Z
   jr z, no_colision_X_corner          ;; COLLISION = 0 // NO COLLISION != 0
      ;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d
            ld    e_x(ix), a              ;; Al aplicarselo en X siempre que entremos por UNA ESQUINA, nos dejara por debajo la cantidad de pixles que hemos entrado simulando la caida dela gravedad
no_colision_X_corner:               
   ld a, e_y(ix)                 ;; haya o no colision, vuelvo a dejar la VY como estaba ya que se modifica despues en sys_check_borderScreem
   sub   e_vy(ix)
   ld e_y(ix), a

   ret












;;
;; PROCESS COLLISION ENEMY-ENEMY
;; change direccion entity IX (for example)
;; IMPUT: IX - FIRST ENEMY
;;        IY - SECOND ENEMY
;;
change_direcction_entity::
   ;ld    a, e_ai_st(ix)
   ;cp    #e_ai_st_patrullar
   ;jr    nz, change_direcction       ;; con aereo siempre camiar velocidades

   ;ld    a, e_ai_st(iy)
   ;cp    #e_ai_st_patrullar
   ;jr    nz, change_direcction       ;; con aereo siempre cambiar velocidades

   ld    a, e_ai_st(ix)
   cp    #e_ai_st_patrullar
   jr    nz, change_direcction      ;; La primera NO es una babosa

   ld    a, e_ai_st(iy)
   cp    #e_ai_st_patrullar
   jr    nz, change_direcction       ;; La segunda NO es babosa

   ;; Las dos son babosas
   ld    a, e_y(ix)
   cp    e_y(iy)
   jr    z, change_direcction
      ;; NO ESTAMOS A LA MISMA ALTURA -- BLOQUEAR A LA QUE ESTA MAS ARRIBA
      ;     x       
      ;  ----------------------
      ;               x
   jp    m, iy_on_ix

      ld    a, (gravity_babosa)
      cp    #0
      jp    m, gravity_negative1
         ;; si gravedad hacia arriba
         ld    a,  e_vy(ix)
         neg
         add   e_y(ix)
         ld    e_y(ix), a
   ret
gravity_negative1:
         ;; si gravedad hacia abajo
         ld    a, e_vy(iy)
         neg
         add   e_y(iy)
         ld    e_y(iy), a
   ret

iy_on_ix:
      ld    a, (gravity_babosa)
      cp    #0
      jp    m, gravity_negative2
         ;; si gravedad hacia arriba
         ld    a,  e_vy(iy)
         neg
         add   e_y(iy)
         ld    e_y(iy), a
   ret
gravity_negative2:
         ;; si gravedad hacia abajo
         ld    a, e_vy(ix)
         neg
         add   e_y(ix)
         ld    e_y(ix), a
   ret

change_direcction:
   ;; ESTAMOS EN LA MISMTA ALTURA
   ;     x       x
   ;  ----------------------
   ;
;; Hay que comprbar si estamos en modo perseguir o en modo defensa, en caso contrario nos cargamos la otra entidad
   ld    a, e_ai_st(ix)
   cp    #e_ai_st_perseguir
   jr    nz, next_ix_per       ;; con aereo siempre camiar velocidades
         ld    a, e_dead(iy)
         cp    #0
         ret nz
         ld    a, #1
         ld    e_dead(iy), a
         call sys_music_sonar_Explosion  ; aereo perseguir mata baobsa
      ret
next_ix_per:
   ld    a, e_ai_st(ix)
   cp    #e_ai_st_defender
   jr    nz, next_iy_per       ;; con aereo siempre cambiar velocidades
         ld    a, e_dead(iy)
         cp    #0
         ret nz
         ld    a, #1
         ld    e_dead(iy), a
         call sys_music_sonar_Explosion    ; aereo defender mata baobsa
      ret
next_iy_per:
;; Hay que comprbar si estamos en modo perseguir o en modo defensa, en caso contrario nos cargamos la otra entidad
   ld    a, e_ai_st(iy)
   cp    #e_ai_st_perseguir
   jr    nz, next_iy_per2       ;; con aereo siempre camiar velocidades
         ld    a, e_dead(ix)
         cp    #0
         ret nz
         ld    a, #1
         ld    e_dead(ix), a
         call sys_music_sonar_Explosion    ; aereo perseguir mata baobsa
         ret
next_iy_per2:
   ld    a, e_ai_st(iy)
   cp    #e_ai_st_defender
   jr    nz, aplicate_normal       ;; con aereo siempre cambiar velocidades
         ld    a, e_dead(ix)
         cp    #0
         ret nz
         ld    a, #1
         ld    e_dead(ix), a
         call sys_music_sonar_Explosion    ; aereo defender mata baobsa
      ret

aplicate_normal:

;; QUEDA REFACTORIZAR SEGUN LA ENRADA DE LAS ENTIDADES -- 
;; SI LA COLISION SE DIFERENCIA POR MAS DE 1 --

   ld    a,  e_x(ix)
   sub   e_x(iy)
   cp    #-2
   jp    m, not_dead
   cp    #2
   jp    p, not_dead

      ld    a, e_dead(iy)
      cp    #0
      ret nz
      ld    a, #1
      ld    e_dead(iy), a
      call sys_music_sonar_Explosion
   ret

not_dead:

   ld    a,  e_vx(ix)
   neg
   ld    e_vx(ix), a         ;; negamos la velocidad en el eje X
   add    e_x(ix)            ;; se lo anyadimos a la posicion
   ld    e_x(ix), a          ;; aplicamos posicion final 

   ld    a, e_vx(iy)         ;; cogemos la velocidad en vx
   neg                       ;; la negamos
   ld    e_vx(iy), a        ;; negamos la velocidad en el eje Y
   add    e_x(iy)            ;; se lo anyadimos a la posicion
   ld    e_x(iy), a          ;; aplicamos posicion final 

 ret






;   ld    a, e_x(ix)
;   cp    e_x(iy)
;   ret   z
;   jp    m, ix_before_iy

;iy_before_ix:
;   ld    a, e_x(iy)
;   add   e_w(iy)             ;; IX : pos + ancho
;   sub   e_x(ix)             ;;  - IY:  pos
;   cp    #1
;   jr    nz, iy_probar_con_2
;      ld    a, e_vx(ix)         ;; cogemos la velocidad en vx
;      add    e_x(ix)            ;; se lo anyadimos a la posicion
;      ld    e_x(ix), a          ;; aplicamos posicion final 
;   ret
;iy_probar_con_2:
;   ld    a, e_x(iy)
;   add   e_w(iy)             ;; IX : pos + ancho
;   sub   e_x(ix)             ;;  - IY:  pos
;   cp    #2
;   ret    nz
;      ld    a, e_vx(ix)         ;; cogemos la velocidad en vx
;      add    e_x(ix)            ;; se lo anyadimos a la posicion
;      ld    e_x(ix), a          ;; aplicamos posicion final 

;      ld    a, e_vx(iy)         ;; cogemos la velocidad en vx
;      add    e_x(iy)            ;; se lo anyadimos a la posicion
;      ld    e_x(iy), a          ;; aplicamos posicion final 
;   ret

;ix_before_iy:
;   ld    a, e_x(ix)
;   add   e_w(ix)             ;; IX : pos + ancho
;   sub   e_x(iy)             ;;  - IY:  pos
;   cp    #1
;   jr    nz, ix_probar_con_2
;      ld    a, e_vx(iy)         ;; cogemos la velocidad en vx
;      add    e_x(iy)            ;; se lo anyadimos a la posicion
;      ld    e_x(iy), a          ;; aplicamos posicion final 
;   ret
;ix_probar_con_2:
;   ld    a, e_x(ix)
;   add   e_w(ix)             ;; IX : pos + ancho
;   sub   e_x(iy)             ;;  - IY:  pos
;   cp    #2
;   ret    nz
;      ld    a, e_vx(iy)         ;; cogemos la velocidad en vx
;      add    e_x(iy)            ;; se lo anyadimos a la posicion
;      ld    e_x(iy), a          ;; aplicamos posicion final 

;      ld    a, e_vx(ix)         ;; cogemos la velocidad en vx
;      add    e_x(ix)            ;; se lo anyadimos a la posicion
;      ld    e_x(ix), a          ;; aplicamos posicion final 
;   ret



;=====================================================================
;           ¡¡¡¡¡¡¡¡¡  SALTO !!!!!!!!!!
;=====================================================================

;; destruye A
;; Recorremos la tabla de GRAVEDAD
gravedad_hero:

   ld a, (hero_gravity)             ;; guardamos en A la variable gravedad
   cp #-1
   ret   z                    ;; si A = -1 NO SALTAR // si A != -1 SI SALTAR/SALTANDO

   ;; Get jump value
   ld hl, #gravity_table            ;; hl primer valor de jump_table
   ld e, a
   ld    d, #0
   add   hl, de                  ;; Se le suma al primer valor de la tabla (HL) el indice actual (A

   ;; Comprobar final del salto
   ld a, (hl)              
   cp #0x80                   ;; Comprobamos el indice actual con el ultimo (SIEMPRE ES 0x80 ya que es el maximo numero negativo)
   jr z, max_gravity             ;; si A = 0x80 ESTAMOS EN GRAVEDAD MAXIMA // si A != 0x80 SEGUIMOS RECORRIENDO

   ;; Cambia la velocidad segun la tabla
   ld d, a
   ld a, e_vy(ix)
   add   d                    ;; SUMAMOS EN D el indice actual+ VY
   ld e_vy(ix), a                ;; APLICAMOS LA GRAVEDAD ACTUAL A NUESTRA VARIABLE VY (es decir, en el eje Y)

   ;; Cambia el indice actual en la tabla
   ld a, (hero_gravity)             ;; COGEMOS EL INDICE ACTUAL
   inc   a                    ;; LO AUMENTAMOS EN 1
   ld (hero_gravity), a             ;; Y SE LO APLICAMOS 
   ret                        ;; SALIMOS
   ;; se reinicia el satlo
max_gravity:

		ld	a, #4						;; SUMAMOS EN D el indice actual+ VY
		ld	e_vy(ix), a	
		;; MALA PROGRAMACION -- VALOR PUESTO A PELO
		ld	a, #9					;; GUARDAMOS EN A EL INDICE ULTIMO DE NUESTRA TABLA = GRAVEDAD MAXIMA

      ld (hero_gravity), a
   ret

;; destruye A
;; Recorremos la tabla de salto DERECHA
jump_control_right:

   ld a, (hero_jump_right)
   cp #-1
   ret   z  

   ;; Get jump value
   ld hl, #jump_table_right 
   ld e, a
   ld    d, #0
   add   hl, de

   ;; Comprobar final del salto
   ld a, (hl)
   cp #0x80
   jr z, end_of_jump_right

   ;; Cambia la velocidad segun la tabla
   ld d, a
   ld a, e_vx(ix)
   add   d
   ld e_vx(ix), a

   ;; Cambia el indice actual en la tabla
   ld a, (hero_jump_right)
   inc   a
   ld (hero_jump_right), a
   ret
   ;; se reinicia el satlo
end_of_jump_right:
      ld a, #-1      

      ld (hero_jump_right), a
      ld (V_jumpControlVX_keyboardO), a
   ret
;; Recorremos la tabla de salto ZIQUIERDA
jump_control_left:

   ld a, (hero_jump_left)
   cp #-1
   ret   z  

   ;; Get jump value
   ld hl, #jump_table_left 
   ld e, a
   ld    d, #0
   add   hl, de

   ;; Comprobar final del salto
   ld a, (hl)
   cp #0x80
   jr z, end_of_jump_left

   ;; Cambia la velocidad segun la tabla
   ld d, a
   ld a, e_vx(ix)
   add   d
   ld e_vx(ix), a

   ;; Cambia el indice actual en la tabla
   ld a, (hero_jump_left)
   inc   a
   ld (hero_jump_left), a
   ret
   ;; se reinicia el satlo
end_of_jump_left:
      ld a, #-1         

      ld (hero_jump_left), a
      ld (V_jumpControlVX_keyboardP), a
   ret

;; Recorremos la tabla de salto normal
jump_control:
   ld a, (hero_jump)
   cp #0
   jr nz, seguir_jumpControl
   call sys_music_sonar_Salto  ; sonido de salto
   seguir_jumpControl:  

   ld a, (hero_jump)
   cp #-1
   ret   z 
      
   ;; Get jump value
   ld hl, #jump_table 
   ld e, a
   ld    d, #0
   add   hl, de

   ;; Comprobar final del salto
   ld a, (hl)
   cp #0x80
   jr z, end_of_jump

   ;; Cambia la velocidad segun la tabla
   ld d, a
   ld a, e_vy(ix)
   add   d
   ld e_vy(ix), a

   ;; Cambia el indice actual en la tabla
   ld a, (hero_jump)
   inc   a
   ld (hero_jump), a
   ret
   ;; se reinicia el satlo
end_of_jump:
      ld a, #-1

      ld (hero_jump), a
      ld    (V_jumpControlVY_gravity), a

      ld a, #0
      ld (hero_gravity), a
      ld a, #1
      ;; cuando acabo del salto, la vuelvo a poner a 1 para volverlo a hacer
      ld (V_jumpControlVX_keyboardO), a
      ld (V_jumpControlVX_keyboardP), a
   ret

;; Modifica A
; Loc contrario a NOT_JUMP, empezamos a saltar
start_jump::

   ld a, (press_now_W)
   cp #-1
   jr nz,  continue_start_jump            ;; ya se habia pulsado el salto, me voy

      ld a, #0
      ld (press_now_W), a
      
; Limpiar la variable hero_jump ya que si pulsamos en el aire y NO estamos colisionando se queda activa
continue_start_jump: 
   ld a, (hero_jump)
   cp #-1
   ret   nz                      ;; ya se habia pulsado el salto, me voy
   ld a, #0
   ld (hero_jump), a

   ret
;; inmediatamente después de pulsar la tecla de salto, reseteamos y nps ponemos en estado "NOT PRESS" = -1
not_jump::
   ld a, (press_now_W)
   cp #0
   ret   nz                      ;; ya se habia pulsado el salto, me voy

      ld a, #-1
      ld (press_now_W), a

   ret
;;
;; SI ENTRAMOS AQUI ES QUE ESTAMOS COLISIONANDO CON UN OBJETO
;; Y SI A LA VEZ EL HER0_JUMP ESTA A 0, ES QUE HEMOS PULSADO 
;; TECLA DE SALTO, POR LO QUE ACTIVAMOS EL SALTO NORMAL
;; RECORDAR TENER VELOCIDAD NEGATIVA
;;
activar_salto_normal:

   ld a, (hero_jump)
   cp #-1
   ret   z  ;; el valor era -1 y po lo tanto no se esta saltando
   ;; SI  LLEGAMOS HASTA AQUI ES QUE:
      ;; 1 - SE HA PULSADO LA TECLA DE SALTAR
      ;; 2 - ESTAMOS COLISIONANDO
      ;; 3 - MI VELOCIDAD EN EL EJE Y ES NEGATIVA
      ld a, #0
      ;ld   (hero_jump_active), a    ;; a 0 es que esta ACTIVO
      ;; LE DAMOS EL CONTROL AL JUMP COMTRL
      ld (V_jumpControlVY_gravity), a
   ret
; Saltamos y colisionamos con velocidad POSITIVA
active_jump_left:
   ld a, (V_jumpControlVY_gravity)
   cp #-1
   ret   z                       ;; el valor era -1 y po lo tanto no se esta saltando

   ld a, (V_jumpControlVX_keyboardP)
   cp #-1
   ret   z                       ;; el valor era -1 y po lo tanto no se esta saltando
      ld a, #0
      ;; el control deja de estar en el usuario y se le pasa a la jump table
      ld (hero_jump_left), a              ;; a 0 es que esta ACTIVO
      ld (V_jumpControlVX_keyboardP), a         ;; a 0 es que esta ACTIVO
   ret
;  Saltamos y colisionamos con velocidad NEGATIVA
active_jump_right:
   ld a, (V_jumpControlVY_gravity)
   cp #-1
   ret   z                       ;; el valor era -1 y po lo tanto estamos en gravedad
   ;; ERROR, NO NOS COGE LA GRAVEDAD EN ESE INSTANTE... .SE ACTUALIZARA DESPUES?

   ld a, (V_jumpControlVX_keyboardO)
   cp #-1
   ret   z                       ;; el valor era -1 y po lo tanto no se esta saltando

		ld	a, #0
		;; el control deja de estar en el usuario y se le pasa a la jump table
		ld	(hero_jump_right), a    			;; a 0 es que esta ACTIVO
		ld	(V_jumpControlVX_keyboardO), a    		;; a 0 es que esta ACTIVO
	ret








; ////////////////////////////////////////
; ENEMIGOS
physics_IA_enemigos:
	ld	a, e_ai_st(ix)
	cp	#e_ai_st_rebotar
	jr	nz, enemigo_patrullar_physic
	ld 	a, (#col_hay_colision_top)
	dec 	a
   ;ld    a, d
   ;cp    #0
	jr 	nz, comprobar_vel_Y
	ld  	a, e_vx(ix)
	neg
	ld  	e_vx(ix), a

	comprobar_vel_Y:
	ld 	a, (#col_hay_colision_left)
	dec 	a
   ;ld    a, c
   ;cp    #0
	ret	nz

	ld  	a, e_vy(ix)
	neg
	ld  	e_vy(ix), a
	ret

	; IA PATRULLAR
	enemigo_patrullar_physic:
	ld	  a, e_ai_st(ix)
	cp	  #e_ai_st_patrullar
	jr   nz, enemigo_perseguir_physic
	ld 	a, (#col_hay_colision_top)
	dec 	a
   ;ld    a, d
   ;cp    #0
	ret   nz
	ld  	a, e_vx(ix)
	neg
	ld  	e_vx(ix), a
   ld    (gravity_babosa), a
    ret

    ; IA PERSEGUIR
   enemigo_perseguir_physic:
   ld    a, e_ai_st(ix)
   cp    #e_ai_st_perseguir
   ret   nz
   ld    a, (#col_hay_colision_top)
   dec   a
   jr    nz, comprobar_PhysicsIA_left
   ld    a, #e_ai_st_rebotar
   ld    e_ai_st(ix), a
   ld    e_ai_rebotar_chocar(ix), #1
   ret
   comprobar_PhysicsIA_left:
   ld    a, (#col_hay_colision_left)
   dec   a
   ret   nz
   ld    a, #e_ai_st_rebotar
   ld    e_ai_st(ix), a
   ld    e_ai_rebotar_chocar(ix), #1
	ret




;; CHOQUES CON LOS BORDES DE LA PANTALLA
sys_check_borderScreem_patrullar:

	;; UPDATE Y
	call sys_check_borderScreem_patrullar_Y

	;; TEMPORIZADOR
	ld  a, e_ai_pausaVel(ix)
	cp  #0
	jr  nz, patrullar_reiniciarPausa
	ld  a, #10
	ld  e_ai_pausaVel(ix), a

	ld 	a, (#col_hay_colision_left) ;; comprobar si estas en el aire para moverte
	dec 	a
	ret 	nz

	;; UPDATE X
	call sys_check_borderScreem_patrullar_X
	ret
patrullar_reiniciarPausa:
	ld  a, e_ai_pausaVel(ix)
	dec   a
	ld  e_ai_pausaVel(ix), a
	ret



;; UPDATE Y
sys_check_borderScreem_patrullar_Y:
	;; UPDATE Y
	ld	  a, e_y(ix)
	add  e_vy(ix)
	ld	  e_y(ix), a
	ret

;; UPDATE X
sys_check_borderScreem_patrullar_X:
	ld	  a, e_x(ix)
	add  e_vx(ix)
	ld	  e_x(ix), a
	ret
	






;; CHOQUES CON LOS BORDES DE LA PANTALLA
sys_check_borderScreem_patrullar2:

   ;; TEMPORIZADOR
   ld  a, e_ai_pausaVel(ix)
   cp  #0
   jr  nz, patrullar_reiniciarPausa2
   ld  a, #3
   ld  e_ai_pausaVel(ix), a


   ;; UPDATE Y
   call sys_check_borderScreem_patrullar_Y2
   ;; UPDATE X
   call sys_check_borderScreem_patrullar_X2
   ret
patrullar_reiniciarPausa2:
   ld  a, e_ai_pausaVel(ix)
   dec   a
   ld  e_ai_pausaVel(ix), a
   ret



;; UPDATE Y
sys_check_borderScreem_patrullar_Y2:
   ;; UPDATE Y
   ld   a, e_y(ix)
   add  e_vy(ix)
   ld   e_y(ix), a
   ret

;; UPDATE X
sys_check_borderScreem_patrullar_X2:
   ld   a, e_x(ix)
   add  e_vx(ix)
   ld   e_x(ix), a
   ret
   