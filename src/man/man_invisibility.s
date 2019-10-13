;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "ent/entity.h.s"


tempo1: .db 0x0A    
tempo2: .db 0x0A

;; CONCLUSIONES: 0x0F = 5 segundos
;;         0x20 = 20 segundos


aplicate_invisibility::

    ;; APLICAMOS INVISIBILIDAD
    ld  a,  e_invisi(ix)
    dec a
    ret nz                    ;; si no se hace 0 es que no era invisible

loop:
    ld  a, (tempo1)
    dec  a
    ld  (tempo1), a
    jr  nz, salto_tempo
      ld  a, #0x0A
      ld  (tempo1), a
      ;jr  salto_tempo


      ld  a, (tempo2)
      dec  a
      ld  (tempo2), a
      jr  nz, salto_tempo

        ;; PINTAMOS ALGO, CUALQUIER COSA CONNNNNYOOOO
          ld  de, #0xC000
          ld  a, #0xFF
          ld  c, #8
          ld  b, #8
              call cpct_drawSolidBox_asm

        ;;VOLVEMOS AL ESTADO PRINCIPAL
        ld  a,  #0
        ld  e_invisi(ix), a

        ld  a, #0x0A
        ld  (tempo1), a
        ld  (tempo2), a

salto_tempo:

  ret