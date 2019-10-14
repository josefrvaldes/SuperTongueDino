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
.globl _enemigo1_sp_0

vx_guardada: .db #0
paso_sprite: .db #0         ;; 0 PASO1 // 1 PASO2
tempo1:      .db #0x20
;;
;; METODO PARA CAMBIO DE SPRITE
;; INPUT:   A sprite  al que queremos cambiar
;; DESTROYS: AF, HL, BC, DE
;;
set_sprite_hero::

    ;call man_entity_getArray  ;; entidad que quiero en IX
    ld a, e_vx(ix)
    cp  #0
    ret z

    ld  a,  (paso_sprite)
    ld  b, a


    ld  a, (tempo1)
    dec  a
    ld  (tempo1), a
    jr  nz, salto_tempo
        ;; entramos y reseteamos
        ld  a, #0x20
        ld  (tempo1), a

        ;; ACTUAMOS
        ld  a, (paso_sprite)
        dec a
        jr  z, es_paso2
            ;; ES PASO 1
            ld  a, #1
            ld  (paso_sprite), a
                call    sprite_hero_direction_paso1
                call    sprite_visibility
            jr  finish_sprite_hero
es_paso2:
            ;; ES PASO 2
            ld  a, #0
            ld  (paso_sprite), a
                call    sprite_hero_direction_paso2
                call    sprite_visibility
            ;ret


   ; ret  z
  ;  jr  nc, movIz
        ;; NOS MOVEMOS HACIA LA DERECHA

   ;         ld  a,  e_invisi(ix)
    ;        dec a
     ;       jr  z, invisb_der
      ;      ld  hl, #_hero_sp_0
       ;     jr finish_sprite_hero
;invisb_der:
 ;           ld  hl, #_hero_sp_2
  ;          jr finish_sprite_hero

;movIz:
            ;; LENGUA PARA ABAJO
                ;; invisible?
 ;           ld  a,  e_invisi(ix)
  ;          dec a
   ;         jr  z, invisb_iz
    ;        ld  hl, #_hero_sp_1
     ;       jr finish_sprite_hero
;invisb_iz:
 ;           ld  hl, #_hero_sp_3
  ;          jr finish_sprite_hero

finish_sprite_hero:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l
salto_tempo:

    ret

;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_hero_direction_paso1:
    add   e_x(ix)
    ld c, a
    ld a, e_vx(ix)
    sub    c
    jr  nc, movIz_paso1
            ld  hl, #_hero_sp_0
        ret
movIz_paso1:
        ;; EN DERECHA  ES EL 1
            ld  hl, #_hero_sp_1
        ret

;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_hero_direction_paso2:
    add   e_x(ix)
    ld c, a
    ld a, e_vx(ix)
    sub    c
    jr  nc, movIz_paso2
        ;; EN DERECHA  ES EL  4
            ld  hl, #_hero_sp_4
        ret
movIz_paso2:
        ;; EN DERECHA  ES EL  5
            ld  hl, #_hero_sp_5
        ret





sprite_visibility:

    ret


guardar_VX::
    ld  a, e_vx(ix)
    ld  (vx_guardada), a

    ret