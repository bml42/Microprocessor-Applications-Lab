N	equ	10	; array count

	org	$00
array	fcb	3,24,15,74,4,10,13,12,9,28

	org	$b600
	ldaa	array	; set array[0] as the temporary array max
	ldab	#1	; initialize loop index to 1
loop	ldx	#array	; point X to array[0]
	abx		; compute the address of array[i]
	cmpa	0,X	; compare temp. array max to the next element
	bhs	chkend	; do we need to update the temporary array max?
	ldaa	0,X	; update the temporary array max
chkend	cmpb	#N-1	; compare loop index with the loop limit
	beq	exit	; is the whole array checked yet?
	incb		; increment loop index
	bra	loop
exit	staa	$20	; save the array max
	swi		; terminate program