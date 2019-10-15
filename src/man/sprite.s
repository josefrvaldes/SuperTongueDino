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
.globl _enemigo1_sp_0

vx_actual:   .db #0
paso_sprite: .db #0         ;; 0 PASO1 // 1 PASO2
tempo1:      .db #0x07
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

    ld  a,  (paso_sprite)
    ld  b, a


    ld  a, (tempo1)
    dec  a
    ld  (tempo1), a
    jr  nz, procesar_cambios_sprite
        ;; entramos y reseteamos
        ld  a, #0x07
        ld  (tempo1), a

        ;; ACTUAMOS
        ld  a, (paso_sprite)
        dec a
        jr  z, es_paso2
            ;; ES PASO 1
            ld  a, #1
            ld  (paso_sprite), a
            ;call    sprite_hero_direction_paso1
            jr  procesar_cambios_sprite
es_paso2:
            ;; ES PASO 2
            ld  a, #0
            ld  (paso_sprite), a
            ;call    sprite_hero_direction_paso2
            ;ret

procesar_cambios_sprite:


    ld  a, (paso_sprite)
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
    ret nz
        call sprite_hero_invisibilidad

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

    add   e_x(ix)
    ld c, a
    ld a, e_vx(ix)
    sub    c
    jr  nc, movIz_paso1
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



sprite_hero_paso2:

    add   e_x(ix)
    ld c, a
    ld a, e_vx(ix)
    sub    c
    jr  nc, movIz_paso2
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





sprite_hero_invisibilidad:
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
;;
;;
;;
guardar_VX:
    ld  (vx_actual), a

    ret