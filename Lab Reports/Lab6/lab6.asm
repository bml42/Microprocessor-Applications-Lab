HPRIO	EQU	$103C
MASK	EQU	$F5

	ORG	$0200
M	RMB	1	;Reserve 1 byte for M at beginning of external RAM
N	RMB	1	;Reserve 1 byte for N at next memory location
SUM	RMB	1	;Reserve 1 byte for SUM at next memory location

	ORG	$B600	
	LDAA	#MASK	;Change HPRIO for internal read visibility
	STAA	HPRIO
	LDAA	#5	;initialize M to 5
	STAA	M
	LDAA 	#4	;initialize N to 4
	STAA	N
LOOP	LDAA	M	;load M into [A]
	LDAB	N	;load N into [B]
	ABA		;[A] = [A] + [B]
	STAA	SUM	;store SUM
	BRA	LOOP	;Loop forever
	SWI