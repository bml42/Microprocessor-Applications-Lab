N	equ	10

	org	$00
negCnt	rmb	1			;1 byte saved for negative count	
posCnt	rmb	1			;1 byte saved for positive count
evenCnt	rmb	1			;1 byte saved for even count
oddCnt	rmb	1			;1 byte saved for odd count

	org	$100
array	fcb	$80,$A4,$F6,$90,$E8,$C2,$74,$53,$11,$67 ;array of 1 byte numbers to be evaluated

	org	$B600
	ldab	#$00			;[b] must start as 0
	stab	negCnt			;each of these values must also be init to 0
	stab	posCnt
	stab	evenCnt
	stab	oddCnt

loop	ldx	#array			;start at beginning of array

	abx				;move to array + [b] : [b] will be counter variable			
					;X stores mem(array) 
	brset	0,X %10000000 isNeg	;tests for neg
	brclr	0,X %10000000 isPos	;tests for pos
eve	brclr	0,X %00000001 isEve	;tests for even
	brset	0,X %00000001 isOdd	;tests for odd
	bra	done			;move to end of current loop, should never reach this command, but is here as safegaurd

isNeg	inc	negCnt			;negative value located, negCnt+=1, cannot also be positive, move to eve/odd
	bra eve
isPos	inc	posCnt			;positive value located, posCnt+=1, move to eve/odd
	bra eve
isEve	inc	evenCnt			;even value located, eveCnt+=1, cannot also be odd, move to done
	bra done
isOdd	inc	oddCnt			;odd value located, oddCnt+=1, move to done
	bra done			;no more comparisons, move to end of current loop
	
done	incb				;[B] will increment until it reaches N (end of array)
	cmpb	#N
	bhs exit			;if [B] is higher or same as N, exit from loop	
	bra loop			;move to next element in array

exit	swi				;end of code
	

		