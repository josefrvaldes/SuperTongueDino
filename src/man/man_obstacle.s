;;
;; COMPONENT MANAGER
;;
.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/man_obstacle.h.s"
.include "entity.h.s"
.include "ent/entity.h.s"
.include "sys/sys_calc.h.s"

.module obstacle_manager

DefineComponentArrayStructure _obstacle, max_obstacles, DefineCmp_Obstacle_default ;; ....

obst_fake: DefineCmp_Obstacle  0, 0, 5, 9, 0xBB


resto_x: .db #0
resto_y: .db #0
nueva_x: .db #0
nueva_y: .db #0
direccion_movimiento: .db #0
pos_memoria_tile_origen: .dw #0


;;=======================================================================================
;; OBSTACLES
;;=======================================================================================


;; //////////////////
;; getArray
;; Input: -
;; Destroy: A, IX
man_obstacle_getArray::
      ld  iy, #_obstacle_array
      ld    a, (_obstacle_num)
      ret


;; //////////////////
;; init Entity
;; Input: -
;; Destroy: AF, HL
man_obstacle_init::
      xor a                         ;; pone a con el valor de 0, solo ocupa una operacion
      ld    (_obstacle_num), a

      ld    hl, #_obstacle_array
      ld    (_obstacle_pend), hl

      ret



;; //////////////////
;; NEW Entity
;; Input: -
;; Destroy: F, BC, DE, HL
;; Return: BC -> tamaño de la entidad,   DE -> apunta al elemento creado
man_obstacle_new::
      ;; Incrementar numero de entidades
      ld    hl, #_obstacle_num
      inc   (hl)

      ;; Mueve el puntero del array al siguiente elemento vacio
      ld    hl, (_obstacle_pend)
      ld    d, h
      ld    e, l
      ld    bc, #sizeof_obs
      add hl, bc
      ld    (_obstacle_pend),hl

      ret 

;; //////////////////
;; CREATE Entity
;; Input: HL -> puntero para inicializar valores de la entidad
;; Destroy: F, BC, DE, HL
;; Return: IX -> puntero al componente creado
man_obstacle_create::
      push hl
      call man_obstacle_new

      ld__ixh_d  ;; carga d en el registro alto de ix
      ld__ixl_e

      pop hl
      ldir

      ret








;; Función que re-rellena el array de obstáculos en base a la posición y velocidad de la entidad recibida en iy
;; Input: IX - Puntero a la entidad a revisar
man_obstacle_re_rellenar_array::
   ; en este momento tenemos la dirección de movimiento guardada en una variable
   call man_obstacle_init ; vaciamos el array de obstacles
   ld hl, #obst_fake
   call man_obstacle_create

   call man_entity_getArray
   call get_direccion_movimiento
   call crear_obstaculos_segun_direccion

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
   ; esto de aquí es debug, para mostrar en pantalla una pista de dónde estamos
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
   ld (direccion_movimiento), a
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
   ld (direccion_movimiento), a
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
   ld (direccion_movimiento), a
   ret

   vy_vx_son_negativas::
   ld hl, #0xC008
   ld (hl), #0xFF
   ld a, #8
   ld (direccion_movimiento), a
   ret

   vy_negativa_vx_cero::
   ld hl, #0xC001
   ld (hl), #0xFF
   ld a, #1
   ld (direccion_movimiento), a
   ret
   
   vy_cero_vx_negativa::
   ld hl, #0xC007
   ld (hl), #0xFF
   ld a, #7
   ld (direccion_movimiento), a
   ret
   
   vy_cero_vx_cero::
   ld hl, #0xC000
   ld (hl), #0xFF
   ld a, #0
   ld (direccion_movimiento), a
   ret

   vy_positiva_vx_negativa::
   ld hl, #0xC006
   ld (hl), #0xFF
   ld a, #6
   ld (direccion_movimiento), a
   ret

   vy_positiva_vx_cero::
   ld hl, #0xC005
   ld (hl), #0xFF
   ld a, #5
   ld (direccion_movimiento), a
   ret




; Input
; ESTO NO--   hl: pos en memoria del obstáculo
;     resto_y y resto_x: cargadas en memoria
;     a:  pos del obstáculo según el dibujo de abajo
;     |8 1 2|
;     |7 E 3|
;     |6 5 4|
crear_obstaculos_segun_direccion::
   ld   a, e_x(ix)
   ld   e, a
   ld   a, e_y(ix) 
   ld   d, a
   call get_pos_tile_memoria
   ld (#pos_memoria_tile_origen), hl

   ld a, e_x(ix)
   ld d, a
   call dividir_d_entre_4
   ld (resto_x), a

   ld a, e_y(ix)
   ld d, a
   call dividir_d_entre_8
   ld (resto_y), a

   ld a, (#direccion_movimiento)
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
   ld hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld bc, #20
   add hl, bc
   ld a, (resto_y) ; cargamos en a el resto en y
   or a            ; comprobamos si el resto de y es cero
   jr nz, . + 2    ; si el resto no es cero, hay que sumar de nuevo el 20
   add hl, bc ; ahora estamos apuntando al tile de abajo, el que sería nuestro obstáculo
   ld a, (hl) ; esta es la información que tiene el tile de abajo, si es 0 es fondo, si no, es obstáculo
   or a
   ret z

   ; dirección hacia abajo
   ; si modulo de x/4 es 0, solo necesitamos un obstáculo, el de abajo
   
   ; aquí a vale el resto de la división
   ld a, (resto_x)
   or a
   jr nz, resto_no_cero_5
   resto_cero_5:
   ; como el resto es cero, la pos del obstáculo estará en
   ; x_obs = x
   ; SI RESTO Y != 0 -- y_obs = y + alto + 8 - resto_y
   ; SI RESTO Y == 0 -- y_obs = y + alto
   
   ; calculamos la nueva x, como el resto en x es cero, la x y la nueva_x son iguales
   ld a, e_x(ix) ; cargamos en a la x
   ld (nueva_x), a

   ld a, (resto_y) ; cargamos en a el resto en y
   or a            ; comprobamos si el resto de y es cero
   jr nz, resto_y_no_cero_5
   ld a, e_y(ix)   ; cargamos en a la y
   add #8          ; le sumamos el alto 
   ld (nueva_y), a
   jr crear_obstaculo_5

   
   resto_y_no_cero_5:
   ld a, e_y(ix)   ; cargamos en a la y
   add #16          ; le sumamos el alto 
   ld b, a         ; guardamos el acumulado de la operación en b
   ld a, (resto_y) ; guardamos el resto en h
   ld h, a         ; guardamos el resto en h
   ld a, b         ; devolvemos el acumulado de la operación a a
   sub a, h        ; le restamos el resto y
   ld (nueva_y), a


   crear_obstaculo_5:
   ld h, a ; nueva_y
   ld a, (nueva_x)
   ld iy, #obst_fake
   ld obs_x(iy), a
   ld obs_y(iy), h
   ld obs_w(iy), #4
   ld obs_h(iy), #8
   ld hl, #obst_fake
   call man_obstacle_create
   resto_no_cero_5:
   ret

   era_6:
   ret

   era_7: 

   ret
   era_8:
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
   
