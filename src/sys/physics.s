;;
;; ENTITY PHYSICS MOVEMENTS
;;
.include "cpctelera.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/entity.h.s"
.include "man/man_obstacle.h.s"
.include "sys/collisions.h.s"
.include "sys/sys_calc.h.s"


.module sys_entity_physics

;; Physics system constants
screen_width  = 80
screen_height = 200
;;
;; VARIABLES CONTROL DEL SALTO Y REBOTES
;;
V_jumpControlVY_gravity:   .db #-1     ;; -1 GRAVITY     // 0 JUMP CONTROL
V_jumpControlVX_keyboardO:    .db #1      ;; -1 KEYBOARD    // 0 JUMP CONTROL           // 1 PRIMER SALTO
V_jumpControlVX_keyboardP: .db #1      ;; -1 KEYBOARD    // 0 JUMP CONTROL          // 1 PRIMER SALTO
hero_jump:           .db #-1           ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_left:         .db #-1     ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_jump_right:        .db #-1     ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
hero_gravity:        .db #0      ;; -1 NO SALTAMOS // != -1 SALTAMOS/SALTANDO
press_now_W:         .db #-1     ;; variable que nos indica si estamos saltando justo en ese momento
;spittle:            .db #6         ;; el numero de saliva es lo que le restamos a la gravedad 
;;
;;TABLAS DE SALTO Y GRAVEDAD
;;
jump_table:                ;; Tabla de salto normal (hacia arriba)
   .db #-7, #-5, #-4, #-3
      .db #-2, #-2, #-2, #-1
      .db #-1, #-1, #-1
      .db #0x80               ;; Ultima posicion de la tabla, para saber que he terminado (nunca tendre una velocidad tan alta)
gravity_table:             ;; Tabla de salto que simula la gravedad
      .db #00, #00, #00
      .db #1, #1, #1, #2
      .db #2, #2, #3, #5
   .db #7 
      .db #0x80
jump_table_right:             ;; Tabla hacia la IZQUIERDA cuando colisionamos por la DERECHA
   .db #2, #2, #1, #1, #1, #00
   .db #0x80
jump_table_left:              ;; Tabla hacia la DERECHA cuando colisionamos por la IZQUIERDA
   .db #-2, #-2, #-1, #-1, #-1,#00  
   .db #0x80


resto_x: .db #0
resto_y: .db #0


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


; Recibe una x y una y del mapa (en bytes) y devuelve la posición de memoria
; donde se encuentra ese tile en el tilemap en memoria.
; Por ahora solo funciona para 1 solo tilemap. Para hacer que funcione con más,
; habrá que pasar próximamente otra variable con el número de nivel en el que nos encontramos
; Input 
;     E: x
;     D: y
; Output
;    HL: la pos de memoria mapeada de la x e y que le hemos pasado
get_pos_tile_memoria::
   ; la posición del tile en memoria es:
   ; pos_ini_tilemap + x + ancho_tilemap * y ---- 4000 + x + 20y
   ; en este caso de prueba, sabemos que nuestro tilemap empieza en 4000
   ; así que: pos_ini_tilemap = 4000
   ; sabemos que el ancho del tilemap es de 20: ancho_tilemap = 20
   
   push de ; guardamos en la pila el valor de x, porque lo vamos a perder en las siguientes llamadas

   ; aquí d ya contiene la pos y en bytes
   ; hay que dividir entre 8 la posición y, porque cada tile son 8 bytes en altura
   call dividir_d_entre_8
   ; ahora en d ya no tenemos la y original, sino la y/8, que es la que necesitamos


   ld a, #20 ; cargamos en c el ancho en tiles del tilemap, que es 20
   ld c, a
   call multiplicar_d_c_16bits ; ya tenemos 20y que nos hace falta para la operación
   ; ahora en HL tenemos el resultado de la operación 20y

   ; recuperamos el valor de x, que lo teníamos en la pila
   pop  de
   ld   d, e ; y lo guardamos en d, que es donde tiene que estar para llamar a esta función
   call dividir_d_entre_4 ; dividimos entre 4 porque en ancho, cada tile son 4 bytes
   ; ahora en d ya no tenemos la y original, sino la y/4, que es la que necesitamos

   ; las 4 operaciones de abajo son para preparar la suma de hl con de, que contiene la división de la pos x
   ld  a, d           ; metemos en a el valor de la divisón de x/4
   ld de, #0          ; ponemos de a cero
   ld  e, a           ; y ponemos en e el valor de x/4
   add hl, de         ; sumamos 20y + x

   ld bc, #0x4000 ; cargamos en bc la pos inicial en memoria de nuestro tilemap
   add hl, bc     ; y ya sumamos 4000 + x + 20y
   ret
   

; Input
; ESTO NO--   hl: pos en memoria del obstáculo
;     resto_y y resto_x: cargadas en memoria
;     a:  pos del obstáculo según el dibujo de abajo
;     |1 2 3|
;     |4 E 5|
;     |6 7 8|
crear_obstaculo::
   dec a
   jr z, era_1
   dec a
   jr z, era_2
   dec a
   jr z, era_3
   dec a
   jr z, era_4
   dec a
   jr z, era_5
   dec a
   jr z, era_6
   dec a
   jr z, era_7
   dec a
   jr z, era_8


   era_1:
   ret
   era_2:
   ret
   era_3:
   ret
   era_4:
   ret
   era_5:
   ret
   era_6:
   ret
   era_7:
   ret
   era_8:
   ret


; Input: 
;     ix: puntero a entidad de origen
; Output:
;     a: núm dirección según este dibujo
;      812
;    7_\|/_ 3    0 si parado
;      /|\
;     6 54
get_direccion_movimiento::
   ld hl, #0xC000
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00
   inc hl
   ld (hl), #00

   ld a, e_vy(ix) ; cargamos en a la vy
   call check_if_negative2  ; esto devuelve en a 0 si cero o positivo, 1 si negativo
   dec a
   jr z, vy_es_negativa
   
   ; si estamos aquí, es que vy es cero o positiva
   ld a, e_vy(ix)
   or a
   jr z, vy_es_cero
   

   vy_es_positiva::
   ld a, e_vx(ix)
   call check_if_negative2
   dec a
   jr z, vy_positiva_vx_negativa
   ; si estamos aquí es que vy es negativa y vx es cero o positiva
   ld a, e_vx(ix)
   or a
   jr z, vy_positiva_vx_cero
   
   vy_positiva_vx_positiva::
   ld hl, #0xC004
   ld (hl), #0xFF
   ld a, #4
   ret


   vy_es_cero::
   ld a, e_vx(ix)
   call check_if_negative2
   dec a
   jr z, vy_cero_vx_negativa
   ; si estamos aquí es que vy es negativa y vx es cero o positiva
   ld a, e_vx(ix)
   or a
   jr z, vy_cero_vx_cero
   
   vy_cero_vx_positiva::
   ld hl, #0xC003
   ld (hl), #0xFF
   ld a, #3
   ret


   vy_es_negativa:
   ld a, e_vx(ix)
   call check_if_negative2
   dec a
   jr z, vy_vx_son_negativas
   ; si estamos aquí es que vy es negativa y vx es cero o positiva
   ld a, e_vx(ix)
   or a
   jr z, vy_negativa_vx_cero

   vy_negativa_vx_positiva::
   ld hl, #0xC002
   ld (hl), #0xFF
   ld a, #2
   ret

   vy_vx_son_negativas::
   ld hl, #0xC008
   ld (hl), #0xFF
   ld a, #8
   ret

   vy_negativa_vx_cero::
   ld hl, #0xC001
   ld (hl), #0xFF
   ld a, #1
   ret
   
   vy_cero_vx_negativa::
   ld hl, #0xC007
   ld (hl), #0xFF
   ld a, #7
   ret
   
   vy_cero_vx_cero::
   ld hl, #0xC000
   ld (hl), #0xFF
   ld a, #0
   ret

   vy_positiva_vx_negativa::
   ld hl, #0xC006
   ld (hl), #0xFF
   ld a, #6
   ret

   vy_positiva_vx_cero::
   ld hl, #0xC005
   ld (hl), #0xFF
   ld a, #5
   ret


; Input: 
;     HL, pos de memoria de la entidad origen
analizar_obstaculos_vy_positiva::
   ; necesitamos el resto de la división entre y/8 para saber cuántos píxeles estamos desplazados.
   ; Ese resto habrá que sumárselo a la y de la entidad origen + el alto del tile para encontrar la 
   ; pos Y de los obstáculos
   ld d, e_y(ix)
   call dividir_d_entre_8
   ; en este punto, a es el resto en y
   ld (#resto_y), a

   ld d, e_x(ix)
   call dividir_d_entre_4
   ; en este punto, a es el resto en y
   ld (#resto_x), a


   ; para obtener el tiled de abajo, sumo 20 a la pos de memoria
   ; para obtener el diagonal abajo izq, sumo 19, y para el diagonal abajo dch, sumo 21
   push hl
   ld   bc, #19 
   add  hl, bc  ; sumamos 19 a hl para coger el obstáculo abajo-izq
   ld a, (hl)   ; cogemos el valor de esa posición de memoria
   or a         ; comprobamos si es cero. Si a == 0, el tile es fondo y por tanto no es obstáculo, si a != 0, el tile es obstáculo
   call nz, crear_obstaculo
   
   inc hl       ; nos posicionamos en hl + 20, que es la posición debajo de la entidad origen
   ld a, (hl)   ; hacemos la misma comprobación de arriba
   or a
   call nz, crear_obstaculo
   
   inc hl
   ld a, (hl)
   or a
   call nz, crear_obstaculo
   pop hl
   ret

   
   colision_vertical:
   call crear_obstaculo
   cpctm_setBorder_asm HW_RED
   pop hl
   ret



;; Función que re-rellena el array de obstáculos en base a la posición y velocidad de la entidad recibida en iy
;; Input: IX - Puntero a la entidad a revisar
re_rellenar_array_obstacles::
   ;call man_obstacle_init ; vaciamos el array de obstacles

   ; la velocidad es positiva, es decir, vamos hacia abajo, por lo tanto hay que
   ; comprobar con los 3 tiles de abajo, /|\, para ello, necesitamos su posición en el tilemap
   ld   a, e_x(ix)
   ld   e, a
   ld   a, e_y(ix) ; para probar lo vamos a hacer con un solo tile en vertical debajo del monigote
   ld   d, a
   call get_pos_tile_memoria

   ; comprobamos si la vy es positiva, es decir, si va hacia abajo
   ld a, e_vy(ix)
   call check_if_negative ; devuelve en a 0 si 0 o positivo, 1 si negativo
   jr nz, vy_negativa
   ; si estamos aquí es que la vy es cero o positiva
   ld a, e_vy(ix)
   or a
   jr nz, vy_positiva
   call vy_cero

   vy_negativa:

   vy_positiva:
   call analizar_obstaculos_vy_positiva
      


   vy_cero:

   ret



;;
;; SYS_PHYSICS UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX, IY, HL -- TODOS
;; Stack Use: 2 bytes
sys_physics_update::
   ld (_ent_counter), a
   call get_direccion_movimiento

   ;; commprobamos si somos el HEROE o un ENEMIGO para pocesar el salto
   ld a, e_ai_st(ix)
   cp #e_ai_st_noAI  ;; comparamos si no tiene IA
   jr nz, _update_loop
      ;; SOMOS EL HEROE
      call check_jump_tables_init

;; BUCLE QUE RECORRE TODAS LAS ENTIDADES CON FISICAS 
_update_loop:
   call re_rellenar_array_obstacles
   ;; COLISIONES CON LOS OBJETOS
   call sys_check_collision

   ;; tenemos en D = VX en E = VY
   ld a, d
   add   e                             ;; sumo variacion en D y variacion en E
   jr nz,   equals                        ;Si !=0 es que NO HAY COLISION EN LAS ESQUINAS

      ld a, #0
      add   d
      jr z, only_collision_corner                  ;; SI UNA DE LAS DOS ES 0, LAS DOS LO ERAN (D y E) y por tanto comprobar colisiones en las esquinas
equals:  ;; si no son iguales HA HABIDO COLISION SEGURO
   ld a, e_ai_st(ix)
   cp #e_ai_st_noAI
   jr nz, no_mas_saltos

         ld  a, e_y(ix)
         add e_vy(ix)
         ld  c, a
         ld  a, e_vy(ix)
         sub c
         jr z, no_mas_saltos
         jr  nc, parar_salto_vetical                  ;; velocidad positiva

      call check_jump_table_update

   jr no_mas_saltos


only_collision_corner:
   ;; COLISIONES CON LAS ESQUINAS DE LOS OBJETOS
   call sys_check_collision_corner
      jr no_mas_saltos
parar_salto_vetical:
   call  end_of_jump
no_mas_saltos:
   ;; COLISIONES CON LOS BORDES DE LA PANTALLA
   call sys_check_borderScreem

   _ent_counter = . + 1
   ld a, #0
   dec   a
   ret   z

   ld (_ent_counter), a
   ld de, #sizeof_e
   add   ix, de
   jr _update_loop
;; FIN  -- sys_physics_update --
;; ---------------------------------------------------------------------------------------------------------------------------------------------------- ;;



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

         ld  a, e_x(ix)
         add e_vx(ix)
         ld  c, a
         ld  a, e_vx(ix)
         sub c
         ret  z    
         jr  c, jump_left  ;; velocidad positiva
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
;; CHOQUES CON LOS BORDES DE LA PANTALLA
   ;; UPDATE X
   ld a, #screen_width + 1
   sub   e_w(ix)
   ld c, a

   ld a, e_x(ix)
   add   e_vx(ix)
   cp c
   jr nc, invalid_x
valid_x:
   ld e_x(ix), a
   jr endif_x
invalid_x:
   ld a, e_vx(ix)
   neg            ;; para cambiar a negativo
   ld e_vx(ix), a
endif_x:


   ;; UPDATE Y
   ld a, #screen_height + 1
   sub   e_h(ix)
   ld c, a

   ld a, e_y(ix)
   add   e_vy(ix)
   cp c
   jr nc, invalid_y
valid_y:
   ld e_y(ix), a
   jr endif_y
invalid_y:
   ld a, e_vy(ix)
   neg            ;; para cambiar a negativo
   ld e_vy(ix), a
endif_y:

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
   call check_collisions               ;; RETURN: - D modificacion en e_x
                           ;;         - E modificacion en e_y

   ld a, d                    ;;tenemos la variacion en el eje X
   add   #0                      ;; si no hat colision se debe de quedar en 0
   jr z, no_colision_X
      ;; COLISION EN X:
            ld    a, e_x(ix)
            sub    d                ;; al tener colision:
            ld    e_x(ix), a              ;; anyadimos esa modicion para que se quede en el borde
no_colision_X:

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
      ;; MALA PROGRAMACION -- VALOR PUESTO A PELO
      ld a, #11               ;; GUARDAMOS EN A EL INDICE ULTIMO DE NUESTRA TABLA = GRAVEDAD MAXIMA

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

      ld a, #0
      ;; el control deja de estar en el usuario y se le pasa a la jump table
      ld (hero_jump_right), a             ;; a 0 es que esta ACTIVO
      ld (V_jumpControlVX_keyboardO), a         ;; a 0 es que esta ACTIVO
   ret


