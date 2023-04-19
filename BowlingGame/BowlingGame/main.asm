;
; BowlingGame.asm
;
; Created: 4/19/2023 4:30:33 PM
; Author : jcubm
;

; Vector Table
.org 0x0000				; Reset vector
	jmp main

.org INT0addr				; Bowling ball button interrupt.
	jmp shoot_ball

.org INT_VECTORS_SIZE		
; End vector table.


main:
    inc r16



main_loop:
    rjmp main_loop
