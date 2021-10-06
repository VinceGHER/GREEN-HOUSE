; file:	encoder.asm
; target: ATmega128L-4MHz-STK300
; description: encoder library, controls the angular position 
;              and sets the flag T if there was a change
; authors: Vincent Gherold & Alain Schöbi



; === definitions ===
; .equ	ENCOD_A	= 4	; angular encoder A
; .equ	ENCOD_B	= 5	; angular encoder B
; .equ	ENCOD_I	= 6	; angular encoder button 
.equ	PORTENCOD	 = PORTE
.equ	MASKENCOD    = (1<<ENCOD_A) + (1<<ENCOD_B) + (1<<ENCOD_I)
.def	rENCOD	     = r21	  ; r21 = a3
.equ	rENCODAddr	 = 21	  ; r21 = a3
.equ	ENCODMIN     = 15*4   ; minimum value of the encoder, [1;254]
.equ	ENCODMAX     = 30*4   ; maximum value of the encoder, [1;254] & >= ENCODMIN
.equ	ENCODDEFAULT = 20*4   ; default value of the encoder, ENCODMIN <=  ENCODDEFAULT <= ENCODMAX

; === SRAM bytes ===
.dseg
	sENCOLD:	.byte	1  ; 1 byte in the SRAM at adress sENCOLD
.cseg




; === subroutines ===

; --- initEncoder ---
; initializes the encoder
; mod w, rENCOD
; ---
initEncoder:
	in	 w, PORTENCOD-1		    ; define PORTENCOD as an input (DDR of the port)
	andi w, ~MASKENCOD
	out	 PORTENCOD-1, w

	in	w, PORTENCOD		    ; enable the internal pull-ups, avoids having to branch extern resistors
	ori	w, MASKENCOD
	out	PORTENCOD, w

	ldi rENCOD, ENCODDEFAULT   	; set rENCOD to the default value

	ret



; --- encoder ---
; checks the encoder status and actualizes rENCOD and the flag T
; mod w, u, flag T, sENCOLD
; out rENCOD
; ---
encoder:
	
	clt						; clear flag T
	in	  w, PORTENCOD-2	; read encoder port (w=new)
	andi  w, MASKENCOD		; mask encoder lines (A,B,I)
	lds	  u, sENCOLD		; load previous value (u=encd_old)

	cp	  w, u			    ; new - old = w - u
	brne  PC+2				; if (w != u) -> jump to PC+2
	ret						; return (as nothing as changed)

	sts	 sENCOLD, w		    ; store encoder value for next time
	eor	 u, w				; exclusive or detects transitions, 
							; u = "transitions"
							; w = "new state"

	sbrs	u, ENCOD_A		; if (bit ENCOD_A of u == 1) -> PC = PC + 2	
	ret						; return (no transition on A)	

aTransition:
	set						; set flag T
	sbrc	w, ENCOD_A	    ; if A rises/falls
	rjmp	aRise
aFall:
	sbrs w, ENCOD_B
	rjmp rENCODDec
	rjmp rENCODInc

aRise:
	sbrc w, ENCOD_B
	rjmp rENCODDec


rENCODInc:
	inc	 rENCOD				; rENCOD++
checkMax:
	cpi  rENCOD, ENCODMAX+1
	brcs PC+2				; if ( rENCOD < rENCODMAX+1 ) -> return
reachedMax:
	ldi  rENCOD, ENCODMAX	; set rENCOD to the maximum value
	ret


rENCODDec:
	dec rENCOD				; rENCOD--
checkMin:
	cpi  rENCOD, ENCODMIN
	brcc PC+2				; if ( rENCOD >= rENCODMIN ) -> return
reachedMin:
	ldi  rENCOD, ENCODMIN	; set rENCOD to the minimum value
	ret