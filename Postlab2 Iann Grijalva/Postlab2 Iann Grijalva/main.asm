;************************
; Universidad del Valle de Guatemala
; IE2025: Programación de Microcontroladores.
; PreLab2 Display.asm
;
; Created: 17/02/2025
; Author : Iann Grjalva
; Proyecto: post lab 2 
; Hardware: ATMega328P
;************************


.include "M328PDEF.inc"
.org 0x0000
    RJMP START  

START:
    LDI    R16, 0xFF
    OUT    DDRC, R16        ; configurar PORTC como salida 
    LDI    R16, 0x05
    OUT    TCCR0B, R16      ; configurar Timer0 con prescaler de 1024
    LDI    R16, 0xFF
    OUT    DDRD, R16        ; configurar PORTD como salida 
    LDI    R16, 0x00
    OUT    DDRB, R16        ; configurar PORTB como entrada
    LDI    R16, 0xFF
    OUT    PORTB, R16       ; pull-up en PB3 y PB2

    ; puntero Z para la tabla de valores del display
    LDI    ZH, 0X01
    LDI    ZL, 0X00

    ; cargar la tabla de valores para los números 0-F en el display de 7 segmentos
    LDI    R16, 0b00111111  ;0
    ST     Z+, R16
    LDI    R16, 0b00000110  ;1
    ST     Z+, R16
    LDI    R16, 0b01011011  ;2
    ST     Z+, R16
    LDI    R16, 0b01001111  ;3
    ST     Z+, R16
    LDI    R16, 0b01100110  ;4
    ST     Z+, R16
    LDI    R16, 0b01101101  ;5
    ST     Z+, R16
    LDI    R16, 0b01111101  ;6
    ST     Z+, R16
    LDI    R16, 0b00000111  ;7
    ST     Z+, R16
    LDI    R16, 0b01111111  ;8
    ST     Z+, R16
    LDI    R16, 0b01101111  ;9
    ST     Z+, R16
    LDI    R16, 0b01110111  ;A
    ST     Z+, R16
    LDI    R16, 0b01111100  ;B
    ST     Z+, R16
    LDI    R16, 0b00111001  ;C
    ST     Z+, R16
    LDI    R16, 0b01011110  ;D
    ST     Z+, R16
    LDI    R16, 0b01111001  ;E
    ST     Z+, R16
    LDI    R16, 0b01110001  ;F
    ST     Z+, R16

    ; reiniciar la tabla
    LDI    ZH, 0X01
    LDI    ZL, 0X00
    LD     R16, Z
    OUT    PORTD, R16
    LDI    R20, 0x00        ; contador en 0
    CLR    R23              ; contador de 100ms

MAIN_LOOP:
    RCALL  T100ms          ; esperar 100ms antes de actualizar
    INC    R23             ; incrementar contador de 100ms
    CPI    R23, 10         ; verificar si pasaron 1000ms (10 * 100ms)
    BRNE   sinc  ; si no es 1 segundo, saltar incremento
    CLR    R23             ; reiniciar contador de 100ms
    INC    R17             ; incrementar el contador del display
    ANDI   R17, 0x0F       ; mantener solo 4 bits

sinc:
    IN     R16, PORTC      ; leer estado actual de PORTC
    ANDI   R16, 0x10    
    MOV    R22, R17        ; copiar contador a R22
    ANDI   R22, 0x0F    
    OR     R16, R22        ; combinar con estado del LED
    OUT    PORTC, R16      ; actualizar PORTC

    RCALL  ccon            ; verificar coincidencia de contadores
    RCALL  revb     
    RJMP   MAIN_LOOP

revb:
    SBIC   PINB, 2         ; si PB2 (incremento) está en bajo
    RJMP   cdec            ; si no, revisar decremento
    RCALL  DELAY   

    INC    R20             ; incrementar contador
    ANDI   R20, 0x0F 

    RCALL  actualizar_display  ; actualizar el display
    RCALL  WAIT_FOR_RELEASE   
    RET

cdec:
    SBIC   PINB, 3         ; si PB3 (decremento) está en bajo
    RET         
    RCALL  DELAY  

    DEC    R20             ; decrementar contador
    ANDI   R20, 0x0F 

    RCALL  actualizar_display  ; actualizar el display
    RCALL  WAIT_FOR_RELEASE    
    RET

actualizar_display:
    LDI    ZH, 0x01        ; recargar parte alta de la tabla
    LDI    ZL, 0x00        ; recargar parte baja de la tabla
    MOV    R16, R20        ; copiar contador
    ADD    ZL, R16         ; calcular dirección en la tabla
    LD     R16, Z          ; cargar valor 
    OUT    PORTD, R16      ; mostrar en el display
    RET

ccon:
    CP     R17, R20        ; comparar contadores
    BRNE   recheck   

    CLR    R17             ; reiniciar contador de segundos
    SBRS   R21, 0          ; si el bit 0 de R21 es 1, encender LED
    RJMP   alrm1           ; si está apagado, encender
    RJMP   alrm0           ; si está encendido, apagar

alrm1:
    SBI    PORTC, 5        ; encender LED en PC5
    LDI    R16, 1
    MOV    R21, R16        ; marcar LED como encendido
    RET

alrm0:
    CBI    PORTC, 5        ; apagar LED en PC5
    CLR    R21             ; marcar LED como apagado
    RET

recheck:
    RET

T100ms:
    LDI    R18, 13         
TIMER: 
    SBIS   TIFR0, TOV0
    RJMP   TIMER
    LDI    R16, (1 << TOV0)
    OUT    TIFR0, R16
    DEC    R18
    BRNE   TIMER
    RET

WAIT_FOR_RELEASE:
    SBIS   PINB, 2
    RJMP   WAIT_FOR_RELEASE
    SBIS   PINB, 3
    RJMP   WAIT_FOR_RELEASE
    RET

DELAY:
    LDI    R18, 0xFF
SUB_DELAY1:
    DEC    R18
    CPI    R18, 0
    BRNE   SUB_DELAY1
    LDI    R18, 0xFF
SUB_DELAY2:
    DEC    R18
    CPI    R18, 0
    BRNE   SUB_DELAY2
    RET