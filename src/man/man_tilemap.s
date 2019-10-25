.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/man_level.h.s"
.include "ent/ent_level.h.s"
.include "man/entity.h.s"
.include "ent/entity.h.s"
.include "sys/sys_calc.h.s"

.globl _level00_pack_end
.globl _level01_pack_end
.globl _tileset_juego_pack_end

decompress_buffer             == 0x40
tileset_max_size              = 0x780
level_max_size                = 0x1F4    ; hay que acordarse de poner en el buildconfig que nuestro código empezará a partir de tileset_max_size + level_max_size, que en este caso es 4F4
total_max_size                = tileset_max_size + level_max_size
decompress_buffer_tilemap_end = decompress_buffer + level_max_size - 1
decompress_buffer_tileset_end = decompress_buffer + total_max_size - 1
tilemap_ptr                   = decompress_buffer + 0
tileset_ptr                   = decompress_buffer + level_max_size

ancho_tilemap                 = #20


tile_player = 46 - 1
tile_e1 = 47 - 1
tile_e2 = 48 - 1
tile_e3 = 49 - 1
tile_e4 = 50 - 1

nueva_x_entity: .db #0
nueva_y_entity: .db #0


; Esta función se tiene que llamar la primera vez de la historia de la humanidad para cargar el primer nivel de todos
man_tilemap_init::
   call man_level_getArray 
   jp man_tilemap_load


man_tilemap_load::
   call man_level_get_current 
   ; descomprimimos tilemap del nivel que toque a continuación del tileset
   ld h, lev_pack_end_h(iy)
   ld l, lev_pack_end_l(iy)
   call man_tilemap_descomprimir_nuevo_nivel

   ; descomprimimos el tileset
   ld hl, #_tileset_juego_pack_end
   ld de, #decompress_buffer_tileset_end
   call cpct_zx7b_decrunch_s_asm
   call man_tilemap_cargar_spawns
   ret


man_tilemap_render::
   ld bc, #0x1914       ; b = alto en tiles, c = ancho en tiles
   ld de, #ancho_tilemap ; ancho en tiles del tilemap, en realidad será fijo, siempre será 20
   ld hl, #tileset_ptr  ; puntero al inicio del tileset
   call cpct_etm_setDrawTilemap4x8_ag_asm


   ld hl, #0xC000       ; posición de memoria de video, a priori siempre será ésta
   ld de, #tilemap_ptr  ; posición al tilemap
   jp cpct_etm_drawTilemap4x8_ag_asm



; Input
;     hl: _levelX_pack_end
; Destroys:
;     DE
man_tilemap_descomprimir_nuevo_nivel::
   ; descomprimimos tilemap del nivel que toque a continuación del tileset
   ld h, lev_pack_end_h(iy)
   ld l, lev_pack_end_l(iy)
   ld de, #decompress_buffer_tilemap_end
   jp cpct_zx7b_decrunch_s_asm


; ; Input:
; ;     a tiene que tener el valor del tile a comparar
; ; Output:
; ;     nada, redirige a otra sección del código, creo que esto es un poco trampa
; hacer_comparaciones_entities:
;    ld e, #tile_player     ; en e guardamos el tile que corresponde con enemigos, hero, etc
;    cp e
;    jr z, era_player
;    ld e, #tile_e1
;    cp e
;    jr z, era_enemigo1
;    ld e, #tile_e2
;    cp e
;    jr z, era_enemigo1
;    ld e, #tile_e3
;    cp e
;    jr z, era_enemigo1
;    ld e, #tile_e4
;    cp e
;    jr z, era_enemigo1
;    jr continuar


man_tilemap_calcular_nueva_x_y:
   ld d, #20
   call dividir_bc_entre_d
   ; en este punto, l es y y a es x
   call multiplicar_a_por_4
   ld (nueva_x_entity), a
   ld a, l
   call multiplicar_a_por_8
   ld (nueva_y_entity), a
   ret


; Input
;     nueva_x y nueva_y cargadas
;     ix la entidad que toque
; Destroy
;     hl, bc, a, ix
man_tilemap_crear_entidad_por_spawn:
   call man_tilemap_calcular_nueva_x_y
   ;ld ix, #hero
   ld a, (nueva_x_entity)
   ld e_x(ix), a
   ld a, (nueva_y_entity)
   ld e_y(ix), a
   ;ld hl, ix

ld    de, #0xC000
   ld    c, e_x(ix)
   ld    b, e_y(ix)
   call  cpct_getScreenPtr_asm
   ld    e_lastVP_l(ix), l
   ld    e_lastVP_h(ix), h
   

   ld__b_ixh  ;; carga d en el registro alto de ix
   ld__c_ixl
   ld h, b
   ld l, c
   call man_entity_create
   ret


man_tilemap_cargar_spawns::
   call man_tilemap_cargar_spawn_hero
   call man_tilemap_cargar_spawn_enemigos
   call man_entity_getArray
   ret



man_tilemap_cargar_spawn_hero:
   call man_entity_init
   call man_entity_getArray
   ; bc será nuestro contador
   ; d  será 20, que corresponde con el ancho del tilemap en tiles
   ; hl será la pos de memoria que iremos incrementando en cada iteración
   ; e será x
   ; d será y
   ; a al principio será el valor del tile, 
   ;           y al final será level_max_size - 1 que lo necesitamos para comparar con el contador para saber si hemso terminado el bucle

   ld hl, #decompress_buffer; nos posicionamos al principio del tilemap en memoria
   ld bc, #0                  ; contador que se incrementará y parará al llegar a level_max_size - 1
   ld d, #20                 ; es el ancho del tilemap

   ; al ser la primera iteración, el contador vale 0 y no podemos dividir entre cero
   ;  así que cargamos en a directamente el valor de 4000, y lanzamos directamente la comparación
   ;  con la nueva_x y nueva_y cargados de antemano, porque sabemos los valores
   ld a, (hl)
   push bc
   push hl
   jr comparaciones_hero

   cargar_spawns_loop_hero:
      inc hl
      
      ld a, (hl)             ; tenemos el valor del byte actual del tilemap en a
      
      push bc                 ; guardamos el valor de bc y hl porque la división los va a romper
      push hl  

      comparaciones_hero:
         ld e, #tile_player     ; en e guardamos el tile que corresponde con enemigos, hero, etc
         cp e
         jr z, era_player
         jr continuar_hero

      
      era_player:
         ld (hl), #0
         ld ix, #hero
         call man_tilemap_crear_entidad_por_spawn
         pop hl
         pop bc
         ret
      

      continuar_hero:
         pop hl
         pop bc
         inc bc
         ld de, #level_max_size - 1 ; cargamos en a el level_max_size - 1
         ld a, d
         cp b     ; si hemos llegado al final, salimos
         jr z, b_es_igual_hero
         jr cargar_spawns_loop_hero
         b_es_igual_hero:
            ld a, e
            cp c
            jr z, salir_hero
         jr cargar_spawns_loop_hero

      salir_hero:
      ret



man_tilemap_cargar_spawn_enemigos:
   ; bc será nuestro contador
   ; d  será 20, que corresponde con el ancho del tilemap en tiles
   ; hl será la pos de memoria que iremos incrementando en cada iteración
   ; e será x
   ; d será y
   ; a al principio será el valor del tile, 
   ;           y al final será level_max_size - 1 que lo necesitamos para comparar con el contador para saber si hemso terminado el bucle


   ld hl, #decompress_buffer; nos posicionamos al principio del tilemap en memoria
   ld bc, #0                  ; contador que se incrementará y parará al llegar a level_max_size - 1
   ld d, #20                 ; es el ancho del tilemap

   ; al ser la primera iteración, el contador vale 0 y no podemos dividir entre cero
   ;  así que cargamos en a directamente el valor de 4000, y lanzamos directamente la comparación
   ;  con la nueva_x y nueva_y cargados de antemano, porque sabemos los valores
   ld a, (hl)
   push bc
   push hl
   jr comparaciones_enemigos

   cargar_spawns_loop_enemigos:
      inc hl
      
      ld a, (hl)             ; tenemos el valor del byte actual del tilemap en a
      
      push bc                 ; guardamos el valor de bc y hl porque la división los va a romper
      push hl  

      comparaciones_enemigos:
      ; en e guardamos el tile que corresponde con enemigos, hero, etc
      ld e, #tile_e1
      cp e
      jr z, era_enemigo1

      ld e, #tile_e2
      cp e
      jr z, era_enemigo2

      ld e, #tile_e3
      cp e
      jr z, era_enemigo3

      ld e, #tile_e4
      cp e
      jr z, era_enemigo4
      jr continuar_enemigos


      era_enemigo1:
         ld (hl), #0
         ld ix, #ene1
         call man_tilemap_crear_entidad_por_spawn
         jr continuar_enemigos

      era_enemigo2:
         ld (hl), #0
         ld ix, #ene2
         call man_tilemap_crear_entidad_por_spawn
         jr continuar_enemigos

      era_enemigo3:
         ld (hl), #0
         ld ix, #ene2
         call man_tilemap_crear_entidad_por_spawn
         jr continuar_enemigos

      era_enemigo4:
         ld (hl), #0
         ld ix, #ene2
         call man_tilemap_crear_entidad_por_spawn
         jr continuar_enemigos
      

      continuar_enemigos:
         pop hl
         pop bc
         inc bc
         ld de, #level_max_size - 1 ; cargamos en a el level_max_size - 1
         ld a, d
         cp b     ; si hemos llegado al final, salimos
         jr z, b_es_igual_enemigo
         jr cargar_spawns_loop_enemigos
         b_es_igual_enemigo:
            ld a, e
            cp c
            jr z, salir_enemigos
            jr cargar_spawns_loop_enemigos

      salir_enemigos:
      ret