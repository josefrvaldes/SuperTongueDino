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
se_creara_obstaculo: .db #0
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
   jp crear_obstaculos



; Input 
;     nueva_x y nueva_y tienen que estar calculadas previamente
; Output
crear_obstaculo_por_nueva_xy:
   ld a, (nueva_y)
   ld l, a ; nueva_y
   ld a, (nueva_x)
   ld h, a
   ld iy, #obst_fake
   ld obs_x(iy), h
   ld obs_y(iy), l
   ld obs_w(iy), #4
   ld obs_h(iy), #8
   ld hl, #obst_fake
   jp man_obstacle_create


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
   ld h, a  ; x
   ld a, (resto_y)
   ld b, a  ; y
   ld a, #0 ; comparador

   cp h
   jr z, x_es_cero
   x_no_es_cero:
      cp b
      jr z, y_es_cero
      y_no_es_cero:
      ld a, #3
      ret

      y_es_cero:
      ld a, #1
      ret


   x_es_cero:
      cp b
      jr z, ambos_son_cero
      ; y no es cero
      ld a, #2
      ret

      ambos_son_cero:
      ld a, #0
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
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   e, a
   call resta_de_a_hl
   ld   d, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   
   ;  ___
   ; | X |
   ; | O |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ___
   ; |  X|
   ; | O |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo tile   
   
   ;  ___
   ; |   |
   ; |XO |
   ; |___|
   ld bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile   
   
   ;  ___
   ; |   |
   ; | OX|
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile   
   
   ;  ___
   ; |   |
   ; | O |
   ; |X__|
   ld bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile   

   ;  ___
   ; |   |
   ; | O |
   ; |_X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile  

   ;  ___
   ; |   |
   ; | O |
   ; |__X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   ret  z
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
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   
   ;  ____
   ; | X  |
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ____
   ; |  X |
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ____
   ; |   X|
   ; | O  |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile   
   
   ;  ____
   ; |    |
   ; | O X|
   ; |____|
   inc  hl
   inc  hl
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo til  

   ;  ____
   ; |    |
   ; | O  |
   ; |X___|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile

   ;  ____
   ; |    |
   ; | O  |
   ; |_X__|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  7, e      ; con esto decimos que queremos CREAR el segundo tile

   ;  ____
   ; |    |
   ; | O  |
   ; |__X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile

   ;  ____
   ; |    |
   ; | O  |
   ; |___X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
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
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   
   ;  ___
   ; | X |
   ; | O |
   ; |   |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ___
   ; |  X|
   ; | O |
   ; |   |
   ; |___|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo til
   
   ;  ___
   ; |   |
   ; |XO |
   ; |   |
   ; |___|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ___
   ; |   |
   ; | OX|
   ; |   |
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ___
   ; |   |
   ; | O |
   ; |X  |
   ; |___|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ___
   ; |   |
   ; | O |
   ; |  X|
   ; |___|
   inc hl
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile  
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |X__|
   ld  bc, #18
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  7, d      ; con esto decimos que queremos CREAR el segundo tile 
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |_X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ___
   ; |   |
   ; | O |
   ; |   |
   ; |__X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
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
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   a, #21   ; nos posicionamos en el primer tile arriba a la izq a analizar
                 ; para ello le restamos 21 a la pos de memoria del tile de origen
   ld  de, #0
   ld   e, a
   call resta_de_a_hl
   ld   de, #0    ; ponemos d a cero porque será nuestro byte de booleanos
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   
   ;  ____
   ; | X  |
   ; | O  |
   ; |    |
   ; |____|
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  1, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ____
   ; |  X |
   ; | O  |
   ; |    |
   ; |___ |
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  2, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ____
   ; |   X|
   ; | O  |
   ; |    |
   ; |___ |
   inc  hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  3, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ____
   ; |    |
   ; |XO  |
   ; |    |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  4, d      ; con esto decimos que queremos CREAR el segundo tile
   
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
   jr   z, . + 4
   set  5, d      ; con esto decimos que queremos CREAR el segundo tile
   
   ;  ____
   ; |    |
   ; | O  |
   ; |X   |
   ; |____|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  6, d      ; con esto decimos que queremos CREAR el segundo tile
   
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
   jr   z, . + 4
   set  7, d      ; con esto decimos que queremos CREAR el segundo tile  
   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |X___|
   ld  bc, #17
   add hl, bc
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  0, e      ; con esto decimos que queremos CREAR el segundo tile

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |_X__|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  1, e      ; con esto decimos que queremos CREAR el segundo tile  

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |__X_|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
   set  2, e      ; con esto decimos que queremos CREAR el segundo tile  

   
   ;  ____
   ; |    |
   ; | O  |
   ; |    |
   ; |___X|
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   jr   z, . + 4
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




; Input
; ESTO NO--   hl: pos en memoria del obstáculo
;     resto_y y resto_x: cargadas en memoria
;     a:  pos del obstáculo según el dibujo de abajo
;     |8 1 2|
;     |7 E 3|
;     |6 5 4|
crear_obstaculos::
   ; obtenemos la posición en memoria del tile origen y la guardamos en su variable
   ld   a, e_x(ix)
   ld   e, a
   ld   a, e_y(ix) 
   ld   d, a
   call get_pos_tile_memoria
   ld (pos_memoria_tile_origen), hl

   ; calculamos el resto_x
   ld a, e_x(ix)
   ld d, a
   call dividir_d_entre_4
   ld (resto_x), a

   ; calculamos el resto_y
   ld a, e_y(ix)
   ld d, a
   call dividir_d_entre_8
   ld (resto_y), a


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
   call crear_obstaculos_ambos_cero
   ret
   x_no_cero:
   call crear_obstaculos_x_no_cero
   ret
   y_no_cero:
   call crear_obstaculos_y_no_cero
   ret
   ninguno_cero:
   call crear_obstaculos_ninguno_cero
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
   
