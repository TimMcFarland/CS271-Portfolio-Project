TITLE Proj6_934066739     (Proj6_934066739.asm)

; Author: Tim McFarland
; Last Modified: 3/16/2021

; Description: Receives 10 different integers from a user and validates whether or not those integers
;	fit within a 32 bit register and if they are integers. If they are integers that fit,
;	then those numbers are printed to the screen, and the sum of those numbers as well as 
;	the average of those numbers is also shown. This is all done using string primitives.

; known issues - Trailing zeroes don't always show; however, they are tracked properly in numArray

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Provides prompt to user, takes input from user and displays certain prompts depending
;	on if the the information input by the user is valid or not.
;
; Preconditions: All inputs are already defined
;
; Receives:
; prompt = userPrompt, which provides direction to the user
; userInput = inputFromUser
; characterCount = SIZEOF inputFromUser
; validCheck = isValid variable
; errMessage = memory location of the string errorMessage
; inputLength = lengthOfInput variable address
;
; returns: inputLength = lengthOfInput is updated
;		   userInput = userInput is updated
; ---------------------------------------------------------------------------------
mGetString   MACRO prompt:REQ, userInput:REQ, characterCount:REQ, validCheck:REQ, errMessage:REQ, inputLength:REQ

	LOCAL	_validNum
	LOCAL	_invalidNum
	LOCAL	_endGetString
	LOCAL	_promptUser

	PUSHAD

	MOV		EAX,	validCheck
	CMP		EAX,	0
	JNZ		_promptUser
	JMP		_invalidNum

_promptUser:
	MOV		EDX,	prompt
	CALL	WriteString

_validNum:
	MOV		EDX,	userInput
	MOV		ECX,	characterCount
	CALL	ReadString

	; This assigns the value of EAX to the memory location of inputLength
	MOV		EBX,	inputLength
	MOV		[EBX],	EAX
	JMP		_endGetString

_invalidNum:
	MOV		EDX,	errMessage
	CALL	WriteString
	JMP		_validNum

_endGetString:
	POPAD

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays the following items: instructions to user, valid nums that user input,
;	and the sum and average of the input as well as a farewell message
;
; Preconditions: introduction is defined in the first use case, numArray is defined
;	in the second use case, sum is defined in the third use case, and average is 
;	defined in the fourth use case
;
; Receives:
; isItIntro		  = isIntro Boolean check
; isItArray		  = isArray Boolean check
; IsItSum		  = isSum Boolean check
; isItAvg		  = isAvg Boolean check
; printNumsHeader = printHeaderForArray Boolean check
; headerText	  = header for array, sum and average
; instructions	  = programInstructions - only called in introduction
; stringToPrint	  = stringForOutput
; fareWell		  = a farewell message to the user
;
; returns: updates isItIntro during first pass to 0 (in main)
;	updates printNumsHeader to 0 after array first value of array is printed
;	updates isItSum to 0 once sum is printed
; ---------------------------------------------------------------------------------
mDisplayString	MACRO isItIntro:REQ, isItArray:REQ, isItSum:REQ, isItAvg:REQ, printNumsHeader:REQ, headerText:REQ, instructions:REQ, stringToPrint:REQ, fareWell:REQ

	LOCAL	_endDisplayString
	LOCAL	_introduction
	LOCAL	_printArray
	LOCAL	_printHeader
	LOCAL	_printEachString
	LOCAL	_printSum
	LOCAL	_printAvg

	; preserve all registers
	PUSHAD

	; if this is an intro, display the intro header
	MOV		EBX,			isItIntro
	MOV		EAX,			[EBX]
	CMP		EAX,			1
	JE		_introduction

	; if it is an array, display header and print array
	MOV		EBX,			isItArray
	MOV		EAX,			[EBX]
	CMP		EAX,			1
	JE		_printArray

	; if it is the sum, display header and print sum
	MOV		EBX,			isItSum
	MOV		EAX,			[EBX]
	CMP		EAX,			1
	JE		_printSum

	; if it is the average, display header and print avg
	MOV		EBX,			isItAvg
	MOV		EAX,			[EBX]
	CMP		EAX,			1
	JE		_printAvg


_introduction:
	; this is to be printed if it is the first time that the array is printed
	MOV		EDX,	headerText
	CALL	WriteString
	CALL	CrLf
	MOV		EDX,	instructions
	CALL	WriteString

	; set isIntro to 0 as it will no longer be called
	MOV		EDX,	0
	MOV		[EBX],	EDX
	JMP		_endDisplayString

_printArray:
	; ---------------------------------------------------------
	; prints all the items that are in the array in string form
	;	if this is the first value, print a header
	; ---------------------------------------------------------
	MOV		EBX,	printNumsHeader
	MOV		EAX,	[EBX]
	CMP		EAX,	1
	JE		_printHeader
	JMP		_printEachString

_printHeader:
	; prints the header
	CALL	CrLf
	MOV		EDX,	headerText
	CALL	WriteString

	; make it so the nums header will no longer print
	MOV		EBX,	printNumsHeader
	MOV		EDX,	0
	MOV		[EBX],	EDX
	MOV		EAX,	0

_printEachString:
	MOV		EDX,	stringToPrint
	CALL	WriteString
	MOV		EDX,	0

	; make it so the nums header will no longer print
	MOV		EBX,	printNumsHeader
	MOV		EDX,	0
	MOV		[EBX],	EDX
	JMP		_endDisplayString

_printSum:
	; print header
	CALL	CrLf
	CALL	CrLf
	MOV		EDX,	headerText
	CALL	WriteString
	MOV		EDX,	0

	; print value
	MOV		EDX,	stringToPrint
	CALL	WriteString
	CALL	CrLf

	; make it so this branch will not be called again
	MOV		EBX,	isItSum
	MOV		EDX,	0
	MOV		[EBX],	EDX
	JMP		_endDisplayString

_printAvg:
	; print header
	CALL	CrLf
	MOV		EDX,	headerText
	CALL	WriteString
	MOV		EDX, 0

	; print value
	MOV		EDX,	stringToPrint
	CALL	WriteString
	CALL	CrLf
	
	; display farewell message
	MOV		EDX,	fareWell
	CALL	WriteString

_endDisplayString:
	POPAD
ENDM

; constants used in validation
upperValidation =	 2147483647						; this is the maximum number allowed for input
lowerValidation =	-2147482648						; this is the minimum number allowed for input 
maxInputLength	=	11
stringBuffer	=	20



.data
programHeader			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10
						BYTE		"Written by: Tim McFarland",13, 10, 0

programInstructions		BYTE		"Please provide 10 signed decimal integers.", 13, 10, 10
						BYTE		"Each number needs to fit inside a 32 bit register; range of [-2,147,482,648 to 2,147,483,647].", 13, 10, 10
						BYTE		"After you have finished inputting the raw numbers, I will display the following:", 13, 10 
						BYTE		"a list of integers, their sum, and their raw average value. -- Neat, right?", 13, 10, 0

userPrompt				BYTE		"please enter a signed number: ", 0

numsHeader				BYTE		"You entered the following numbers: ", 13, 10, 0

sumHeader				BYTE		"The sum of these numbers is: ", 0

avgHeader				BYTE		"The average of these numbers is: ", 0

inputFromUser			BYTE		stringBuffer DUP(0)

lengthOfInput			DWORD		?

stringForOutput			BYTE		stringBuffer DUP(0)

errorMessage			BYTE		"ERROR: You did not enter a signed number or your number was too big.", 13, 10
						BYTE		"Please try again: ", 0

isValid					DWORD		1

numArray				SDWORD		10 DUP(?)

; Initializing items that manage mDisplayString macro
isIntro					DWORD		1
isArray					DWORD		1
isSum					DWORD		1
isAvg					DWORD		1
printHeaderForArray		DWORD		1

sum						DWORD		?

average					DWORD		?

farewell				BYTE		13, 10, "Thanks for a great and challenging term! Have a great day!", 13, 10, 0

.code
main PROC

	; Introduction is shown
	mDisplayString OFFSET isIntro, OFFSET isArray, OFFSET isSum, OFFSET isAvg, OFFSET printHeaderForArray, OFFSET programHeader, OFFSET programInstructions, OFFSET stringForOutput, OFFSET farewell

	PUSH	lowerValidation
	PUSH	upperValidation
	PUSH	maxInputLength
	PUSH	OFFSET		lengthOfInput
	PUSH	OFFSET		errorMessage
	PUSH	isValid
	PUSH	OFFSET		numArray
	PUSH	SIZEOF		inputFromUser
	PUSH	OFFSET		inputFromUser
	PUSH	OFFSET		userPrompt
	CALL	ReadVal

	PUSH	OFFSET		farewell
	PUSH	OFFSET		average
	PUSH	stringBuffer
	PUSH	OFFSET		sum
	PUSH	OFFSET		printHeaderForArray
	PUSH	OFFSET		isAvg
	PUSH	OFFSET		isSum
	PUSH	OFFSET		isArray
	PUSH	OFFSET		isIntro
	PUSH	OFFSET		numsHeader
	PUSH	OFFSET		avgHeader
	PUSH	OFFSET		sumHeader
	PUSH	LENGTHOF	numArray
	PUSH	OFFSET		numArray
	PUSH	OFFSET		stringForOutput
	CALL	WriteVal

	MOV		EAX,	1
	Invoke ExitProcess, 0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Takes input from user and validates whether the signed input will fit within a 32
;	bit register
;
; Preconditions: variables programHeader and programInstructions are string variables
;
; Postconditions: None
;
; Receives:
; [EBP+44] = lowerValidation
; [EBP+40] = upperValidation
; [EBP+36] = maxInputLength
; [EBP+32] = lengthOfInput
; [EBP+28] = errorMessage
; [EBP+24] = isValid
; [EBP+20] = numArray
; [EBP+16] = SIZEOF inputFromUser
; [EBP+12] = inputFromUser
; [EBP+8]  = userPrompt
;
; returns: numArray is filled with signed integers that fit a 32-bit register
; ---------------------------------------------------------------------------------
ReadVal	PROC

	LOCAL	lowAscii:BYTE, highAscii:BYTE, numsFound:DWORD, hasSign:DWORD, powerOfTen: DWORD, conversionReady: BYTE, count:DWORD, singleNum:BYTE

	; defining constants
	MOV		lowAscii,	48
	MOV		highAscii,	57
	MOV		count,		0

_userInput:
	; resets these trackers at each loop
	MOV		hasSign,			0
	MOV		numsFound,			0
	MOV		conversionReady,	0
	MOV		powerOfTen,			0
	MOV		singleNum,			0
 	mGetString [EBP+8], [EBP+12], [EBP+16], [EBP+24], [EBP+28], [EBP+32]

	MOV		EAX,		1
	MOV		[EBP+24],	EAX						; reset isValid to True

_checkForLength:
	MOV		EBX,	[EBP+32]					; lengthOfInput		
	MOV		EAX,	[EBX]

	CMP		EAX,	0
	JZ		_invalidInput

	; if the string length is greather than what is allowed - it is not valid
	CMP		EAX,	[EBP+36]					; maxInputLength			 
	JA		_invalidInput
	JB		_checkForCharacters

_checkForCharacters:

	; set AL to character '0' and increment until '9'
	MOV		AL,		lowAscii					; local variable

	; prepare counter for string evaluation
	MOV		EBX,	[EBP+32]					; lengthOfInput
	MOV		ECX,	[EBX]

	; Take the string and see if the first item is a sign (+ or -)
	MOV		ESI,	[EBP+12]					; inputFromUser
	MOV		AH,		[ESI]
	CMP		AH,		'-'
	JE		_containsSign
	CMP		AH,		'+'
	JE		_containsSign

	; If it is positive, evaluation can begin
	JMP		_stringEvaluation

_containsSign:
	; if the input has a sign, but nothing else, it is invalid
	CMP		ECX,		1
	JE		_invalidInput

	; Otherwise, move to the next item, and indicate that it has a sign
	ADD		ESI,		1
	MOV		hasSign,	1
	DEC		ECX
	
_stringEvaluation:
	PUSH	ESI
	PUSH	[EBP+32]							;lengthOfInput
	LEA		EBX,	numsFound
	PUSH	EBX
	LEA		EDI,	hasSign
	PUSH	EDI
	PUSH	ECX
	CALL	evaluateString


_evaluateLength:
	; comparing the maximum length of the string allowed with the numbers found
	MOV		EAX,		[EBP+32]				; lengthOfInput
	MOV		EBX,		[EAX]
	CMP		hasSign,	1						; local variable
	JE		_signAdjustment
	JNE		_testForNums

_signAdjustment:
	; if a number has a sign in the front, then the max nums it will have is 1 less than the characters
	DEC		EBX
	JMP		_testForNums

_testForNums:
 	CMP		EBX,		numsFound				; local variable
	JNE		_invalidInput
	JE		_stringToInteger

_invalidInput:
	MOV		EAX,		0
	MOV		[EBP+24],	EAX						; isValid
	JMP		_userInput

_stringToInteger:
	; find userInput location
	MOV		ESI,		[EBP+12]				; inputFromUser

	; check to see if number has a sign, if so, convert to work with it
	;	otherwise, prepare to convert number
	CMP		hasSign,	1
	JE		_signExists
	JMP		_prepConversion

_signExists:
	; if there is a sign, point to the next item in the string
	ADD		ESI,		1
	MOV		EDX,		0
	MOV		EBX,		[EBP+32]				; lengthOfInput
	MOV		ECX,		[EBX]
	DEC		ECX
	JMP		_moveElement

_prepConversion:
	MOV		EBX,		[EBP+32]				; lengthOfInput
	MOV		ECX,		[EBX]

_moveElement:
	MOV		AL,			[ESI]

	MOV		AH,			conversionReady
	CMP		AH,			1
	JE		_prepForBaseComponents

_stringConversion:
	
	; find the power of 10 used for the num component
	LEA		EDI,		powerOfTen
	PUSH	EDI
	PUSH	ECX
	CALL	powersOfTen

	; Move each item from the string into the AL register to work with
	LODSB

	MOV		AH,			0

	; covert that string into its integer version
	SUB		AL,			lowAscii				; local variable
	MOV		singleNum,	AL							

	MOVSX	EAX,		singleNum			

	; now that EAX has the number, we are going to multiply this by the power of 10 that was updated from the CALL
	MOV		EBX,		powerOfTen

	; this looks like singleNum * 10^lengthOfInput
	MUL		EBX									
	
	; Now that we have this number in it's power of 10 component, move it to the stack to work with later
	PUSH	EAX

	; After adding, if EDX > 0 that means there was overflow
	MOV		EDX,		0

	MOV		conversionReady,	1
	LOOP	_stringConversion
	JMP		_stringToInteger
	
_prepForBaseComponents:
	MOV		EAX,	0

_addAllBaseComponents:
	; add each of the components together to make up the whole number
	POP		EBX
	ADD		EAX,	EBX
	LOOP	_addAllBaseComponents

	; if there is a carry flag, that means that the num is greater than 32 bits
	JC		_invalidInput

	; if the variable has a sign, make a two's complement of the value
	CMP		hasSign,	1
	JE		_negativeOfNum
	JNE		_compareNumToMax

_negativeOfNum:
	; if number is subtracted by 1 and is STILL larger than the upperValidation
	;	then the negative version of this will not fit within a 32-bit register

	; since we know there is a sign, check to see if it is a + sign
	MOV		EDI,	[EBP+12]				; inputFromUser
	MOV		BL,		[EDI]
	CMP		BL,		'+'
	JE		_compareNumToMax

	DEC		EAX
	CMP		EAX,	[EBP+40]				; upperValidation
	JA		_invalidInput

	; return number to original state and take the inverse
	INC		EAX
	NEG		EAX
	JMP		_addToArray

_compareNumToMax:
	; if the number is greater than the upperValidation, it is no longer fit for a signed 32-bit integer
	CMP		EAX,	[EBP+40]				; upperValidation
	JA		_invalidInput

_addToArray:

	LEA		EBX,	count
	PUSH	[EBP+20]
	PUSH	EBX
	PUSH	EAX
	CALL insertArrayElement			

	CMP		count,	9
	JE		_finish
	INC		count
	JMP		_userInput

	_finish:
	RET		40
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: evaluateString
;
; iterates through the string to determine if it the right amount of numbers to 
;	qualify for further evaluation
;
; Postconditions: None
;
; Receives:
; [EBP+24] = inputFromUser
; [EBP+20] = lengthOfInput
; [EBP+16] = numsFound; this represents the amount of numbers found in the input
; [EBP+12] = hasSign; local variable from calling procedure this indicates if there is a sign
; [EBP+8] = ECX, which is the length of the string
;
; returns: powerOfTen (local variable to ReadVal) currently has a value
; ---------------------------------------------------------------------------------
evaluateString PROC
	PUSH	EBP
	MOV		EBP,	ESP

	PUSHAD

	; assigning numsFound to the EDX register
	MOV		EBX,	[EBP+16]
	MOV		EDX,	[EBX]

	MOV		AL,		48							; this is the lowAscii value

	MOV		ECX,	[EBP+8]

_preEvaluate:
	MOV		EBX,	[EBP+24]
	MOV		ESI,	EBX							; userInput

_evaluateString:
	; if an item is found, increment the counter that keeps track of numbers
	;	if the item is not found, go to the next ASCII character and try again
	MOV		AH,		[ESI]						; for debugging purposes
	CMP		AL,		[ESI]
	JE		_countUp

	ADD		ESI,	1
	LOOP	_evaluateString
	JMP		_testForNextAscii

_countUp:
	INC		EDX									; numsFound
	ADD		ESI,	1
	LOOP	_evaluateString
	JMP		_testForNextAscii

_testForNextAscii:
	CMP		AL,		57							; highAscii
	JNE		_incrementAscii
	JE		_exitProc

_incrementAscii:
	INC		AL

	; prepare counter for string evaluation
	MOV		EBX,	[EBP+20]					; lengthOfInput
	MOV		ECX,	[EBX]

	; set pointer back to inputFromUser reference
	MOV		ESI,	[EBP+24]					; inputFromUser
	MOV		BL,		[ESI]

	MOV		EBX,	[EBP+12]					; hasSign
	MOV		EDI,	[EBX]
	CMP		EDI,	1
	JE		_moveUpOneByte	
	JNE		_reevaluate

	; since it's a negative, the first character is not considered, so ECX is one less
_moveUpOneByte:
	ADD		ESI,	1
	LOOP	_preEvaluate

	; increase the counter to work with the whole string after the loop
_reevaluate:
	MOV		EBX,	[EBP+12]
	MOV		EDI,	[EBX]
	CMP		EDI,	1
	JE		_isNeg
	INC		ECX
	LOOP	_evaluateString
	JMP		_exitProc

_isNeg:
	LOOP	_evaluateString
	JMP		_exitProc

_exitProc:
	; return numsFound
	MOV		EAX,	[EBP+16]
	MOV		[EAX],	EDX

	POPAD

	POP		EBP
	RET		20
evaluateString ENDP

; ---------------------------------------------------------------------------------
; Name: powersOfTen
;
; Creates the current power of ten based on the string representation of the number
;	currently being evaluated in ReadVal.
;
; Preconditions: variable powerOfTen has a value and is passed as a reference
;				 ECX is the place of the string representation of the number being evaluated
;
; Postconditions: None
;
; Receives:
; [EBP+12] = stack location of powerOfTen (local variable of calling procedure)
; [EBP+8] = ECX, which is the current 10s place being evaluated
;
; returns: powerOfTen (local variable to ReadVal) receives a value
; ---------------------------------------------------------------------------------
powersOfTen PROC

	PUSH	EBP
	MOV		EBP,	ESP

	; preserving previous registers
	PUSHAD

	; EAX is prepping to be a place holder for the power of 10's
	MOV		EAX,	1

	; set ECX to the current 10s place being evaluated
	MOV		ECX,	[EBP+8]

	; if ECX is 1, this doesn't need to be done
	CMP		ECX,	1
	JE		_assignPowerOfTen
	JMP		_prepForExp
	
_prepForExp:
	DEC		ECX

	MOV		EBX,	10

	; find the exponent of 10^n
_tenToTheN:
	MUL		EBX
	LOOP	_tenToTheN

_assignPowerOfTen:
	; now that we have our number, assign that to the powerOfTen (local from calling proc)
	MOV		EBX,	[EBP+12]
	MOV		[EBX],	EAX	

	; restoring all registers
	POPAD
	
	POP		EBP
	RET		8
powersOfTen ENDP

; ---------------------------------------------------------------------------------
; Name: insertArrayElement
;
; This is a subprocedure to ReadVal. This takes a number that has been validated
;	and adds it as an element to the array
;	
;
; Preconditions: Element has been identified and tested
;				
; Postconditions: None
;
; Receives:
; [EBP+16] = Array memory location
; [EBP+12] = count, this represents what number will be added to array
; [EBP+8] =	integer that is ready to be placed in array
;
; returns: updates numArray with element
; ---------------------------------------------------------------------------------
insertArrayElement PROC
	PUSH	EBP
	MOV		EBP,	ESP

	; preserve current registers
	PUSH	EAX
	PUSH	EBX

	; find the location where to put the next item
	MOV		EBX,	[EBP+12]				; count
	MOV		EAX,	[EBX]
	MOV		EBX,	4						
	MUL		EBX

	MOV		EDI,	[EBP+16]				; array
	ADD		EDI,	EAX
	MOV		EBX,	[EBP+8]					; integer ready to be placed
	MOV		[EDI],	EBX

	; restore registers
	POP		EBX
	POP		EAX

	POP		EBP
	RET		12	
insertArrayElement ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Shows the valid inputs that the user input. Also shows the sum and the floored average
;	
; Preconditions: numArray is filled with numbers that fit within a 32-bit register
;
; Postconditions: Prints all values to screen for the user, 
;
; Receives:
; [EBP+64]	= address of farewell
; [EBP+60]	= address of average
; [EBP+56]	= stringBuffer - this is the length of stringForOutput
; [EBP+52]	= address of sum
; [EBP+48]	= address of printHeaderForArray
; [EBP+44]	= address of isAvg
; [EBP+40]	= address of isSum
; [EBP+36]	= address of isArray 
; [EBP+32]	= address of isIntro
; [EBP+28]	= address of numsHeader
; [EBP+24]	= address of avgHeader
; [EBP+20]	= address of sumHeader
; [EBP+16]	= LENGTHOF numArray
; [EBP+12]	= address of numArray
; [EBP+8]	= address of stringForOutput
;
; returns: all values printed to screen using mDisplayString macro
; ---------------------------------------------------------------------------------
WriteVal PROC
	LOCAL	powerOfTen: DWORD, fullNum: DWORD, singleNum:DWORD, amountOfDigits:DWORD, fullDigitCount:DWORD, count:DWORD, zerosToAdd:DWORD, digitTracker:DWORD

	MOV		ESI,	[EBP+12]					; numArray
	MOV		EBX,	0
	MOV		ECX,	[EBP+16]					; LENGTHOF numArray
	INC		ECX

	; initialize local variables
	MOV		amountOfDigits,	0
	MOV		powerOfTen,		1
	MOV		count,			0

_loadNumFromArray:
	
	MOV		EDI,	[EBP+8]						; stringForOutput

	LODSD

	MOV		EBX,	0

	MOV		digitTracker,	0					; accounts for trailing zeros

	; check to see if the sign flag is raised
	CMP		EAX,	1
	JS		_loadSign
	JMP		_breakDownEachElement

_loadSign:
	; change to the positive version
	NEG		EAX
	; since AL is changed, preserve EAX
	PUSH	EAX

	; add - to the string representation of the number
	MOV		AL,		'-'
	STOSB
	
	; return the value back to itself
	POP		EAX

_breakDownEachElement:

	; initialize how many zeros to be added with each element
	MOV		zerosToAdd,		0

	; EBX, the first time, is 0, otherwise, subtract the 10s component
	SUB		EAX,	EBX

	; once all components are removed -- evaluate the next item in numArray
	CMP		EAX,	0
	JZ		_printToScreen

	; save EAX for later
	PUSH	EAX

	LEA		EBX,	zerosToAdd						; local variable
	PUSH	EBX
	PUSH	EAX
	LEA		EDX,	amountOfDigits					; local variable
	PUSH	EDX
	CALL	findDigitPlace

	MOV		EBX,	amountOfDigits					; local variable
	
; ------------------------------------------------------------------------
; Here we initialize the amount of initial nums. This is ran the first
;	time the place is being determined. If the amount of digits is two
;	less than the previous place, then this number is a zero and should
;	be added to the string.
; ------------------------------------------------------------------------
	
	MOV		EDX,	zerosToAdd						; local variable
	CMP		EDX,	1
	JA		_addZeros
	JMP		_dontAddZeros

_addZeros: 
	PUSH	EAX
	PUSH	ECX

	; ECX will contain the variable zerosToAdd
	MOV		ECX,	EDX
	CMP		ECX,	1
	DEC		ECX

	; keep track of the amount of zeros added
	MOV		EAX,			digitTracker
	ADD		EAX,			ECX
	MOV		digitTracker,	EAX
	MOV		EAX,			0

	; AL is loaded with the ACII '0' and is added
	MOV		AL,		48
	REP		STOSB
	
	POP		ECX
	POP		EAX

_dontAddZeros:
	; find the power of 10 currently being evaluated
	LEA		EDX,		powerOfTen					; local variable
	PUSH	EDX
	PUSH	EBX
	CALL	powersOfTen
	
	; in case powerOfTen ever becomes 0
	CMP		powerOfTen,	0
	JE		_safeForDividing
	JMP		_nowToDivide

_safeForDividing:
	INC		powerOfTen								; local variable

_nowToDivide:
	; Find the base component in EAX
	MOV		EDX,	0
	DIV		powerOfTen								; local variable

	; this is the previous value of EAX -- work with this later
	POP		fullNum									; local variable

	; EAX is now the single number
	PUSH	EAX

_addToString:
	; put the single number into the string to display to the screen
	ADD		EAX,		48
	MOV		singleNum,	EAX
	MOV		AL,			BYTE PTR singleNum

	STOSB

	; track each digit stored in memory
	INC		digitTracker

	; take that individual number and find it's power of ten
	POP		EAX
	MOV		EBX,	powerOfTen
	MUL		EBX

	; prepare the power of ten number to be subtracted later from the full number
	MOV		EBX,	EAX

	MOV		EAX,	fullNum
	JMP		_breakDownEachElement

_printToScreen:
	
	; check to see if the digitTracker and amountOfDigits is the same
	;	if it is not the same, add trailing zeroes
	MOV		EAX,	amountOfDigits
	MOV		EBX,	digitTracker
	CMP		EAX,	EBX
	JA		_addTrailingZeroes
	JMP		_checkIfArrayIsDone

_addTrailingZeroes:
	PUSH	ECX
	
	SUB		EAX,	EBX
	MOV		ECX,	EAX
	MOV		AL,		'0'
	REP		STOSB

	POP		ECX

_checkIfArrayIsDone:
	; checks to see if isArray if 0, if so, that means that it
	;	has been evaluated already, so check to see if sum or
	;	average needs to be printed next
 	MOV		EBX,	[EBP+36]
	MOV		EAX,	[EBX]
	CMP		EAX,	0
	JZ		_checkForSumOrAverage

	MOV		AL,		','
	STOSB
	MOV		AL,		' '
	STOSB
	
_loadNextNum:
	; after printing, print the next num
	LOOP	_printAndLoadNextNum
	JMP		_summation

_printAndLoadNextNum:

;	mDisplayString isIntro, isArray, isSum, isAvg, printHeaderForArray, numsHeader, numsHeader, stringForOutput, farewell
	mDisplayString [EBP+32], [EBP+36], [EBP+40], [EBP+44], [EBP+48], [EBP+28], [EBP+28], [EBP+8], [EBP+64]

	; preserve ECX
	PUSH	ECX

	; clean up stringForOutput
	PUSH	[EBP+56]							; stringBuffer
	PUSH	[EBP+8]								; stringForOutput
	CALL	cleanString

	POP		ECX
	CMP		ECX,	0
	JZ		_summation
	JMP		_loadNumFromArray

_summation:
	
	; reset the digit tracker in preparation for printing sum
	MOV		digitTracker,	0

	; this is no longer an array, so set isArray to 0
	MOV		EAX,	[EBP+36]
	MOV		EDX,	0
	MOV		[EAX],	EDX

	; clean up stringForOutput
	PUSH	[EBP+56]							; stringBuffer
	PUSH	[EBP+8]								; stringForOutput
	CALL	cleanString

	PUSH	[EBP+52]							; sum
	PUSH	[EBP+16]							; LengthOf numArray
	PUSH	[EBP+12]							; numArray
	PUSH	[EBP+8]								; stringForInput
	CALL	findSum

	; prep the sum to be printed to the screen
	MOV		EBX,	[EBP+52]					; address of sum
	MOV		EAX,	[EBX]					
	MOV		EDI,	[EBP+8]						; stringForOutput
	MOV		EBX,	0

	; check to see if the number is a negative, if so adjust
	CMP		EAX,	1
	JS		_loadSign
	JMP		_breakDownEachElement

_average:
	; clean up stringForOutput
	PUSH	[EBP+56]							; stringBuffer
	PUSH	[EBP+8]								; stringForOutput
	CALL	cleanString

	PUSH	[EBP+16]							; LENGTHOF numArray
	PUSH	[EBP+60]							; address of average
	PUSH	[EBP+52]							; address of sum
	CALL	findAverage

	; prep the average to be printed to the screen
	MOV		EBX,	[EBP+60]					; address of average
	MOV		EAX,	[EBX]					
	MOV		EDI,	[EBP+8]						; stringForOutput
	MOV		EBX,	0

	; check to see if the number is a negative, if so adjust
	CMP		EAX,	1
	JS		_loadSign
	JMP		_breakDownEachElement

_checkForSumOrAverage:
	; check to see if isSum is 1. If so, print the sum
	;	otherwise, prepare to print the average
	MOV		EDX,	[EBP+40]	
	MOV		EAX,	[EDX]
	CMP		EAX,	1
	JE		_printSum
	JMP		_printAverage

_printSum:
;	mDisplayString isIntro, isArray, isSum, isAvg, printHeaderForArray, sumHeader, sumHeader, stringForOutput, farewell
	mDisplayString [EBP+32], [EBP+36], [EBP+40], [EBP+44], [EBP+48], [EBP+20], [EBP+20], [EBP+8], [EBP+64]
	
	; reset the digit tracker once the string has been printed
	MOV		digitTracker,	0

	JMP		_average

_printAverage:
;	mDisplayString isIntro, isArray, isSum, isAvg, printHeaderForArray, averageHeader, averageHeader, stringForOutput, farewell
	mDisplayString [EBP+32], [EBP+36], [EBP+40], [EBP+44], [EBP+48], [EBP+24], [EBP+24], [EBP+8], [EBP+64]


	RET 60
WriteVal ENDP
	
; ---------------------------------------------------------------------------------
; Name: findDigitPlace
;
; finds how many digits are in a given number; uses a brute force method
;	
; Preconditions: the maximum and minimum allowed values are defined constants
;
; Postconditions: None
;
; Receives:
; [EBP+16]	= zerosToAdd
; [EBP+12]	= the current number being evaluated
; [EBP+8]	= amountOfDigits
;
; returns: the amount of digits in the current number being evaluated
; ---------------------------------------------------------------------------------
findDigitPlace PROC
	LOCAL	ten:DWORD

	PUSHAD

	; keep track of the previous amount of digits being evaluated
	MOV		EBX,	[EBP+8]				
	MOV		EAX,	[EBX]
	PUSH	EAX

	; EBX will act as a counter
	MOV		EBX,	0
	MOV		ten,	10

	; EDX is initialized to the highest 10s allowed
	MOV		EAX,		1000000000

	; Compare each item 
_findCount:
	; -----------------------------------------------------------
	; goes through all the 10's places and finds how many places
	;	the number under evaluateion currently has
	; -----------------------------------------------------------
	MOV		EDX,	0
	CMP		[EBP+12],	EAX					; the current number being evaluated
	JAE		_increaseCount
	DIV		ten
	CMP		EAX,	0
	JNZ		_findCount
	JZ		_assignPlaceAndEvaluateForZeros

_increaseCount:
	; when a place is found, count is increased
	INC		EBX
	MOV		EDX,	0
	DIV		ten
	CMP		EAX,	0
	JZ		_assignPlaceAndEvaluateForZeros
	JMP		_findCount

_assignPlaceAndEvaluateForZeros:
	; assign the amount of digits to the variable amountOfDigits
	MOV		EDX,	[EBP+8]
	MOV		[EDX],	EBX

	; check to see if the previous amount of digits being evaluated
	;	is 2 or more less than the previous number being evaluated and 
	;	save this to be used later
	POP		EDX
	SUB		EDX,	EBX
	CMP		EDX,	1
	JS		_exitProc					; handles first evaluation instance
	JA		_prepToAddZeros
	JMP		_exitProc

_prepToAddZeros:
	MOV		EAX,	[EBP+16]
	MOV		[EAX],	EDX

_exitProc:
	POPAD

	RET	12
findDigitPlace ENDP

; ---------------------------------------------------------------------------------
; Name: findSum
;
; Adds all numbers in the array together
;	
; Preconditions: numArray is filled with numbers that fit within a 32-bit register
;
; Postconditions: None
;
; Receives:
; [EBP+20]	= address of sum
; [EBP+16]	= LENGTHOF numArray
; [EBP+12]	= address of numArray
; [EBP+8]	= address of stringForOutput
;
; returns: the variable sum is now filled with the sum of the numbers
; ---------------------------------------------------------------------------------
findSum	PROC
	LOCAL	num:DWORD

	PUSHAD

	; set counter and address of numArray
	MOV		EBX,	0
	MOV		ECX,	[EBP+16]
	MOV		ESI,	[EBP+12]

_whereSumHappens:
	LODSD

	ADD		EBX,	EAX
	LOOP	_whereSumHappens

	MOV		EDX,	[EBP+20]
	MOV		[EDX],	EBX

	POPAD

	RET	16
findSum	ENDP

; ---------------------------------------------------------------------------------
; Name: findAverage
;
; finds the average of all the numbers input by user this takes the sum and 
;	divides that by the length of the array, which is 10
;	
; Preconditions: numArray is filled with numbers that fit within a 32-bit register.
;		The variable sum contains the summation of the items in the array
;
; Postconditions: None
;
; Receives:
; [EBP+16]	= LENGTHOF numArray
; [EBP+12]	= address of average
; [EBP+8]	= address of sum
;
; returns: the variable average has the floored average of the numbers
; ---------------------------------------------------------------------------------
findAverage	PROC
	LOCAL	lengthOfArray:DWORD

	PUSHAD

	; set up divisor
	MOV		EDX,			[EBP+16]
	MOV		lengthOfArray,	EDX
	MOV		EDX,			0

	; check to see if num is negative
	MOV		EBX,	[EBP+8]
	MOV		EAX,	[EBX]
	CMP		EAX,	1
	JS		_negativeDivide
	JMP		_positiveDivide

_negativeDivide:

	CDQ
	IDIV	lengthOfArray
	JMP		_assignToAvg

_positiveDivide:
	
	DIV		lengthOfArray
	JMP		_assignToAvg

_assignToAvg:

	MOV		EBX,	[EBP+12]
	MOV		[EBX],	EAX

_exitProcedure:
	POPAD
	RET	12

findAverage	ENDP

; ---------------------------------------------------------------------------------
; Name: cleanString
;
; cleans up the string that will be output to the screen
;	
; Preconditions: variable stringForOutput and constant stringBuffer are declared
;
; Postconditions: stringForOutput is cleaned up
;
; Receives:
; [EBP+12]	= stringBuffer
; [EBP+8]	= address of stringForOutput
;
; returns: None
; ---------------------------------------------------------------------------------
cleanString PROC

	PUSH	EBP
	MOV		EBP,	ESP
	PUSHAD

	; clean up stringForOutput
	MOV		EDI,	[EBP+8]						; stringForOutput
	MOV		AL,		0
	MOV		ECX,	[EBP+12]					; stringBuffer
	REP		STOSB

	POPAD
	POP		EBP

	RET	8
cleanString ENDP

END main
