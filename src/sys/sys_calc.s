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
   xor a         ;This is an optimised way to set A to zero. 4 cycles, 1 byte.
   ld b,#8        ;Number of bits in E, so number of times we will cycle through
   multiplicar_d_e_16bitsLoop:
   add a,a       ;We double A, so we shift it left. Overflow goes into the c flag.
   rl c          ;Rotate overflow in and get the next bit of C in the c flag
   jr nc,.+6     ;If it is 0, we don't need to add anything to A
      add a,d     ;Since it was 1, we do A+1*D
      jr nc,.+3   ;Check if there was overflow
         inc c     ;If there was overflow, we need to increment E
      djnz multiplicar_d_e_16bitsLoop     ;Decrements B, if it isn't zero yet, jump back to Loop:
   ld h, c
   ld l, a
   ret