;
; BowlingGame.asm
;
; Created: 4/19/2023 4:30:33 PM
; Author : jcubm
;

; Constants
.equ ButtonDir = DDRD
.equ ButtonReg = DDD2
.equ ButtonPort = PORTD
.equ ButtonPin = PD2

; Vector Table
.org 0x0000				; Reset vector
	jmp main

.org INT0addr				; Bowling ball button interrupt.
	jmp shoot_ball

.org INT_VECTORS_SIZE		
; End vector table.


main:     
	; init stack
     ldi  r16,HIGH(RAMEND)
     out  SPH,r16
     ldi  r16,LOW(RAMEND)
     out  SPL,r16

	; Init GPIO
	cbi ButtonDir, ButtonReg ; Button pull-up.
	sbi ButtonPort, ButtonPin

	; Init Bowling Ball LEDS [b0-b2]
	sbi	DDRB, DDB0
	sbi	PORTB, PB0
	sbi	DDRB, DDB1	
	sbi	DDRB, DDB2		

	; Init Interrupts
	ldi	r16, (1<<INT0)
	out	EIMSK, r16
	ldi	r16, (1<<ISC01)
	sts	EICRA, 16
	sei					; Enable global interupts.

main_loop:
	; Bowling ball leds = [PD3, PD4, PD5]





    rjmp main_loop
