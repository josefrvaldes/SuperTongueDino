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
   call get_direccion_movimiento
   jp crear_obstaculos_segun_direccion



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

; Input
;     pos_memoria_tile_origen cargada
;     a, offset con respecto al tile origen (ejemplo, 20 si es el de la fila de abajo, -20 si es de arriba, 1 si es el de la dch, -1 si es el de la izq)
; Output
;     a 0 si no es obstaculo, != 0 si sí lo es
analizar_si_tile_cercano_es_obstaculo:
   ld  bc, #0
   ld  hl, (#pos_memoria_tile_origen) ; aquí está el tile de origen
   ld   c, a
   add hl, bc                        ; ahora estamos posicionados en el tile destino
   ld   a, (hl)                      ; cargamos en a el contenido del tile destino
   ret


; Input
;     pos_memoria_tile_origen cargada 
;     a, offset con respecto al tile origen (ejemplo, 20 si es el de la fila de abajo, -20 si es de arriba, 1 si es el de la dch, -1 si es el de la izq)
; Output
;     d tendrá cargados los bits de los obstáculos que se deberán crear
get_d_dir_5:
   ld   d, #0  ; ponemos d a cero porque es el registro que usaremos para saber qué obstáculos hay que crear y cuales no
   call analizar_si_tile_cercano_es_obstaculo
   or   a        ; si el contenido es cero, no hay obstáculo
   jr   z, . + 4
   set  0, d      ; con esto decimos que queremos CREAR el primer tile
   
   inc hl
   ld   a, (hl)         ; cargamos en a el contenido del tile destino
   or   a               ; si el contenido es cero, no hay obstáculo, salimos
   ret  z
   set  1, d      ; con esto decimos que queremos CREAR el segundo tile
   ret


crear_obstaculos_dir_5::
   ld a, #0
   ld d, a
   call calcular_combinacion_restos ; en a, cargamos la combinación de restos
   cp d
   jr z, ambos_cero_dir_5
   dec a
   jr z, x_no_cero_dir_5
   dec a
   jr z, y_no_cero_dir_5
   dec a
   jr z, ninguno_cero_dir_5

   ambos_cero_dir_5::
      ld   a, #20
      call analizar_si_tile_cercano_es_obstaculo
      or   a        ; si el contenido es cero, no hay obstáculo, salimos
      ret  z

      ; si el contenido del tile destino es obstaculo, calculamos las posiciones del mismo
      ld a, e_x(ix)
      ld (nueva_x), a
      ld a, e_y(ix)
      add #8
      ld (nueva_y), a
      call crear_obstaculo_por_nueva_xy
      ret

   y_no_cero_dir_5::
      ld   a, #40
      call analizar_si_tile_cercano_es_obstaculo
      or   a        ; si el contenido es cero, no hay obstáculo, salimos
      ret  z
      

      ld a, e_x(ix)
      ld (nueva_x), a
      ld a, e_y(ix)
      add #16
      ld b, a         ; guardamos el acumulado de la operacion
      ld a, (resto_y) ; guardamos en a el resto_y
      ld h, a         ; guardamos en h el resto_y
      ld a, b         ; guardamos en a el acumulado de la operación
      sub a, h        ; le restamos a 'a' el valor de 'h', es decir, el acumulado menos el resto
      ld (nueva_y), a
      call crear_obstaculo_por_nueva_xy
      ret

   ninguno_cero_dir_5::      
      ld   a, #40
      call get_d_dir_5
      or d          ; si todos los tiles eran fondo..
      ret z         ; ..nos salimos

      ld  a, (resto_x) ; guardamos en a el resto_x
      ld  h, a         ; guardamos en h el resto_x
      ld  a, e_x(ix)   ; guardamos la x en a
      sub h            ; le restamos a la x el resto
      ld (nueva_x), a  ; ya tenemos la nueva x
      ld a, e_y(ix)
      add #16
      ld b, a         ; guardamos el acumulado de la operacion
      ld a, (resto_y) ; guardamos en a el resto_y
      ld h, a         ; guardamos en h el resto_y
      ld a, b         ; guardamos en a el acumulado de la operación
      sub a, h        ; le restamos a 'a' el valor de 'h', es decir, el acumulado menos el resto
      ld (nueva_y), a
      push de
      bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
      jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
      call crear_obstaculo_por_nueva_xy
      pop de

      ld a, (nueva_x)
      add a, #4
      ld (nueva_x), a
      bit 1, d         ; si este obstáculo no hay que crearlo.. 
      ret z            ; ..nos salimos
      call crear_obstaculo_por_nueva_xy
      ret
   
   x_no_cero_dir_5::
      ld   a, #20
      call get_d_dir_5
      or d          ; si todos los tiles eran fondo..
      ret z         ; ..nos salimos

      ld  a, (resto_x) ; guardamos en a el resto_x
      ld  h, a         ; guardamos en h el resto_x
      ld  a, e_x(ix)   ; guardamos la x en a
      sub h            ; le restamos a la x el resto
      ld (nueva_x), a  ; ya tenemos la nueva x
      ld a, e_y(ix)
      add #8
      ld (nueva_y), a
      push de
      bit 0, d         ; lo hemos calculado porque el primero siempre es obligatorio
      jr  z, . + 5     ; pero si no hay que crearlo, no lo creamos
      call crear_obstaculo_por_nueva_xy
      pop de

      ld a, (nueva_x)
      add a, #4
      ld (nueva_x), a
      bit 1, d         ; si este obstáculo no hay que crearlo.. 
      ret z            ; ..nos salimos
      call crear_obstaculo_por_nueva_xy
      ret


; Input
; ESTO NO--   hl: pos en memoria del obstáculo
;     resto_y y resto_x: cargadas en memoria
;     a:  pos del obstáculo según el dibujo de abajo
;     |8 1 2|
;     |7 E 3|
;     |6 5 4|
crear_obstaculos_segun_direccion::
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

   ld a, (direccion_movimiento)
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
   jp crear_obstaculos_dir_5

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
