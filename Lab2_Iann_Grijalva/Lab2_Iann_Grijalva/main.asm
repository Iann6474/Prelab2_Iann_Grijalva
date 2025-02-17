;************************
; Universidad del Valle de Guatemala
; IE2025: Programación de Microcontroladores.
; PreLab2 Display.asm
;
; Created: 13/02/2025
; Author : Iann Grjalva
; Proyecto: l2ab 
; Hardware: ATMega328P
; Modificado:
; Descripción: Este programa hace un contador hex 
;************************


.include "m328Pdef.inc"
.def alm = r16          ; Registro temporal
.def dis = r17          ; Valor actual del display
.def sb = r18           ; Estado actual de los botones
.def sb1 = r19          ; Estado anterior botón 1
.def sb2 = r20          ; Estado anterior botón 2
.def verb = r21         ; Variable para debounce

.equ B1 = 5            ; Botón 1 en PB5 
.equ B2 = 4            ; Botón 2 en PB4 

.cseg
.org 0x00
    rjmp setup

setup:
    ; Inicializar Stack Pointer
    ldi alm, high(RAMEND)
    out SPH, alm
    ldi alm, low(RAMEND)
    out SPL, alm
    
    ; Configurar pines de botones como entrada con pull-up
    ldi alm, (1 << B1) | (1 << B2)
    out DDRB, alm
    out PORTB, alm
    
    ; Configurar puerto D como salida
    ldi alm, 0xFF
    out DDRD, alm
    
    ; Inicializar tabla de segmentos en SRAM
    ldi ZH, 0x00
    ldi ZL, 0x00  
    
    ; Tabla de valores para display de 7 segmentos
    ldi alm, 0b10111110  ; 0
    st Z+, alm
    ldi alm, 0b00001100  ; 1
    st Z+, alm
    ldi alm, 0b01110110  ; 2
    st Z+, alm
    ldi alm, 0b01011110  ; 3
    st Z+, alm
    ldi alm, 0b11001100  ; 4
    st Z+, alm
    ldi alm, 0b11011010  ; 5
    st Z+, alm
    ldi alm, 0b11111010  ; 6
    st Z+, alm
    ldi alm, 0b00001110  ; 7
    st Z+, alm
    ldi alm, 0b11111110  ; 8
    st Z+, alm
    ldi alm, 0b11011110  ; 9
    st Z+, alm
    ldi alm, 0b11101110  ; A
    st Z+, alm
    ldi alm, 0b11111000  ; B
    st Z+, alm
    ldi alm, 0b10110010  ; C
    st Z+, alm
    ldi alm, 0b01111100  ; D
    st Z+, alm
    ldi alm, 0b11110010  ; E
    st Z+, alm
    ldi alm, 0b11100010  ; F
    st Z+, alm
    
    ; Inicializar variables
    clr dis
    ser sb1
    ser sb2
    
    rcall mostrarNumero

main_loop:
    ; Leer estado de botones
    in sb, PINB
    
    ; Verificar botón 1 (incremento)
    mov verb, sb
    com verb
    andi verb, (1 << B1)
    breq check_b2
    sbrc sb1, B1
    rcall incremento
    
check_b2:
    ; Verificar botón 2 (decremento)
    mov verb, sb
    com verb
    andi verb, (1 << B2)
    breq update_states
    sbrc sb2, B2
    rcall decremento

update_states:
    ; Actualizar estados anteriores
    mov sb1, sb
    mov sb2, sb
    rcall delay_ms
    rjmp main_loop

incremento:
    inc dis
    cpi dis, 0x10
    brne no_reset_inc
    clr dis
no_reset_inc:
    rcall mostrarNumero
    ret

decremento:
    tst dis
    brne no_reset_dec
    ldi dis, 0x0F
    rjmp mostrarNumero
no_reset_dec:
    dec dis
    rcall mostrarNumero
    ret

mostrarNumero:
    ldi ZH, 0x00
    ldi ZL, 0x00
    add ZL, dis
    ld alm, Z
    out PORTD, alm
    ret
;anti rebote
delay_ms:
    ldi r24, 50
delay_loop1:
    ldi r25, 200
delay_loop2:
    dec r25
    brne delay_loop2
    dec r24
    brne delay_loop1
    ret