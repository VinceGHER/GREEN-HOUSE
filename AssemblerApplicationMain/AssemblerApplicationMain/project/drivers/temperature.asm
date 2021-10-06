; file:	temperature.asm   
; target: ATmega128L-4MHz-STK300
; description: Dallas 1-wire(R) temperature sensor interfacing, Module M5
; authors: Vincent Gherold & Alain Schöbi


; === SRAM bytes ===
.dseg
		sTEMPh: .byte 1
		sTEMPl: .byte 1
.cseg


; === subroutines ===
; --- aquireTemp ---
; aquire temperature 
; mod a0, w, SREG
; out sTEMPh, sTEMPl
; ---
aquireTemp:
	rcall	wire1_reset				; send a reset pulse
	CA	wire1_write, skipROM		; skip ROM identification
	CA	wire1_write, convertT		; initiate temp conversion

	ret


; --- readTemp ---
; read temperature 
; mod a0, w, SREG
; out sTEMPh, sTEMPl
; ---
readTemp:
	rcall	wire1_reset				; send a reset pulse
	CA	wire1_write, skipROM
	CA	wire1_write, readScratchpad	
	rcall	wire1_read				; read temperature LSB
	sts	sTEMPl, a0
	rcall	wire1_read				; read temperature MSB
	sts	sTEMPh, a0

	ret
