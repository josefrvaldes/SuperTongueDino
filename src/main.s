
;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/state.h.s"
.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;;
;; Start of _CODE area
;; 
.area _CODE


;;
;; MAIN function. This is the entry point of the application.
;;    _main:: global symbol is required for correctly compiling and linking
;;
_main::
   ;; Disable firmware to prevent it from interfering with string drawing
   call cpct_disableFirmware_asm

   call man_state_init

   call man_level_init
   call man_level_insertar_niveles
   call man_tilemap_init

   ;; Loop forever
loop:
   call man_state_update

   call cpct_waitVSYNC_asm
   call man_state_render
   jr    loop