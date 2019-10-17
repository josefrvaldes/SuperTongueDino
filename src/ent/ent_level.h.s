;;
;; Entity LEVEL, this is the default level entity
;;

max_levels == 20

;; Defines a new entity component
.macro DefineCmp_Level _pack_end
   .dw   _pack_end   
.endm

lev_pack_end_l        = 0
lev_pack_end_h        = 1
sizeof_level        = 2


;; Default constructor for entity components
.macro DefineCmp_Level_default
   DefineCmp_Level 0x0000 ;; reserva el espacio de una entidad, NO!! crea una entidad
.endm

;; Defines entity array for components
.macro DefineCmpArray_Level _N
   .rept _N
      DefineCmp_Level_default
   .endm
.endm
