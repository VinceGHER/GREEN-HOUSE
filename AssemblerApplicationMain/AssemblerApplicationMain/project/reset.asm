; file:	reset.asm   
; target: ATmega128L-4MHz-STK300
; description: reset code
; authors: Vincent Gherold & Alain Schöbi

reset:
	; === global initialisation ===
	LDSP RAMEND                     ; initialize stack pointer	
	cli								; clear global interrupt
	OUTI TIMSK, 0x00                ; desactivate all timers
	
	; === drivers initialisation ===
	rcall initReadTemperatureTimer
	rcall initMusic
	rcall initEncoder
	rcall initMotor

	; === libraries initialisation ===
	rcall LCD_init
	rcall wire1_init

	; === other initialisation ===
	ldi w, 0
	sts sTemperatureWasInRange, w	; clear sTemperatureWasInRange
	
	rcall loadingLCDTemperature		; displays loading...

	rcall aquireTemp				; first aquiring temperature
	WAIT_MS 1000
	rcall readTemp					; first reading temperatue
	rcall updateLCDTemperature		; displays temperature
	rcall updateLCDEncoder			; displays encoder

	sei								; set global interrupt
	jmp main			