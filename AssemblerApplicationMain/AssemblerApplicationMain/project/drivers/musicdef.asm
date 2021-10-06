; file:	musicdef.asm   
; target: ATmega128L-4MHz-STK300
; description: music definitions
; authors: Vincent Gherold & Alain Schöbi



; === macros ===

; --- PLAYPARTITION ---
; loads a specific music partition and starts music
; in partitionAdress @0
; mod sMUSIC, w (from startBpm)
; out plays music
; ---
.macro PLAYPARTITION
	lds w, ETIMSK			; if (no music playing (OCEI3A == 0)) -> startMusic
	sbrc w, OCIE3A
	rjmp endPlayPartitionMacro

playMusic:
	SETsMUSIC @0
	rcall startBpm

endPlayPartitionMacro:
.endmacro


; --- SETsMUSIC ---
; loads a specific music partition
; in partitionAdress @0
; mod sMUSIC
; out sMUSIC
; ---
.macro SETsMUSIC
	ldi w, high(@0*2)
	sts sMUSIC+1, w

	ldi w, low(@0*2)
	sts sMUSIC, w
.endmacro




; === constants ===

; === frequencies ===
; octave 2
.equ freqC  = 15905
.equ freqCs = 15012
.equ freqD  = 14169
.equ freqDs = 13374
.equ freqE  = 12624
.equ freqF  = 11915
.equ freqFs = 11246
.equ freqG  = 10615
.equ freqGs = 10019
.equ freqA  = 9457
.equ freqAs = 8926
.equ freqB  = 8425



.cseg ; programm memory (optionnal)
	frequencies: .dw 0, freqFs/1, freqG/1, freqGs/1, freqA/1, freqAs/1, freqB/1, freqC/2, freqCs/2, freqD/2, freqDs/2, freqE/2, freqF/2, freqFs/2, freqG/2, freqGs/2, freqA/2, freqAs/2, freqB/2, freqC/4, freqCs/4, freqD/4, freqDs/4, freqE/4, freqF/4, freqFs/4, freqG/4, freqGs/4, freqA/4, freqAs/4, freqB/4, freqC/8



; === notes ===
.equ nRest = 0
.equ nFs3 = 1 
.equ nG3 = 2 
.equ nGs3 = 3 
.equ nA3 = 4 
.equ nAs3 = 5 
.equ nB3 = 6 
.equ nC4 = 7 
.equ nCs4 = 8 
.equ nD4 = 9 
.equ nDs4 = 10 
.equ nE4 = 11 
.equ nF4 = 12 
.equ nFs4 = 13 
.equ nG4 = 14 
.equ nGs4 = 15 
.equ nA4 = 16 
.equ nAs4 = 17 
.equ nB4 = 18 
.equ nC5 = 19 
.equ nCs5 = 20 
.equ nD5 = 21 
.equ nDs5 = 22 
.equ nE5 = 23 
.equ nF5 = 24 
.equ nFs5 = 25 
.equ nG5 = 26 
.equ nGs5 = 27 
.equ nA5 = 28 
.equ nAs5 = 29 
.equ nB5 = 30 
.equ nC6 = 31 



; === length ===
.equ LMul = 32

.equ Noire        = 1 * LMul ;       -> 0010 0000 = 0x20 (no transform)
.equ Blanche      = 2 * LMul ;       -> 0100 0000 = 0x40 (no transform)
.equ BlancheP     = 3 * LMul ;       -> 0110 0000 = 0x60 (no transform)
.equ Ronde        = 4 * LMul ;       -> 1000 0000 = 0x80 (no transform)
.equ RondeP       = 6 * LMul ;       -> 1100 0000 = 0xc0 (no transform)

.equ DoubleCroche = 5 * LMul ;       -> 0000 1000 = 0x08 (transform)
.equ Croche		  = 7 * LMul ;       -> 0001 0000 = 0x10 (transform)

; 0 * LMul is not used, otherwise a nRest of this duration would be interpreted as the end of the partiion



; === partition ===
.cseg ; programm memory (optionnal)
	harryPotter: .db nB3+Noire, nE4+Noire, nE4+Croche, nG4+Croche, nFs4+Noire, nE4+Blanche, nB4+Noire, nA4+BlancheP, nFs4+BlancheP, nE4+Noire, nE4+Croche, nG4+Croche, nFs4+Noire, nDs4+Blanche, nF4+Noire, nB3+BlancheP, 0, 0

.cseg ; programm memory (optionnal)
	starWars: .db nC4+BlancheP, nG4+BlancheP, nF4+Croche, nE4+Croche, nD4+Croche, nC5+BlancheP, nG4+Noire, nG4+Croche, nF4+Croche, nE4+Croche, nD4+Croche, nC5+BlancheP, nG4+Noire, nG4+Croche, nF4+Croche, nE4+Croche, nF4+Croche, nD4+BlancheP, nRest+Noire, nRest+Croche, 0, 0

.cseg ; programm memory (optionnal)
	dring: .db nA4+Ronde, 0 
