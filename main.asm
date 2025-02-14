;************************
; Universidad del Valle de Guatemala
; IE2025: Programación de Microcontroladores.
; PreLab2 Display.asm
;
; Created: 13/02/2025
; Author : Iann Grjalva
; Proyecto: Prelab 
; Hardware: ATMega328P
; Modificado:
; Descripción: Este programa hace un contador de 4 bits sin necesidad de un push
;************************



.include "M328PDEF.inc"
.org 0x0000


ldi r16, 0xFF       
out DDRC, r16        ; puerto C salida


ldi r16, 0x05        ; prescaler de 1024
out TCCR0B, r16      ; configurar el Timer0


loop:
    call T100ms    
    inc r17              ; incrementar el contador 
    out PORTC, r17       
    rjmp loop            

T100ms:
    ldi r18, 6     
tiempo:
    sbis TIFR0, TOV0     ;esperar a que el Timer0 se desborde
    rjmp tiempo            
    ldi r16, (1<<TOV0)   ;restablecer la bandera de desbordamiento
    out TIFR0, r16       
    dec r18              
    brne tiempo            
    ret
