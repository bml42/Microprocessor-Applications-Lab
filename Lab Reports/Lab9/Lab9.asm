;Benjamin Linam lab 9	
;must measure from 100hz to 10khz, 0064->2710
REGBAS	EQU	$1000	;base address of I/O register block
TCTL2	EQU	$21	;offset of TCTL3 from REGBAS
TMSK1	EQU	$22	;offset of TMSK1 from REGBAS
TFLG1	EQU	$23	;offset of TFLG1 from REGBAS
TCNT	EQU	$0E	;offset of TCNT from REGBAS
TIC1	EQU	$10	;offset of TIC1 from REGBAS
IC1rise	EQU	$10	;value to select the rising edge of IC1 to capture
IC1I	EQU	$04	;mask to select the IC1I bit of the TMSK1 register
IC1FM	EQU	$FB	;mask to clear IC1F flag using the BCLR instruction

.OUTA	EQU	$FFB8
.OUTCRL	EQU	$FFC4
.OUTSTO	EQU	$FFCA
.OUTSTR	EQU	$FFC7
	
		ORG	$00
edge_cnt	RMB	1	;edge count
EDGE1		RMB	2	;captured first edge value
period		RMB	2	;period in number of E clock cycles
TEMP1		RMB	2
FREQH		RMB	2
DBUFR		RMB	8

	ORG 	$E8
	JMP	IC1_ISR
	
	ORG	$B600
	LDS	#$01FF		;init stack
	LDX	#REGBAS
	CLRA	
	STAA	EDGE1
	STAA	EDGE1+1
	JSR	IC1_init
	
LOOP	LDAA	#2		;initialize edge_cnt to 2
	STAA	edge_cnt	;
	CLI			;enable interrupts to 68HC11

	LDAB	#10		;wait for 1 second
outer	LDY	#20000		
inner	NOP
	NOP
	DEY
	BNE	inner
	DECB
	BNE	outer
	
WAIT	TST	edge_cnt	;checks if two edges have been captured
	BNE	WAIT
	SEI			;disables interrupts
	CLR	period
	LDX	#REGBAS	
	LDD	TIC1,X		;get the second edge time
	SUBD	EDGE1		;take the difference of edge1 and edge2
	STD	period
	
	LDX	period

	LDD	#32		;X-period D-32
	FDIV			;D/X -> X R->D
	STX	TEMP1

	LDD	TEMP1
	LSRD
	LSRD
	LSRD
	CLR	FREQH
	STAA	FREQH+1
	LSRD
	LSRD
	STD	TEMP1
	XGDX
	SUBD	TEMP1	
	XGDX
	LSRD
	STD	TEMP1
	ADDA	FREQH+1
	STAA	FREQH+1
	XGDX
	SUBD	TEMP1
	ADDD	FREQH
	STD	FREQH

	CPD	#$0064		;64(16) = 100(10) lower limit of freq
	BHS	OKP1		;skip if okay
	LDX 	#MSGER1
	JSR	.OUTSTR
	BRA	JTOP		;else display too small

OKP1	CPD	#$2710		;2710(16) = 10K(10) upper limit of freq
	BLS	OKP2		;skip if okay
	LDX	#MSGER2
	JSR	.OUTSTR
	BRA	JTOP		;else display too large

OKP2	JSR	.OUTCRL
	LDX	#FREQH
	JSR	HTOD
	JSR	P5DEC
	LDX	#MSGHZ
	JSR	.OUTSTO
JTOP	JMP	LOOP

IC1_init	LDX	#REGBAS
		LDAA	#IC1rise	;prepare to capture the rising edge of IC1
		STAA	TCTL2,X		;	"
		BCLR	TFLG1,X IC1FM	;clear the IC1F flag of the TFLG1 register
		LDAA	#2
		STAA	edge_cnt
		BSET	TMSK1,X IC1I	;set the IC1 interrupt bit
		RTS
	

IC1_ISR	LDX	#REGBAS
	BCLR	TFLG1,X IC1FM	;clear the IC1F flag
	DEC	edge_cnt
	BEQ	SKIP		;is this the second edge?
	LDD	TIC1,X
	STD 	EDGE1		;save the arrival time of the first edge
SKIP	RTI

P5DEC	PSHX
	PSHB
	PSHA
	LDX	#DBUFR
	LDAA	#$30
	CMPA	0,X
	BNE	P10K
	BSR	SKP1
	CMPA	0,X
	BNE	P1K
	BSR	SKP1
	BSR	SKP1
	DEX
	CMPA	0,X
	BNE	P100
	BSR	SKP1
	CMPA	0,X
	BNE	P10
	BSR	SKP1
	BRA	P1
P10K	LDAA	0,X
	JSR	.OUTA
	INX
P1K	LDAA	0,X
	JSR	.OUTA	
	LDAA	#','
	JSR	.OUTA
	INX
P100	LDAA	0,X
	JSR	.OUTA
	INX
P10	LDAA	0,X
	JSR	.OUTA
	INX
P1	LDAA	0,X
	JSR	.OUTA
	PULA
	PULB
	PULX
	RTS

SKP1	PSHA
	INX
	LDAA	#$20
	JSR	.OUTA
	PULA
	RTS

HTOD	PSHX
	PSHB
	PSHA
	LDD	0,X
	LDX	#10000
	IDIV
	XGDX
	ADDB	#$30
	STAB	DBUFR
	XGDX
	LDX	#1000
	IDIV	
	XGDX
	ADDB	#$30
	STAB	DBUFR+1
	XGDX
	LDX	#100
	IDIV
	XGDX
	ADDB	#$30
	STAB	DBUFR+2
	XGDX
	LDX	#10
	IDIV
	ADDB	#$30
	STAB	DBUFR+4
	XGDX
	ADDB	#$30
	STAB	DBUFR+3
	PULA	
	PULB
	PULX
	RTS
	
MSGER1	FCC	"Freq. is below 100Hz"
	FCB	$04
MSGER2	FCC	"Freq. is above 10kHz"
	FCB	$04
MSGHZ	FCC	" Hz"
	FCB	$04

	
