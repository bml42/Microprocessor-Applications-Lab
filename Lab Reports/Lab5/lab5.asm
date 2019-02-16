N	EQU	4		;Number of matrix rows
M	EQU	5		;Number of matrix columns
OUTA	EQU	$FFB8		;Address of OUTA Buffalo subroutine
OUTSTRG	EQU	$FFC7		;Address of OUTSTRG Buffalo subroutine
OUTLHLF	EQU	$FFB2		;Address of OUTLHLF Buffalo subroutine				
OUTRHLF	EQU	$FFB5		;Address of OUTRHLF Buffalo subroutine
OUTCRLF	EQU	$FFC4		;Address of OUTCRLF Buffalo subroutine

	ORG	$0100
Matrix	FCB	01,02,03,04,05	;Memory allocation for matrix elements
	FCB	06,07,08,09,10	
	FCB	11,12,13,14,15
	FCB	16,17,18,19,20

i       RMB     1               ;Memory allocation for variables
j       RMB     1
TEMP1   RMB     1
TEMP2   RMB     1
TEMP3   RMB     1
TEMP4   RMB     1

	ORG	$B600		;Save code in EEPROM
**** Start of Main Program ****
Main	LDS	#$01FF		;Initialize SP
	
	LDX	#MSG1		;Load X with base address of MSG1
	JSR	OUTSTRG		;Call subroutine to print MSG1
	LDX	Matrix		;Load address starting addr of Matrix to X
	
	BSR 	PRINTMAT	;Call subroutine to print original matrix
	
	BSR 	SWAPMAT		;Call subroutine to swap matrix columns
	
	LDX 	#MSG2		;Load X with base address of MSG2
	JSR	OUTSTRG		;Call subroutine to print MSG2
	
	BSR	PRINTMAT	;Call subroutine to print modified matrix
	SWI			;return to Buffalo monitor

**** Code for Subroutines ****
PRINTMAT        LDAA    #1      ;A points to the first element
                STAA    i       ;Store i in accumulator [A]
                CLR     j       ;Clear value stored in j
                LDAB    #M	;stores accumulator [B] with M dimension
                LDX     #Matrix ;Load [X] with address of Matrix
                JSR     OUTCRLF ;outputs ASCII carriage and outputs the characters
Loop            LDAA    0,X	
                JSR     OUTLHLF ;converts left nibble of A to ascii
                LDAA    0,X
                JSR     OUTRHLF ;converts right nibble of A to ascii
                LDAA    #$20
                JSR     OUTA    ;outputs space between 
                LDAB    i       ;Load accumulator [B] with i
                CMPB    #M
                BEQ     NEXTEL

                BRA     NEXTROW ;Branch
NEXTEL          CLR     i       ;Clear value stored in i
                INC     j       ;Increment j
                JSR     OUTCRLF
NEXTROW         LDAB    j       ;load accumulator [B] with j
                CMPB    #N      ;Compare [B] with N dimension
                BEQ     LEAVE   ;Last row output to console, return from subroutine
                INC     i       ;increment i
                INX            	;increment [X] to point to next element
                BRA     Loop    ;Branch back to the loop
LEAVE           RTS             ;Return to subroutine

SWAPMAT         LDAA    #0      ;Load accumulator [A] with 0
                STAA    i       ;Store [A] to i
                STAA    j	;Store [A] to j
                STAA    TEMP1
                STAA    TEMP3
                LDAA    #M      ;Load accumulator [A] with M
                STAA    TEMP2
                LDAA    #N-1
                STAA    TEMP4
                LDAA    i
                LDAB    #M      ;Load accumulator [B] with M
                MUL             ;Multiply i and M
                ADCA    #0
                ADDD    #MATRIX ;Add accumulator D with MATRIX
                XGDX            ;Exchange [D] with [X]
LOOP2           LDAA    TEMP4   
                LDAB    TEMP2   
                MUL             ;Multiply TEMP4 and TEMP2
                ADCA    #0
                ADDD    #MATRIX
                XGDY            ;Exchange [D] with [Y]
LOOP1           LDAA    0,X
                LDAB    0,Y
                STAA    0,Y
                STAB    0,X
                INX             ;Increment X
                INY             ;Increment Y
                INC     TEMP1   ;Increment TEMP1
                LDAA    TEMP1
                CMPA    #M      ;Compare accumulator [A] with M
                BNE     LOOP1
                CLR     TEMP1    ;Clear TEMP1
                INC     TEMP3    ;Increment TEMP3
                DEC     TEMP4    ;Decrement TEMP4
                LDAA    TEMP4   
                CMPA    TEMP3    ;Compare TEMP4 and TEMP3
                BGE     LOOP2   ;Branch if greater or equal

                RTS             ;Return to subroutine

**** Message Definitions ****
MSG1	FCC	"The original matrix is as follows:"
	FCB	$04
MSG2	FCC	"The modified matrix is as follows:"
	FCB	$04
	