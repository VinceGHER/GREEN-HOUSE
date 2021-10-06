; file:	manager.asm   
; target: ATmega128L-4MHz-STK300
; description: manager file of the project, 
;			   contains subroutines to control the LCD, the initliasation of timers...
; authors: Vincent Gherold & Alain Schöbi




; === SRAM bytes ===
.dseg
	sReadTemperatureRequest:	.byte	1  ; 1 byte in the SRAM at adress sACTIVITYTIME
.cseg

.set TIMER1COMPARE = 256 * 16


; === subroutines ===
; --- initReadTemperatureTimer ---
; initiliazes timer1
; mod w 
; ---
initReadTemperatureTimer:
	OUTI TCCR1B, (1<<CTC10) + 5				  ; set CTC10 for clear on output compare
	OUTI OCR1AH, high(TIMER1COMPARE)		  ; define OCR1AH 
	OUTI OCR1AL, low(TIMER1COMPARE)			  ; define OCR1AL 

	in w, TIMSK
	ori w, (1<<OCIE1A)						  ; set OCIE1A for output compare mode
	out TIMSK, w	
ret


; --- iTimer1TemperatureRequest ---
; interruption of timer1, increments sReadTemperatureRequest
; ---
iTimer1TemperatureRequest:
	push w
	INCS sReadTemperatureRequest			  ; (only modifies w, SREG = CST)
	pop w
	reti


; --- loadingLCDTemperature ---
; displays loading on the first line of the LCD
; mod a0, b0, b1, w, u, e0, e1, SREG
; out LCD
; ---
loadingLCDTemperature:
	ldi a0, 0x00                              ; start writing at the first line of the LCD
	rcall LCD_pos
	PRINTF LCD
	.db "loading...", 0, 0 ;
	ret


; --- updateLCDTemperature ---
; displays sTEMP on the first line of the LCD
; in sTEMPl, sTEMPh
; mod a0, b0, b1, w, u, e0, e1, SREG
; out LCD
; ---
updateLCDTemperature:
	lds b1, sTEMPh
	lds b0, sTEMPl
	ldi a0, 0x00                               ; start writing at the first line of the LCD
	call LCD_pos
	PRINTF LCD
	.db "Actuelle: ", FFRAC2, b, 4, $22, " ", 0, 0
	ret
	

; --- updateLCDEncoder ---
; displays rENCOD on the second line of the LCD
; in rENCOD, parameterIn2, parameterIn3
; mod a0, w, u, e0, e1, SREG
; out LCD
; ---
updateLCDEncoder:
	ldi a0, 0x40							    ; start writing at the second line of the LCD
	call LCD_pos
	PRINTF LCD
	.db  LF, "Consigne: ", FFRAC, rENCODAddr, 2, $22, " ", 0, 0
	ret





	