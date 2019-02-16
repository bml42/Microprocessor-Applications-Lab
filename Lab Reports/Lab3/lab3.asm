	org	$00	;data allocation begin
M	rmb	3	;allocate 3 bytes for multiplicand
N	rmb	1	;allocate 1 byte for muliplier
P	rmb	4	;allocate 4 bytes for final product
P1	rmb	2	;allocate 2 bytes for product1
P2	rmb 	2	;allocate 2 bytes for product2
P3	rmb	2	;allocate 2 bytes for product3

	org	$0100	;code data begin
	ldaa	M + 2	;read multiplicand LSB to [A]
	ldab	N	;read multiplier to [B]
	mul		;mulitiply [A] * [B]
	stab	P + 3	;store [B] in product LSB
	staa	P1	;store [A] to P1 MSB
	ldaa	M + 1	;read mulitplicand MID to [A]
	ldab	N	;read multiplier to [B]
	mul		;multiply [A] * [B]
	std	P2	;store [D] to P2
	ldaa	M	;read multiplicand MSB to [A]
	ldab	N	;read multiplier to [B]
	mul		;multiply [A] * [B]
	std	P3	;store [D] to P3
	ldaa	P1	;read P1 MSB to [A]
	adda	P2 + 1	;add P2 LSB
	staa	P + 2	;store sum to product MID-L
	ldaa	P2	;read P2 MSB to [A]
	adca	P3 + 1	;add with carry P3 LSB
	staa	P + 1	;store sum to product MID-H
	ldaa 	P3	;read P3 MSB to [A]
	adca	#$00	;add with carry, zero
	staa	P	;store sum to product MSB
	swi		;exit program