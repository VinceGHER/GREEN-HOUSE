; file:	motor.asm   
; target: ATmega128L-4MHz-STK300
; description: file to control S3003 FUTABA Servo motor
; authors: Vincent Gherold & Alain Schöbi

; === definitions ===
.equ SERVOPIN = 5
.equ PORTMOTOR = PORTB      ; defines the port of motor


; === SRAM bytes ===
.dseg
		sMOTORHIGH: .byte 1
		sMOTORLOW:	.byte 1
.cseg

; === macros ===
; --- STSI ---
; store value direct in register 
; in SRAM adress, value
; mod w
; out SRAM
; ---
.macro STSI
	ldi w, @1
	sts @0, w
.endmacro


; --- OUTLDS ---
; store I/O register from register 
; in I/O register, sram register
; mod w
; out I/O
; ---
.macro OUTLDS
	lds w, @1
	out @0, w
.endmacro


; === subroutines ===
; --- initMotor ---
; initializes the motor, the PORTMOTOR, the timer2 
; mod w, PORTMOTOR, timer2, sMOTORHIGH, sMOTORLOW
; ---
initMotor:
	in w, PORTMOTOR-1				; configure PORTMOTOR as output
	ori w, (1<<SERVOPIN)
	out PORTMOTOR-1, w

	P0		PORTMOTOR, SERVOPIN     ; set line to low

	OUTI  TCCR2, (1<<CTC2) + 5		; prescaler:  CS2 = 5, prescaler = 1024, freq = 4000/128 = 3.9 kHz, period = 256 us
	rcall openWindow				; open window by default

	in w, TIMSK
	ori w, (1<<OCIE2)				; set OCIE2 for output compare mode
	out TIMSK, w	  
	ret


; --- iMotorLogic ---
; interruption of timer2, controls the signal sent to the motor
; mod _sreg, timer2
; out timer2
; ---
iMotorLogic:
	in _sreg, SREG					; save context
	PUSH2 w, _w

	in w, OCR2						; loads current output compare register OCR2
	lds _w, sMOTORHIGH				; loads sMOTORHIGH
	cp w, _w						; if (OCR2 != sMOTORHIGH) -> set line to low
	brne notEqual					; if (OCR2 == sMOTORHIGH) -> set line to high
	P0	PORTMOTOR, SERVOPIN			; set PORTMOTOR to 0
	
	OUTLDS OCR2, sMOTORLOW			; set OCR2 to sMOTORLOW
	rjmp final

notEqual:
	P1		PORTMOTOR, SERVOPIN		; set PORTMOTOR to 1
	OUTLDS	OCR2, sMOTORHIGH		; set OCR2 to sMOTORHIGH
	rjmp final

final:
	POP2 w, _w						; restore context
	out SREG, _sreg					
	reti


; --- openWindow ---
; changes the duration of the HIGH and LOW period of the signal sent to the motor (to open the window)
; mod w (from STSI), sMOTORHIGH, sMOTORLOW
; out sMOTORHIGH, sMOTORLOW
; ---
openWindow:
	STSI 	sMOTORHIGH, 3   
	STSI	sMOTORLOW, 76   
	ret

; --- closeWindow ---
; changes the duration of the HIGH and LOW period of the signal sent to the motor (to close the window)
; mod w (from STSI), sMOTORHIGH, sMOTORLOW
; out sMOTORHIGH, sMOTORLOW
; ---
closeWindow:
	STSI 	sMOTORHIGH, 7   
	STSI	sMOTORLOW, 72
	ret



