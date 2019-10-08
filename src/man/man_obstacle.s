;;
;; COMPONENT MANAGER
;;
.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/man_obstacle.h.s"

.module obstacle_manager

DefineComponentArrayStructure _obstacle, max_obstacles, DefineCmp_Obstacle_default ;; ....


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
