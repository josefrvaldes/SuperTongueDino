.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sprite.h.s"
.include "ent/entity.h.s"
.include "man/entity.h.s"


.globl _hero_sp_0
.globl _hero_sp_1
.globl _hero_sp_2
.globl _hero_sp_3
.globl _enemigo1_sp_0

vx_guardada: .db #0

;;
;; METODO PARA CAMBIO DE SPRITE
;; INPUT:   A sprite  al que queremos cambiar
;; DESTROYS: AF, HL, BC, DE
;;
set_sprite_hero::

    ;call man_entity_getArray  ;; entidad que quiero en IX

    ld a, (vx_guardada)
    add   e_x(ix)
    ld c, a
    ld a, (vx_guardada)
    sub    c
   ; ret  z
    jr  nc, movIz
        ;; NOS MOVEMOS HACIA LA DERECHA

            ld  a,  e_invisi(ix)
            dec a
            jr  z, invisb_der
            ld  hl, #_hero_sp_0
            jr finish_sprite_hero
invisb_der:
            ld  hl, #_hero_sp_2
            jr finish_sprite_hero

movIz:
            ;; LENGUA PARA ABAJO
                ;; invisible?
            ld  a,  e_invisi(ix)
            dec a
            jr  z, invisb_iz
            ld  hl, #_hero_sp_1
            jr finish_sprite_hero
invisb_iz:
            ld  hl, #_hero_sp_3
            jr finish_sprite_hero

finish_sprite_hero:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l

    ret


guardar_VX::
    ld  a, e_vx(ix)
    ld  (vx_guardada), a

    ret