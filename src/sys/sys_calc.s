;Inputs:
;     d es el numerador
;     e es el denominador
;Outputs:
;     a es el resto
;     b es 0
;     d es el resultado de d/e
;Destruye:
;     a,b,d,e 
dividir_d_e::
   ld b, #8
   xor a
      sla d
      rla
      cp e
      jr c, .+4
         inc d
         sub e
      djnz .-8
   ret

;Inputs:
;     d es el numerador
;Outputs:
;     a es el resto
;     d es el resultado de d/8
;Destruye:
;     a,b,d,e 
dividir_d_entre_8::
   ld a, #8
   ld e, a
   call dividir_d_e
   ret


;Inputs:
;     d es el numerador
;Outputs:
;     a es el resto
;     d es el resultado de d/4
;Destruye:
;     a,b,d,e 
dividir_d_entre_4::
   ld a, #4
   ld e, a
   call dividir_d_e
   ret



; Inputs:
;     A: el valor a comprobar
; Outputs:
;     A: 0 si positivo o cero, 1 si negativo
; Destroys:
;     A
check_if_negative::
   sub a
   ret z ; si el número era positivo o cero, al restarse a sí mismo, da cero, así que salimos devolviendo 0 en a
   ld a, #1 ; si el número era negativo, al restarse a sí mismo, da un valor distinto de cero, así que cargamos -1 en a y salimos
   ret


; Inputs:
;     A: el valor a comprobar
; Outputs:
;     A: 0 si positivo o cero, 1 si negativo
; Destroys:
;     A
check_if_negative2::
   bit 7, a
   jr z, era_positivo
   era_negativo:
   ld a, #1
   ret
   era_positivo:
   ld a, #0
   ret



;Input:
;     D: multiplicador 1
;     E: multiplicador 2
;Outputs:
;     A es el resultado
;Destroys: 
;     A B D E
multiplicar_d_e_8bits::
   ld b, #8    
   xor a       
      rlca     
      rlc d    
      jr nc, . + 3
         add a,e  
      djnz . - 6  
   ret


;Multiplica dos números de 8 bits dando un resultado de 16 bits
;Inputs:
;     D y C son factores
;Outputs:
;     HL es el resultado
;Destroys:
;     A, B, C, D, H, L
;===============================================================
multiplicar_d_c_16bits::
   xor a          ;nos aseguramos de que a vale cero
   ld b, #8        ;número de bits en E, es decir, el número de veces que haremos loop
   multiplicar_d_e_16bitsLoop:
   add a, a       ;Duplicamos a, así nos movemos hacia la izquierda. Se activa el flag c.
   rl c           ;Rotamos C y ponemos el próximo bit en el flag c
   jr nc, . + 6   ;Si es 0, no le sumamos nada a a
      add a, d    ;Como no era cero, hacemos A+1*D
      jr nc, . + 3;Comprobamos si hay carry
         inc c    ;Si hay carry, incrementamos c
      djnz multiplicar_d_e_16bitsLoop     ;Decrementa B, si todavía no es cero, volvemos al loop:
   ld h, c
   ld l, a
   ret