; file:	main.asm   
; target: ATmega128L-4MHz-STK300
; description: main file of the project
; authors: Vincent Gherold & Alain Schöbi


; === macros and definitions ===
.include "libraries/macros.asm"
.include "libraries/definitions.asm"

; === interruption ===
.include "interruption.asm"

; === libraries ===
.include "libraries/lcd.asm"
.include "libraries/printf.asm"
.include "libraries/wire1.asm"

; === subroutines and code ===
.include "manager.asm"
.include "drivers/encoder.asm"
.include "drivers/temperature.asm"
.include "drivers/musicdef.asm"	; first include macros which are used in music.asm
.include "drivers/music.asm"
.include "drivers/motor.asm"

; === reset ===
.include "reset.asm"


; === constants ===
.set TEMPERATUREINTERVAL = 2 ; seconds [2, 255], actualization interval of the temperature sensor

.set AQUIRETEMPERATUREREQUESTINTERVAL = TEMPERATUREINTERVAL -1 ; seconds
.set READTEMPERATUREREQUESTINTERVAL = AQUIRETEMPERATUREREQUESTINTERVAL + 1 ; seconds

.set TEMPERATUREINTERVAL    = 0.5*4*4	; ±0.5°C for the window control (avoid openging/closing too often)
.set TEMPERATUREBIGINTERVAL = 1*4*4		; ±1°C   for the big range (with the music alert, sTemperatureWasInRange)

.dseg
	sTemperatureWasInRange: .byte 1		; equals 1 if the temperature was in range, equals 0 otherwise
.cseg


; === main ===
main:		
	WAIT_MS 1							; (faster than the timer1 interruption)

	call encoder						; call encoder (value into rENCOD)
	brtc noEncoderChange

enncoderChange:
	ldi w, 0
	sts sTemperatureWasInRange, w		; clear sTemperatureWasInRange, as the encoder value has changed
	call updateLCDEncoder				; displays the new encoder value (consign temperature)

noEncoderChange:
	lds w, sReadTemperatureRequest
	cpi w, AQUIRETEMPERATUREREQUESTINTERVAL
	brne checkReadTemperatureRequest	; if (sReadTemperatureRequest == AQUIRETEMPERATUREREQUESTINTERVAL) -> call aquireTemp

aquireTemperatureRequest:
	call aquireTemp						; (modifies w, a0, SREG)
	rjmp main

checkReadTemperatureRequest:	
	lds w, sReadTemperatureRequest
	cpi w, READTEMPERATUREREQUESTINTERVAL
	brne main							; if (sReadTemperatureRequest == READTEMPERATUREREQUESTINTERVAL) -> call readTemp

readTemperatureRequest:
	ldi w, 0							; reset sReadTemperatureRequest
	sts sReadTemperatureRequest, w

	call readTemp						; (modifies w, a0, SREG)
	call updateLCDTemperature			; (modifies u, w, SREG)

	lds a0, sTEMPl						; loads sTemph:sTempl in a1:a0
	lds a1, sTEMPh

	mov b0, rENCOD						; loads rENCOD in b0, the consign temperature
	ldi b1, 0

	LSL2 b1, b0							; logical shift left by 2, for the temperature sensor format
	LSL2 b1, b0

checkOpenWindow:						; if (actual temperature > consign temperature + TEMPERATUREINTERVAL) 
	MOV2 b3, b2, b1, b0
	ADDI2 b3, b2, TEMPERATUREINTERVAL
	CP2 a1, a0, b3, b2					
	brlt checkCloseWindow				; if (a - b < 0)  -> jump
	breq checkCloseWindow				; if (a - b == 0) -> jump
	call openWindow						
	rjmp temperatureWasNotInRange

checkCloseWindow:						; if (actual temperature < consign temperature - TEMPERATUREINTERVAL) 
	MOV2 b3, b2, b1, b0
	ADDI2 b3, b2, -TEMPERATUREINTERVAL	
	CP2 a1, a0, b3, b2

	brge temperatureWasInRange			; if (a - b > 0)  -> jump
	call closeWindow
	rjmp temperatureWasNotInRange

temperatureWasInRange:
	ldi w, 1
	sts sTemperatureWasInRange, w	    ; sets sTemperatureWasInRange to 1, as the temperature was in range
	jmp main

temperatureWasNotInRange:
	lds w, sTemperatureWasInRange
	tst w								; tests if temperature was in range before
	brne checkBigRange					; if (temperatureWasInRange != 0) -> checkBigRange
	jmp main


checkBigRange:
checkBigRangeHigh:						; if (actual temperature > consign temperature + TEMPERATUREBIGINTERVAL) 
	MOV2 b3, b2, b1, b0				 
	ADDI2 b3, b2, TEMPERATUREBIGINTERVAL
	CP2 a1, a0, b3, b2				
	brlt checkBigRangeLow				; if (a - b < 0)  -> jump
	breq checkBigRangeLow				; if (a - b == 0) -> jump
	PLAYPARTITION starWars
	ldi w, 0							; reset sReadTemperatureRequest
	sts sTemperatureWasInRange, w
	jmp main
	
checkBigRangeLow:						; if (actual temperature < consign temperature - TEMPERATUREBIGINTERVAL) 
	MOV2 b3, b2, b1, b0				
	ADDI2 b3, b2, -TEMPERATUREBIGINTERVAL
	CP2 a1, a0, b3, b2
	brge noTemperatureUpdate			; if (a - b >= 0) -> jump
	PLAYPARTITION harryPotter
	ldi w, 0							; reset sReadTemperatureRequest
	sts sTemperatureWasInRange, w
	jmp main

noTemperatureUpdate:
	jmp main