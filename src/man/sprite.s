.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sprite.h.s"
.include "ent/entity.h.s"
.include "man/entity.h.s"


.globl _hero_sp_0
.globl _hero_sp_1
.globl _hero_sp_2
.globl _hero_sp_3
.globl _hero_sp_4
.globl _hero_sp_5
.globl _hero_sp_6
.globl _hero_sp_7
.globl _enemigo2_sp_0
.globl _enemigo2_sp_1
.globl _enemigo2_sp_2
.globl _enemigo2_sp_3
.globl _enemigo2_sp_4
.globl _enemigo2_sp_5
.globl _enemigo2_sp_6
.globl _enemigo2_sp_7

vx_actual:     .db #0
paso_hero:      .db #0         ;; 0 PASO1 // 1 PASO2
paso_enemy2:     .db #0         ;; 0 PASO1 // 1 PASO2
tempo_hero:    .db #0x05
tempo_enemy2:  .db #0x0F


;;
;; SYS_PHYSICS UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX, IY, HL -- TODOS
;; Stack Use: 2 bytes
aplicate_animation::
   ld (_ent_counter), a

_update_loop:


    _ent_counter = . + 1
    ld  a, #0
    dec     a
    ret z

    ld  a, e_ai_st(ix)
    cp  #e_ai_st_patrullar
    jr  nz, next_ix
            call set_sprite_enemy2
        jr not_more_animation
next_ix:
    cp  #e_ai_st_noAI
    jr  nz, next_ix2
            call set_sprite_hero
        jr not_more_animation
next_ix2:
            ;;call set_sprite_enemy1

not_more_animation:

   ld (_ent_counter), a
   ld de, #sizeof_e
   add   ix, de
   jr _update_loop



;;
;; METODO PARA CAMBIO DE SPRITE
;; INPUT:   A sprite  al que queremos cambiar
;; DESTROYS: AF, HL, BC, DE
;;
set_sprite_hero::

    ;call man_entity_getArray  ;; entidad que quiero en IX
    ld a, e_vx(ix)
    cp  #0
    jr  z, procesar_invisibilidad_sprite          ;; si la velocidad en x no se modifica no entro al contador
    ;; pero si debo permitir cambio de sprote de invisibilidad

    ld  a,  (paso_hero)
    ld  b, a


    ld  a, (tempo_hero)
    dec  a
    ld  (tempo_hero), a
    jr  nz, procesar_cambios_sprite
        ;; entramos y reseteamos
        ld  a, #0x05
        ld  (tempo_hero), a

        ;; ACTUAMOS
        ld  a, (paso_hero)
        dec a
        jr  z, es_paso2
            ;; ES PASO 1
            ld  a, #1
            ld  (paso_hero), a
            ;call    sprite_hero_direction_paso1
            jr  procesar_cambios_sprite
es_paso2:
            ;; ES PASO 2
            ld  a, #0
            ld  (paso_hero), a
            ;call    sprite_hero_direction_paso2
            ;ret

procesar_cambios_sprite:

    ld  a, (paso_hero)
    dec a
    jr  z, procesar_paso2
        call    sprite_hero_paso1
        jr  finish_sprite_hero
procesar_paso2:
        call    sprite_hero_paso2
        jr  finish_sprite_hero


procesar_invisibilidad_sprite:
    ;; MOVIMINETO HACIA LA DERECHA
    ld  a,  e_invisi(ix)
    dec a
    jr nz, visibility
        call sprite_hero_invisibilidad_stopped
    jr  finish_sprite_hero
visibility:
        call sprite_hero_visibilidad_stopped  
finish_sprite_hero:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l


    ret
;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_hero_paso1:

    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso1
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a,  e_invisi(ix)
        dec a
        jr nz,  no_invisibilidad_paso1_der
            ;; INVISIBLE
            ld  hl, #_hero_sp_2
        ret
no_invisibilidad_paso1_der:
            ;; VISIBLE
            ld  hl, #_hero_sp_0
        ret

movIz_paso1:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
    ld  a,  e_invisi(ix)
    dec a
    jr nz,  no_invisibilidad_paso1_iz
        ;; INVISIBLE
        ld  hl, #_hero_sp_3
    ret
no_invisibilidad_paso1_iz:
        ;; VISIBLE
        ld  hl, #_hero_sp_1
    ret
;======================================================
sprite_hero_paso2:

    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a,  e_invisi(ix)
        dec a
        jr nz,  no_invisibilidad_paso2_der
            ;; INVISIBLE
            ld  hl, #_hero_sp_6
        ret
no_invisibilidad_paso2_der:
            ;; VISIBLE
            ld  hl, #_hero_sp_4
        ret

movIz_paso2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
    ld  a,  e_invisi(ix)
    dec a
    jr nz,  no_invisibilidad_paso2_iz
        ;; INVISIBLE
        ld  hl, #_hero_sp_7
    ret
no_invisibilidad_paso2_iz:
        ;; VISIBLE
        ld  hl, #_hero_sp_5
    ret
;==============================================
sprite_hero_invisibilidad_stopped:
    ;; INVISIBLE
    add   e_x(ix)
    ld c, a
    ld a, (vx_actual)
    sub    c
    jr  nc, inv_iz
        ;; MOVIMINETO HACIA LA DERECHA
        ld  hl, #_hero_sp_2
    ret
inv_iz:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  hl, #_hero_sp_3
    ret
;===================================================
sprite_hero_visibilidad_stopped:
    ;; INVISIBLE
    add   e_x(ix)
    ld c, a
    ld a, (vx_actual)
    sub    c
    jr  nc, v_iz
        ;; MOVIMINETO HACIA LA DERECHA
        ld  hl, #_hero_sp_0
    ret
v_iz:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  hl, #_hero_sp_1
    ret
;;
;;
;;
guardar_VX:
    ld  (vx_actual), a

    ret




set_sprite_enemy2::
    ld  a,  (paso_enemy2)
    ld  b, a                                ;; guardamos el paso actual en B


    ld  a, (tempo_enemy2)
    dec  a
    ld  (tempo_enemy2), a
    jr  nz, procesar_cambios_sprite_enemy2
        ;; entramos y reseteamos
        ld  a, #0x0F
        ld  (tempo_enemy2), a
        ;; ACTUAMOS
        ld  a, (paso_enemy2)
        dec a
        jr  z, es_paso2_enemy2
            ld  a, #1
            ld  (paso_enemy2), a
            jr  procesar_cambios_sprite_enemy2
es_paso2_enemy2:
            ld  a, #0
            ld  (paso_enemy2), a

procesar_cambios_sprite_enemy2:

    ld  a, (paso_enemy2)
    dec a
    jr  z, procesar_paso2_enemy2
        call    sprite_enemy2_paso1
        jr  finish_sprite_enemy2
procesar_paso2_enemy2:
       ; call    sprite_enemy2_paso2
        call    sprite_enemy2_paso2

finish_sprite_enemy2:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l

    ret




;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy2_paso1:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso1_enemy2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a, e_vy(ix)
        or  a
        jp  m, movDer_grav_paso1_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_0
        ret
movDer_grav_paso1_enemy2:
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_4
        ret

movIz_paso1_enemy2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  a, e_vy(ix)
        or  a
        jp  m, movIz_grav_paso1_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_1
        ret
movIz_grav_paso1_enemy2:
            ld  hl, #_enemigo2_sp_5
        ret

;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy2_paso2:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso2_enemy2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a, e_vy(ix)
        or  a
        jp  m, movDer_grav_paso2_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_2
        ret
movDer_grav_paso2_enemy2:
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_6
        ret

movIz_paso2_enemy2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  a, e_vy(ix)
        or  a
        jp  m, movIz_grav_paso2_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_3
        ret
movIz_grav_paso2_enemy2:
            ld  hl, #_enemigo2_sp_7
        ret


