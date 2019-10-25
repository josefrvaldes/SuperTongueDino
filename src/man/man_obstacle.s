;;
;; COMPONENT MANAGER
;;
.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/man_obstacle.h.s"
.include "man/man_tilemap.h.s"
.include "entity.h.s"
.include "ent/entity.h.s"
.include "sys/sys_calc.h.s"
.include "man/man_level.h.s"

.module obstacle_manager

obst_array:: DefineComponentArrayStructure _obstacle, max_obstacles, DefineCmp_Obstacle_default ;; ....

obst_fake: DefineCmp_Obstacle  0, 0, 4, 8, 0xBB


resto_x: .db #0
resto_y: .db #0
nueva_x: .db #0
nueva_y: .db #0
x_tile:  .db #0
y_tile:  .db #0
combinacion_restos:  .db #0

pos_memoria_tile_origen:: .dw #0

valor_puerta_1 = 39 - 1 ; el valor del tile en el tmx no corresponde con el de la memoria, es 1 menos
valor_puerta_2 = 40 - 1 
max_num_tile_muro_hero: .db #37
max_num_tile_muro_enemigos: .db #39


max_num_tile_muro_entidad_actual: .db #0


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
   push ix
   ; en este momento tenemos la dirección de movimiento guardada en una variable
   call man_obstacle_init ; vaciamos el array de obstacles
   pop ix
   call crear_obstaculos

   ; si no había obstáculos, metemos uno dummy
   ld a, (_obstacle_num)
   or a
   ret nz
   ld hl, #obst_fake
   jp man_obstacle_create



; OPTIMIZADO
; Input 
;     nueva_x y nueva_y tienen que estar calculadas previamente
; Output
crear_obstaculo_por_nueva_xy:
   ld iy, #obst_fake
   ld a, (nueva_x)
   ld obs_x(iy), a
   ld a, (nueva_y)
   ld obs_y(iy), a
   ld hl, #obst_fake
   jp man_obstacle_create


; OPTIMIZADO
; Input:
;     resto_x y resto_y calculados de antemano
; Output:
;     A: 0 si ambos restos son 0
;        1 si y es cero
;        2 si x es cero
;        3 si ambos son distintos de cero
calcular_combinacion_restos::
   ; comparo si son iguales
   ; si SÍ son, miro si uno de ellos es cero, si lo es, ambos son 0, si no, ambos son 1
   ; si NO son, miro si uno de ellos es cero, si lo es, ese es cero 0, y el otro 1, sino, al revés
   ld a, (resto_x)
   or a
   jr z, x_es_cero
   x_no_es_cero:
      ld a, (resto_y)
      or a
      jr z, y_es_cero
      y_no_es_cero:
      ld a, #3
      ld (combinacion_restos), a
      ret

      y_es_cero:
      ld a, #1
      ld (combinacion_restos), a
      ret


   x_es_cero:
      ld a, (resto_y)
      or a
      jr z, ambos_son_cero
      ; y no es cero
      ld a, #2
      ld (combinacion_restos), a
      ret

      ambos_son_cero:
      ld a, #0
      ld (combinacion_restos), a
      ret



;  ___
; |   |
; | O |
; |___|
get_d_ambos_cero::
   ;  ___
   ; |X  |
   ; | O |
   ; |___|
   
   call get_max_num_tile_muro_segun_enemigo_o_hero

   ld  de, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   call resta_de_a_hl
   ld   d, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)  ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, d_ambos_cero_obst_1
   ld   b, a ; ahora b tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   d_ambos_cero_obst_1:

   ;  ___
   ; | X |
   ; | O |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_2
   ; si el contenido es mayor que max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   d_ambos_cero_obst_2:
   
   ;  ___
   ; |  X|
   ; | O |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_3
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo tile   
   d_ambos_cero_obst_3:

   ;  ___
   ; |   |
   ; |XO |
   ; |___|
   ld bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_4
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile   
   d_ambos_cero_obst_4:
   
   ;  ___
   ; |   |
   ; | OX|
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_5
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile   
   d_ambos_cero_obst_5:
   
   ;  ___
   ; |   |
   ; | O |
   ; |X__|
   ld bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_6
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile   
   d_ambos_cero_obst_6:

   ;  ___
   ; |   |
   ; | O |
   ; |_X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ambos_cero_obst_7
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile  
   d_ambos_cero_obst_7:

   ;  ___
   ; |   |
   ; | O |
   ; |__X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   ret  z
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que d, significa que no hay obstáculo
   cp b
   ret  c
   set  7, d      ; con esto decimos que queremos CREAR el segundo tile  
   ret


crear_obstaculos_ambos_cero::
   call get_d_ambos_cero

   ;  ___
   ; |X  |
   ; | O |
   ; |___|
   ld  a, e_x(ix)   ; guardamos en a la x
   sub #4
   ld (nueva_x), a
   ld  a, e_y(ix)
   sub #8
   ld (nueva_y), a
   push de
   bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; | X |
   ; | O |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |  X|
   ; | O |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 2, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; |XO |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #8
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 3, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | OX|
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #8
   ld (nueva_x), a
   push de
   bit 4, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |X__|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #8
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 5, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |_X_|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 6, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |__X|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 7, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   ret


;  ____
; |    |
; | O  |
; |____|
get_d_x_no_cero::
   ;  ____
   ; |X   |
   ; | O  |
   ; |____|
   call get_max_num_tile_muro_segun_enemigo_o_hero

   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_x_no_cero_obst_1
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   d_x_no_cero_obst_1:

   ;  ____
   ; | X  |
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_2
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   d_x_no_cero_obst_2:

   ;  ____
   ; |  X |
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_3
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo til
   d_x_no_cero_obst_3:
   
   ;  ____
   ; |   X|
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_4
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo til
   d_x_no_cero_obst_4:
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_5
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile   
   d_x_no_cero_obst_5:
   
   ;  ____
   ; |    |
   ; | O X|
   ; |____|
   inc  hl
   inc  hl
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_6
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo til  
   d_x_no_cero_obst_6:

   ;  ____
   ; |    |
   ; | O  |
   ; |X___|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_7
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile
   d_x_no_cero_obst_7:

   ;  ____
   ; |    |
   ; | O  |
   ; |_X__|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_8
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  7, e      ; con esto decimos que queremos CREAR el segundo tile
   d_x_no_cero_obst_8:

   ;  ____
   ; |    |
   ; | O  |
   ; |__X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_x_no_cero_obst_9
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile
   d_x_no_cero_obst_9:

   ;  ____
   ; |    |
   ; | O  |
   ; |___X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   ret z
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   ret c
   set  1, e      ; con esto decimos que queremos CREAR el segundo tile
   ret


crear_obstaculos_x_no_cero::
   call get_d_x_no_cero

   ;  ____
   ; |X   |
   ; | O  |
   ; |____|
   ld  a, (resto_x)
   add #4
   ld  b, a
   ld  a, e_x(ix)   ; guardamos en a la x
   sub b
   ld (nueva_x), a
   ld  a, e_y(ix)
   sub #8
   ld (nueva_y), a
   push de
   bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; | X  |
   ; | O  |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; |  X |
   ; | O  |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 2, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; |   X|
   ; | O  |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 3, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #12
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 4, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | OX |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #12
   ld (nueva_x), a
   push de
   bit 5, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |X___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #12
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 6, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |_X__|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 7, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |_ X_|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 0, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |___X|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   ret



;  ___
; |   |
; | O |
; |   |
; |___|
get_d_y_no_cero::
   ;  ___
   ; |X  |
   ; | O |
   ; |   |
   ; |___|
   call get_max_num_tile_muro_segun_enemigo_o_hero
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_y_no_cero_obst_1
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ; si a es menor que b, significa que no hay obstáculo
   ld a, (max_num_tile_muro_entidad_actual)
   cp b
   jr   c, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   d_y_no_cero_obst_1:

   ;  ___
   ; | X |
   ; | O |
   ; |   |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_2
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   d_y_no_cero_obst_2:
   
   ;  ___
   ; |  X|
   ; | O |
   ; |   |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_3
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo til
   d_y_no_cero_obst_3:
   
   ;  ___
   ; |   |
   ; |XO |
   ; |   |
   ; |___|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_4
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile
   d_y_no_cero_obst_4:
   
   ;  ___
   ; |   |
   ; | OX|
   ; |   |
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_5
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile
   d_y_no_cero_obst_5:
   
   ;  ___
   ; |   |
   ; | O |
   ; |X  |
   ; |___|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_6
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile
   d_y_no_cero_obst_6:
   
   ;  ___
   ; |   |
   ; | O |
   ; |  X|
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_7
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile  
   d_y_no_cero_obst_7:
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |X__|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_8
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  7, d      ; con esto decimos que queremos CREAR el segundo tile 
   d_y_no_cero_obst_8:
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |_X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_y_no_cero_obst_9
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile
   d_y_no_cero_obst_9:
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |__X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   ret z
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   ret  c
   set  1, e      ; con esto decimos que queremos CREAR el segundo tile
   ret


crear_obstaculos_y_no_cero::
   call get_d_y_no_cero

   ;  ___
   ; |X  |
   ; | O |
   ; |   |
   ; |___|
   ld  a, (resto_y)
   add #8
   ld  b, a
   ld  a, e_y(ix)   ; guardamos en a la x
   sub b
   ld (nueva_y), a
   ld  a, e_x(ix)
   sub #4
   ld (nueva_x), a
   push de
   bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ___
   ; | X |
   ; | O |
   ; |   |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ___
   ; |  X|
   ; | O |
   ; |   |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 2, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; |XO |
   ; |   |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #8
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 3, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | OX|
   ; |   |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #8
   ld (nueva_x), a
   push de
   bit 4, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |X  |
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #8
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 5, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |  X|
   ; |___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #8
   ld (nueva_x), a
   push de
   bit 6, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |X__|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #8
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 7, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |_X_|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 0, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |__X|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   ret




;  ____
; |    |
; | O  |
; |    |
; |____|
get_d_ninguno_cero::
   ;  ____
   ; |X   | 
   ; | O  |
   ; |    |
   ; |____|
   call get_max_num_tile_muro_segun_enemigo_o_hero
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr z, d_ninguno_cero_obst_1
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   d_ninguno_cero_obst_1:
   
   ;  ____
   ; | X  |
   ; | O  |
   ; |    |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_2
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_2:
   
   ;  ____
   ; |  X |
   ; | O  |
   ; |    |
   ; |___ |
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_3
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_3:
   
   ;  ____
   ; |   X|
   ; | O  |
   ; |    |
   ; |___ |
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_4
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_4:
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |    |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_5
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_5:
   
   ;  ____
   ; |    |
   ; | O X|
   ; |    |
   ; |____|
   inc hl
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_6
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_6:
   
   ;  ____
   ; |    |
   ; | O  |
   ; |X   |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_7
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_7:
   
   ;  ____
   ; |    |
   ; | O  |
   ; |   X|
   ; |____|
   inc hl
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_8
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  7, d      ; con esto decimos que queremos CREAR el segundo tile  
   d_ninguno_cero_obst_8:
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |X___|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_9
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile
   d_ninguno_cero_obst_9:

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |_X__|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_10
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  1, e      ; con esto decimos que queremos CREAR el segundo tile  
   d_ninguno_cero_obst_10:

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |__X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr z, d_ninguno_cero_obst_11
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   jr   c, . + 4
   set  2, e      ; con esto decimos que queremos CREAR el segundo tile  
   d_ninguno_cero_obst_11:

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |___X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   ret z
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld b, a ; ahora d tiene el valor del tile
   ld a, (max_num_tile_muro_entidad_actual)
   ; si a es menor que b, significa que no hay obstáculo
   cp b
   ret c
   set  3, e      ; con esto decimos que queremos CREAR el segundo tile  
   ret


crear_obstaculos_ninguno_cero::
   call get_d_ninguno_cero

   ;  ____
   ; |X   |
   ; | O  |
   ; |    |
   ; |____|
   ld  a, (resto_x)
   add #4
   ld  b, a
   ld  a, e_x(ix)   ; guardamos en a la x
   sub b
   ld (nueva_x), a
   ld  a, (resto_y)
   add #8
   ld  b, a
   ld  a, e_y(ix)   ; guardamos en a la x
   sub b
   ld (nueva_y), a
   push de
   bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; | X  |
   ; | O  |
   ; |    |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; |  X |
   ; | O  |
   ; |    |
   ; |___ |
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 2, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de

   ;  ____
   ; |   X|
   ; | O  |
   ; |    |
   ; |___ |
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 3, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |    |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #12
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 4, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O X|
   ; |    |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #12
   ld (nueva_x), a
   push de
   bit 5, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |X   |
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #12
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 6, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |   X|
   ; |____|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #12
   ld (nueva_x), a
   push de
   bit 7, d         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |X___|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   sub #12
   ld (nueva_x), a
   ld  a, (nueva_y)   ; guardamos en a la nueva y
   add #8
   ld (nueva_y), a
   push de
   bit 0, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |_X__|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 1, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |__X_|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 2, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |___X|
   ld  a, (nueva_x)   ; guardamos en a la nueva x
   add #4
   ld (nueva_x), a
   push de
   bit 3, e         ; lo hemos calculado porque el primero siempre es obligatorio
   jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
   call crear_obstaculo_por_nueva_xy
   pop de
   ret


hacer_calculos_posiciones_y_restos:
   ld a, e_x(ix)
   ld d, a
   call dividir_d_entre_4_f
   ld (resto_x), a
   ld a, d
   ld (x_tile), a

   ; calculamos el resto_y
   ld a, e_y(ix)
   ld d, a
   call dividir_d_entre_8_f
   ld (resto_y), a
   ld a, d
   ld (y_tile), a
   ret


; Input
; ESTO NO--   hl: pos en memoria del obstáculo
;     resto_y y resto_x: cargadas en memoria
;     a:  pos del obstáculo según el dibujo de abajo
;     |8 1 2|
;     |7 E 3|
;     |6 5 4|
crear_obstaculos::
   ;cpctm_setBorder_asm HW_GREEN
   ; calculamos el resto_x
   call hacer_calculos_posiciones_y_restos

   ;cpctm_setBorder_asm HW_RED
   ; obtenemos la posición en memoria del tile origen y la guardamos en su variable
   call get_pos_tile_memoria_by_tile
   ld (pos_memoria_tile_origen), hl


   call calcular_combinacion_restos ; en a, cargamos la combinación de restos
   or a
   jr z, ambos_cero
   dec a
   jr z, x_no_cero
   dec a
   jr z, y_no_cero
   dec a
   jr z, ninguno_cero

   ambos_cero::
   jp crear_obstaculos_ambos_cero
   
   x_no_cero:
   jp crear_obstaculos_x_no_cero
   
   y_no_cero:
   jp crear_obstaculos_y_no_cero
   
   ninguno_cero:
   jp crear_obstaculos_ninguno_cero
   



; Recibe una x y una y del mapa (en tiles) y devuelve la posición de memoria
; donde se encuentra ese tile en el tilemap en memoria.
; Input 
;     y_tile y x_tile cargadas
; Output
;    HL: la pos de memoria mapeada de la x e y que le hemos pasado
get_pos_tile_memoria_by_tile::
   ; la posición del tile en memoria es:
   ; pos_ini_tilemap + x + ancho_tilemap * y ---- 4000 + x + 20y
   ; en este caso de prueba, sabemos que nuestro tilemap empieza en 4000
   ; así que: pos_ini_tilemap = 4000
   ; sabemos que el ancho del tilemap es de 20: ancho_tilemap = 20
   
   ld a, (y_tile)
   ld d, a
   call multiplicar_d_por_20_no_safe
   ; ahora en HL tenemos el resultado de la operación 20y


   ; las 4 operaciones de abajo son para preparar la suma de hl con de, que contiene la división de la pos x
   ld de, #0          ; ponemos de a cero
   ld a, (x_tile)
   ld  e, a           ; y ponemos en e el valor de x/4
   add hl, de         ; sumamos 20y + x

   ld bc, #decompress_buffer ; cargamos en bc la pos inicial en memoria de nuestro tilemap
   add hl, bc     ; y ya sumamos 4000 + x + 20y
   ld (pos_memoria_tile_origen), hl
   ret
   



; OPTIMIZADO
; Devuelve el número de tile máximo que representa un muro dentro del tileset.
; Esto es necesario porque no es el mismo número para enemigo que para hero
get_max_num_tile_muro_segun_enemigo_o_hero::
   ld a, e_ai_st(ix) ; obtenemos el tipo de ia, si es el personaje, 
                     ; podrá salir por la puerta, si son enemigos, 
                     ; la puerta es un obstáculo más
   or a ; el tipo de ia del personaje es 0, las demás son de los enemigos, si a == 0, somos el hero, si no, enemigos
   jr z, es_hero
   ; si el contenido es mayor que  max_num_tile_muro no hay obstáculo
   ld a, (max_num_tile_muro_enemigos)
   ld (max_num_tile_muro_entidad_actual), a
   ret

   es_hero:
      ld a, (max_num_tile_muro_hero)
      ld (max_num_tile_muro_entidad_actual), a
      ret



; OPTIMIZADO
; Devuelve el valor crítico de los tiles que la entidad está pisando.
; Por valor crítico entendemos que si está pisando 4 tiles a la vez,
; devolverá el valor más significativo. Por ejemplo, si 3 tiles son fondo y 1 es pinchos, devolverá pinchos
; Input
;     hl posicion origen a revisar
; Output
;     a devolverá:
;        0 si fondo
;        1 si pincho
;        2 si puerta
man_obstacle_get_valor_tile_x_no_cero:
   ld  a, (hl)
   or a  ; comprobamos si era fondo
   jr nz, x_no_cero_no_era_fondo ; el primer tile no es fondo
   inc hl ; pasamos al tile de al lado
   ld  a, (hl)
   or a
   ret z         ; si llegamos aquí significa que los dos primeros tiles eran fondo, nos salimos pq a ya vale cero
                 ; si llegamos aquí significa que ninguno de los dos primeros tiles era fondo, así que hay que decrementar hl
   dec hl        ; esto de incrementar para luego decrementar es porque la mayoría de las veces ambos serán fondo, así que es
   ld  a, (hl)   ; conveniente descartar esto primero que además tiene muy poco coste computacional, antes que analizar primero el primer tile entero y luego el segundo entero


   x_no_cero_no_era_fondo:
      ld b, #valor_puerta_1
      cp b 
      jr z, x_no_cero_era_puerta

      ; no era la puerta 1
      ld b, #valor_puerta_2
      cp b 
      jr z, x_no_cero_era_puerta

      inc hl
      ld a, (hl)
      ld b, #valor_puerta_1
      cp b 
      jr z, x_no_cero_era_puerta

      ; no era la puerta 1
      ld b, #valor_puerta_2
      cp b 
      jr z, x_no_cero_era_puerta
      jr x_no_cero_era_pincho

   x_no_cero_era_pincho:
      ld a, #1
      ret

   x_no_cero_era_puerta:
      ld a, #2
      ret


; OPTIMIZADO
; Devuelve el valor crítico de los tiles que la entidad está pisando.
; Por valor crítico entendemos que si está pisando 4 tiles a la vez,
; devolverá el valor más significativo. Por ejemplo, si 3 tiles son fondo y 1 es pinchos, devolverá pinchos
; Input
;     hl posicion origen a revisar
; Output
;     a devolverá:
;        0 si fondo
;        1 si pincho
;        2 si puerta
man_obstacle_get_valor_tile_y_no_cero:
   ld  a, (hl)
   or a  ; comprobamos si era fondo
   jr nz, y_no_cero_no_era_fondo ; el primer tile no es fondo
   ld bc, #20
   add hl, bc ; pasamos al tile de abajo
   ld  a, (hl)
   or a
   ret z         ; si llegamos aquí significa que los dos primeros tiles eran fondo, nos salimos pq a ya vale cero
                 ; si llegamos aquí significa que ninguno de los dos primeros tiles era fondo, así que hay que decrementar hl
   ld hl, (#pos_memoria_tile_origen) ; esto de incrementar para luego decrementar es porque la mayoría de las veces ambos serán fondo, así que es
   ld  a, (hl)   ; conveniente descartar esto primero que además tiene muy poco coste computacional, antes que analizar primero el primer tile entero y luego el segundo entero


   y_no_cero_no_era_fondo:
      ld b, #valor_puerta_1
      cp b 
      jr z, y_no_cero_era_puerta

      ; no era la puerta 1
      ld b, #valor_puerta_2
      cp b 
      jr z, y_no_cero_era_puerta

      ld bc, #20
      add hl, bc
      ld a, (hl)
      ld b, #valor_puerta_1
      cp b 
      jr z, y_no_cero_era_puerta

      ; no era la puerta 1
      ld b, #valor_puerta_2
      cp b 
      jr z, y_no_cero_era_puerta
      jr y_no_cero_era_pincho

   y_no_cero_era_pincho:
      ld a, #1
      ret

   y_no_cero_era_puerta:
      ld a, #2
      ret


; OPTIMIZADO
; Devuelve el valor crítico de los tiles que la entidad está pisando.
; Por valor crítico entendemos que si está pisando 4 tiles a la vez,
; devolverá el valor más significativo. Por ejemplo, si 3 tiles son fondo y 1 es pinchos, devolverá pinchos
; Input
;     hl posicion origen a revisar
; Output
;     a devolverá:
;        0 si fondo
;        1 si pincho
;        2 si puerta
man_obstacle_get_valor_tile_ninguno_cero::
   ; aquí vamos a hacer una cosa, en vez de hacer un método que compruebe las 4 posibles posiciones
   ; vamos a reutilizar el metodo de x_no_cero. Le pasaremos la x origen de la fila de arriba, luego desplazaremos
   ; abajo, y se la pasaremos de nuevo, algo así:
   

   ; la x marca el origen, se mirará ese tile y el de su derecha
   ; en la primera iteración, comprobaremos la X y el +, utilizando el método de x_no_cero
   ;  __
   ; |X+|
   ; |__|
   ;
   ; En la segunda iteración, desplazaremos X al tile inferior, y comprobaremos lo siguiente:
   ;  __
   ; |  |
   ; |X+|
   ; Como veis, comprobamos las dos de abajo, quedando todas las posiciones cubiertas sin añadir código excesivo
   ld hl, (#pos_memoria_tile_origen)
   call man_obstacle_get_valor_tile_x_no_cero  ; obtenemos el valor del eje x
   or a        
   ret nz      ; si no ha sido cero, ya sabemos que tenemos que salir, nos da igual que sea puerta o pincho
   ld hl, (#pos_memoria_tile_origen)
   ld bc, #20
   add hl, bc
   call man_obstacle_get_valor_tile_x_no_cero ; en caso de que no fuera cero, desplazamos hl hacia abajo, y comprobamos de nuevo
   ret



; OPTIMIZADO
; Recibe una x y una y del mapa (en tiles) y devuelve la posición de memoria
; donde se encuentra ese tile en el tilemap en memoria.
; Input 
;     pos_memoria_tile_origen cargada
; Output
;     a devolverá:
;        0 si fondo
;        1 si pincho
;        2 si puerta
; Destroys
;     a
man_obstacle_get_valor_tile_por_pos_memoria_cargada::
   ;call hacer_calculos_posiciones_y_restos
   ;call calcular_combinacion_restos ; en a, cargamos la combinación de restos
   ;call get_pos_tile_memoria_by_tile
   ld a, (combinacion_restos)
   or a
   jr z, get_valor_tile_ambos_cero
   dec a
   jr z, get_valor_tile_x_no_cero
   dec a
   jr z, get_valor_tile_y_no_cero
   dec a
   jr z, get_valor_tile_ninguno_cero

   get_valor_tile_ambos_cero:
      ld hl, (#pos_memoria_tile_origen)
      ld  a, (hl)
      or a  ; comprobamos si era fondo
      ret z ; sí era fondo nos salimos porque a ya vale 0

      ld b, #valor_puerta_1
      cp b 
      jr z, era_puerta

      ; no era la puerta 1
      ld b, #valor_puerta_2
      cp b 
      jr z, era_puerta
      jr era_pincho


   get_valor_tile_x_no_cero:
      ld hl, (#pos_memoria_tile_origen)
      jp man_obstacle_get_valor_tile_x_no_cero
      

   get_valor_tile_y_no_cero:
      ld hl, (#pos_memoria_tile_origen)
      jp man_obstacle_get_valor_tile_y_no_cero


   get_valor_tile_ninguno_cero:
      call man_obstacle_get_valor_tile_ninguno_cero
      ret


   era_pincho:
      ld a, #1
      ret

   era_puerta:
      ld a, #2
      ret
