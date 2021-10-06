; file:	music.asm   
; target: ATmega128L-4MHz-STK300
; description: generates music on the buzzer connected on PORTBUZZER
;			   uses timer0 for the bpm and timer3 for the frequencies
; authors: Vincent Gherold & Alain Schöbi
	


; === definitions ===
.equ PORTBUZZER = PORTE


; === SRAM bytes ===
.dseg
	sMUSIC:	.byte	2  ; 1 word (16 bits) in the SRAM at adress sMUSICh
.cseg


; === subroutines ===
; --- initBeep ---
; initliazes the music, the buzzer, and the timer0
; mod w, timer0, sMUSIC
; ---	
initMusic:
	sbi	PORTBUZZER-1, SPEAKER	; defines SPEAKER as an output (DDR of the port)
	OUTI ASSR, (1<<AS0)         ; chose TOSC (32768 Hz) for TIMER0
	OUTI TCCR0, (1<<CTC0) + 6	; prescaler:  CS0 = 6, prescaler = 256, freq = 32768/256 = 128Hz	
	SETsMUSIC 0					; initialize sMUSIC to 0
	ret
	


; --- startBpm ---
; starts the bpm (timer3) and thus starts the music
; mod w
; out timer0, timer3
; ---
startBpm:

	OUTI OCR0, 0x01							  ; (modifies w) to directly call iBpm

	OUTI TCNT0, 0							  ; clears the TCNT of the timer0 and timer3
	OUTEI TCNT3H, 0
	OUTEI TCNT3L, 0

	OUTEI TCCR3B, (1<<CTC30) + (0<<CS30)      ; desactivate timer3 until the first call of iBpm

	in w, TIMSK
	ori w, (1<<OCIE0)						  ; set OCIE0 for output compare mode
	out TIMSK, w	
	
	lds w, ETIMSK							  ; set OCIE3A for output compare mode
	ori w, (1<<OCIE3A)
	sts ETIMSK, w        

	ret


; --- stopBpm ---
; stops the bpm (timer3) and thus stops the music
; mod w
; out timer0, timer3
; ---
stopBpm: 
	in w, TIMSK				    ; stops bpm timer (timer0)
	andi w, ~(1<<OCIE0)					
	out TIMSK, w

	lds w, ETIMSK				; stops frequency timer (timer3)
	andi w, ~(1<<OCIE3A)
	sts ETIMSK, w

	ret


; --- iFrequency ---
; output compare interruption of timer3, inverses the speaker voltage 
; ---	
iFrequency:
	INVP PORTBUZZER, SPEAKER   ; inverse speaker voltage (SREG = CST)
	reti
	



; --- iBpm ---
; compare overflow of timer3, loads next note
; in  sMUSIC
; mod sMUSIC, timer0, timer3, _sreg
; out sMUSIC, timer0, timer3
; ---	
iBpm:
	in _sreg, SREG			            ; save context
	push r0
	push w
	PUSHZ								; (SREG = CST)

	LDSZ sMUSIC 						; load pointer z with the adress of sMUSIC (SREG = CST)
							
	lpm						            ; load programm memory into r0
	tst	r0					            ; test for zero or minus
	breq endOfPartition		            ; if (r0 == 0) -> endOfPartition

	adiw z, 1							; increment pointer z
	STSZ sMUSIC							; store the value of z at the sMUSIC

	mov w, r0				            ; move r0
	andi w, 0b11100000		            ; take the 3 MSB, which stand for the note's length

	; musicdef.asm note length transform rules	
	cpi w, 7*LMul						; Croche				
	brne PC+2
	ldi w, 0x10 
	cpi w, 5*LMul						; DoubleCroche
	brne PC+2
	ldi w, 0x08 

	out OCR0, w				            ; set the note length (timer0)

	mov w, r0 				            ; move r0
	andi w, 0b00011111		            ; take the 5 LSB, which stand for the note's pitch
	add w, w				            ; multiply by 2, for the lpm adressing standard

	LDZD 2*frequencies, w               ; (only modifies SREG)

	lpm						            ; loads programm memory into r0
	mov w, r0				            ; we now use r0:w as the frequency byte
	adiw zl, 1				            ; increments pointer z
	
	lpm						            ; loads programm memory into r0
	tst r0
	breq playRest
	tst w
	breq playRest

	sts OCR3AH, r0					    ; set the OCR3A byte according to the frequency (r0:w)
	sts OCR3AL, w

	OUTEI TCCR3B, (1<<CTC30) + (1<<CS30); activates timer3, as it was maybe playing a nRest (modifies w)

retiBpm:	
	POPZ			                    ; return form interrupt, restore context
	pop w
	pop r0
	out SREG, _sreg		
	reti

playRest:								; desactive timer3 to play a nRest
	OUTEI TCCR3B, (1<<CTC30) + (0<<CS30)
	rjmp retiBpm

endOfPartition:			                ; stops bpm timer (timer0)
	in w, TIMSK
	andi w, ~(1<<OCIE0)					
	out TIMSK, w

	lds w, ETIMSK						; stops frequency timer (timer3)
	andi w, ~(1<<OCIE3A)
	sts ETIMSK, w

	rjmp retiBpm