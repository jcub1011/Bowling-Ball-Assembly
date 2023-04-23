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

.equ BowlingBallPort = PORTD
.equ	BowlingBallPin	= PIND
.equ BowlingBallData = DDRD
.equ BowlingBallStart = PD3
.equ BowlingBallEnd = PD5

.equ	BowlPinData = DDRB
.equ	BowlPinPin = PINB
.equ	BowlPinPort = PORTB
.equ	BowlPinLeft = PB4
.equ	BowlPinRight = PB5
.equ	BowlPinMid = PB3

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
	cbi ButtonDir, ButtonReg			; Button pull-up.
	sbi ButtonPort, ButtonPin

	; Init Bowling Ball LEDS [D3-D5]
	sbi	BowlingBallData, DDD3
	sbi	BowlingBallPort, PD3		; Have one led on at startup.
	sbi	BowlingBallData, DDD4
	sbi	BowlingBallData, DDD5

	; Init Pin LEDs
	sbi	BowlPinData, BowlPinLeft		; Turn on output.
	sbi	BowlPinData, BowlPinRight	; Turn on output.
	sbi	BowlPinData, BowlPinMid		; Turn on output.
	sbi	BowlPinPort, BowlPinLeft		; Turn on output.
	sbi	BowlPinPort, BowlPinRight	; Turn on output.
	sbi	BowlPinPort, BowlPinMid		; Turn on output.

	; Init Interrupts
	ldi	r16, (1<<INT0)
	out	EIMSK, r16
	ldi	r16, (1<<ISC01)
	sts	EICRA, r16
	sei					; Enable global interupts.

main_loop:
	; Bowling ball leds = [PD3, PD4, PD5]
	call	update_ball_position

	rjmp main_loop



shoot_ball:
	call wait_1_sec

	; Update bowling pins.

shoot_ball_ret:
	reti






update_ball_position:
	; Init timer delay.
	ldi	r20, 0xE7				; For 100ms timer.
	sts	TCNT1H, r20
	ldi	r20, 0x96				; For 100ms timer.
	sts	TCNT1L, r20

	; Set normal mode
	ldi	r20, 0
	sts	TCCR1A, r20

	; Set clock select: 256 prescaler
	ldi	r20, 0x04
	sts	TCCR1B, r20

update_ball_position_timer_loop:
	sbis	tifr1, tov1			; Check if overflow flag set.
	rjmp	update_ball_position_timer_loop

	clr	r20
	sts	tccr1b, r20			; Stop timer
	sbi	tifr1, tov1			; Clear flag.

	in	r16, BowlingBallPin		; Read in what leds are on.
	andi	r16, (1<<PD3)|(1<<PD4)|(1<<PD5)		; Mask for led registers.

	lsl	r16					; Move to next led. (shifts bits to the left)
	ldi	r17, (1<<BowlingBallEnd)	; Register of last led.
	lsl	r17					; Register after last led.

	cp	r16, r17				; Check if equal.

	brne	reset_count_skip

reset_count:
	ldi	r16, (1<<BowlingBallStart)
	ori	r16, (1<<ButtonPin)		; To not overwrite the pullup mode.
	out	BowlingBallPort, r16	; Restart led position.
	rjmp	update_ball_position_ret

reset_count_skip:
	ori	r16, (1<<ButtonPin)		; To not overwrite the pullup mode.
	out	BowlingBallPort, r16	; Update led.

update_ball_position_ret:
	ret						; Update_ball_position.


wait_1_sec:
	; Init timer delay.
	ldi	r20, 0x0B				; For 1000ms timer.
	sts	TCNT1H, r20
	ldi	r20, 0xDC				; For 1000ms timer.
	sts	TCNT1L, r20

	; Set normal mode
	ldi	r20, 0
	sts	TCCR1A, r20

	; Set clock select: 256 prescaler
	ldi	r20, 0x04
	sts	TCCR1B, r20
	

wait_1_sec_loop:
	sbis	tifr1, tov1			; Check if overflow flag set.
	rjmp	wait_1_sec_loop
	ret