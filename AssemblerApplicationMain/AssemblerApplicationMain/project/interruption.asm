; file:	interruption.asm   
; target: ATmega128L-4MHz-STK300
; description: interruption vector
; authors: Vincent Gherold & Alain Schöbi


.org 0					; Reset
	rjmp reset
.org	INT0addr		; External Interrupt Request 0
	reti
.org	INT1addr		; External Interrupt Request 1
	reti
.org	INT2addr		; External Interrupt Request 2
	reti
.org	INT3addr		; External Interrupt Request 3
	reti
.org	INT4addr		; External Interrupt Request 4
	reti
.org	INT5addr		; External Interrupt Request 5
	reti
.org	INT6addr		; External Interrupt Request 6
	reti
.org	INT7addr		; External Interrupt Request 7
	reti
.org	OC2addr			; Timer/Counter2 Compare Match
	rjmp iMotorLogic
.org	OVF2addr		; Timer/Counter2 Overflow
	reti 
.org	ICP1addr		; Timer/Counter1 Capture Event
	reti
.org	OC1Aaddr		; Timer/Counter1 Compare Match A
	jmp iTimer1TemperatureRequest
.org	OC1Baddr		; Timer/Counter Compare Match B
	reti
.org	OVF1addr		; Timer/Counter1 Overflow
	reti
.org	OC0addr			; Timer/Counter0 Compare Match
	rjmp iBpm
.org	OVF0addr		; Timer/Counter0 Overflow
	reti
.org	SPIaddr			; SPI Serial Transfer Complete
	reti
.org	URXC0addr		; USART0, Rx Complete
	reti
.org	UDRE0addr		; USART0 Data Register Empty
	reti
.org	UTXC0addr		; USART0, Tx Complete
	reti
.org	ADCCaddr		; ADC Conversion Complete
	reti
.org	ERDYaddr		; EEPROM Ready
	reti
.org	ACIaddr			; Analog Comparator
	reti
.org	OC1Caddr		; Timer/Counter1 Compare Match C
	reti
.org	ICP3addr		; Timer/Counter3 Capture Event
	reti
.org	OC3Aaddr		; Timer/Counter3 Compare Match A
	rjmp iFrequency
.org	OC3Baddr		; Timer/Counter3 Compare Match B
	reti
.org	OC3Caddr		; Timer/Counter3 Compare Match C
	reti
.org	OVF3addr		; Timer/Counter3 Overflow
	reti


.org 0x46
