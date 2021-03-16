TITLE Proj6_934066739     (Proj6_934066739.asm)

; Author: Tim McFarland
; Last Modified: 3/15/2021
; OSU email address: mcfarlti@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6              Due Date: 3/18/2021
; Description: Receives 10 different integers from a user and validates whether or not those integers
;	fit within a 32 bit register. If they do, then those numbers are printed to the screen, and the 
;	sum of those numbers as well as the average of those numbers is also shown. This is all done
;	using string primitives.

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
;	and the sum and average of the input.
;
; Preconditions: introduction is defined in the first use case, numArray is defined
;	in the second use case, sum is defined in the third use case, and average is 
;	defined in the fourth use case
;
; Receives:
; prompt = userPrompt, which provides direction to the user
; userInput = inputFromUser
; characterCount = SIZEOF inputFromUser
; validCheck = isValid variable
; errMessage = memory location of the string errorMessage
; isItIntro = isIntro, which is defined as 1 initially, 0 anytime after
;
; returns: inputLength = lengthOfInput is updated
;		   userInput = userInput is updated
;		   isIntro is changed to 0 if isIntro is initially 1
; ---------------------------------------------------------------------------------
mDisplayString	MACRO isItIntro:REQ, isItArray:REQ, isItSum:REQ, isItAvg:REQ, headerText:REQ, instructions:REQ

	LOCAL	_endDisplayString
	LOCAL	_introduction

	; preserve all registers
	PUSHAD

	; if this is an intro, display the intro header
	MOV		EBX,			isItIntro
	MOV		EAX,			[EBX]
	CMP		EAX,			1
	JE		_introduction

_introduction:
	MOV		EDX,	headerText
	CALL	WriteString
	CALL	CrLf
	MOV		EDX,	instructions
	CALL	WriteString

	; set isIntro to 0 as it will no longer be called
	MOV		EDX,	0
	MOV		[EBX],	EDX
	JMP		_endDisplayString


_endDisplayString:
	POPAD
ENDM

; constantDefinitions
upperValidation =	 2147483647						; this is the maximum number allowed for input
lowerValidation =	-2147482648						; this is the minimum number allowed for input
maxInputLength	=	11

.data
; variables used in introduction
programHeader			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10
						BYTE		"Written by: Tim McFarland",13, 10, 0

programInstructions		BYTE		"Please provide 10 signed decimal integers.", 13, 10, 10
						BYTE		"Each number needs to fit inside a 32 bit register; range of [-2,147,482,648 to 2,147,483,647].", 13, 10, 10
						BYTE		"After you have finished inputting the raw numbers, I will display the following:", 13, 10 
						BYTE		"a list of integers, their sum, and their raw average value. -- Neat, right?", 13, 10, 0

userPrompt				BYTE		"please enter a signed number: ", 0

numsHeader				BYTE		"You entered for following numbers: ", 13, 10, 0

sumHeader				BYTE		"The sum of these numbers is: ", 0

avgHeader				BYTE		"The average of these numbers is: ", 0

inputFromUser			BYTE		20	DUP(0)		; set to a size of 12 since -2,147,482,648 is the longest character allowed

lengthOfInput			DWORD		?

stringForOutput			BYTE		12	DUP(0)

; variables used in data validation
errorMessage			BYTE		"ERROR: You did not enter a signed number or your number was too big.", 13, 10
						BYTE		"Please try again: ", 0

isValid					DWORD		1

; array used to keep track of items
numArray				SDWORD		9 DUP(?)

; Initializing items that manage mDisplayString macro
isIntro					DWORD		1
isArray					DWORD		0
isSum					DWORD		0
isAvg					DWORD		0

.code
main PROC

	; Introduction is shown

	mDisplayString OFFSET isIntro, OFFSET isArray, OFFSET isSum, OFFSET isAvg, OFFSET programHeader, OFFSET programInstructions


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

	PUSH	isAvg
	PUSH	isSum
	PUSH	isArray
	PUSH	isIntro
	PUSH	OFFSET		numsHeader
	PUSH	OFFSET		avgHeader
	PUSH	OFFSET		sumHeader
	PUSH	LENGTHOF	numArray
	PUSH	OFFSET		numArray
	PUSH	OFFSET		stringForOutput
	CALL	WriteVal

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

	LOCAL	lowAscii:BYTE, highAscii:BYTE, numsFound:DWORD, hasSign:DWORD, powerOfTen: DWORD, conversionReady: BYTE,
			count:DWORD, singleNum:BYTE

	; these are constants
	MOV		lowAscii,	48
	MOV		highAscii,	57
	MOV		count,		0
	; MUST invoke the mGetString Macro to get user input in the form of a string of digits
	; Convert (using string primitives) the string of ASCII digits to its numeric value representation (SDWORD)
		;	Validate the user's input is a valid number (no letters, symbols, etc).
	; Store this value in a memory variable

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
	
	; iterates through ESI and compares with AL at each step

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
	; here, we are going to compare the count, which has accrued each time that number was found, and
	;	we are going to compare that with 1 less than the maximum allowed input because that is the number
	;	that count should be in this respect

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
	; Here, each string element is 
	; find userInput location
	MOV		ESI,		[EBP+12]					; inputFromUser

	CMP		hasSign,	1

	JE		_signExists
	JMP		_prepConversion

_signExists:
	; if there is a sign, point to the next item in the string
	ADD		ESI,		1
	MOV		EDX,		0
	MOV		EBX,		[EBP+32]					; lengthOfInput
	MOV		ECX,		[EBX]
	DEC		ECX
	JMP		_moveElement

_prepConversion:
	MOV		EBX,		[EBP+32]					; lengthOfInput
	MOV		ECX,		[EBX]

_moveElement:
	MOV		AL,			[ESI]

	MOV		AH,			conversionReady
	CMP		AH,			1
	JE		_prepForBaseComponents

_stringConversion:
	
	; Algorithm:
	; max num is 2147483647 and -2147483648
	; Note that EDX is already 0
	; Note that EAX already has the latest number in it

	LEA		EDI,		powerOfTen
	PUSH	EDI
	PUSH	ECX
	CALL	powersOfTen

	; Move each item from the string into the AL register to work with
	LODSB

	MOV		AH,			0

	; covert that string into its integer version
	SUB		AL,			lowAscii					; local variable
	MOV		singleNum,	AL							

	MOVSX	EAX,		singleNum			

	; now that EAX has the number, we are going to multiply this by the power of 10 that was updated from the CALL
	MOV		EBX,		powerOfTen
	MUL		EBX										; this looks like singleNum * 10^lengthOfInput
	
	; Now that we have this number in it's power of 10 component, move it to the stack to work with later
	PUSH	EAX

	; After adding, if EDX > 0 that means there was overflow
	MOV		EDX,		0

	; Repeat this process again until we have all the numbers on the stack
	; LOOP _stringConversion

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
	RET		12
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
	MOV		EBX,	[EBP+20]				; lengthOfInput
	MOV		ECX,	[EBX]

	; set pointer back to inputFromUser reference
	MOV		ESI,	[EBP+24]				; inputFromUser
	MOV		BL,		[ESI]

	MOV		EBX,	[EBP+12]				; hasSign
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
; returns: powerOfTen (local variable to ReadVal) currently has a value
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
; Postconditions: None
;
; Receives:
; [EBP+16] = LENGTHOF numArray
; [EBP+12] = numArray
; [EBP+8]  = stringForOutput
;
; returns: None
; ---------------------------------------------------------------------------------
WriteVal PROC
	; Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits
	; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value to the output
	LOCAL	powerOfTen: DWORD, fullNum: DWORD, singleNum:DWORD, amountOfDigits:DWORD

	MOV		EDI,	[EBP+8]						; stringForOutput
	MOV		ESI,	[EBP+12]					; numArray
	MOV		EBX,	0
	MOV		ECX,	[EBP+16]					; LENGTHOF numArray
	INC		ECX

	; initialize local variables
	MOV		amountOfDigits,	0
	MOV		powerOfTen,		1

_loadNumFromArray:
	LODSD

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
	; EBX, the first time, is 0, otherwise, subtract the 10s component
	SUB		EAX,	EBX

	; once all components are removed -- evaluate the next item in numArray
	CMP		EAX,	0
	JZ		_printToScreen

	; save EAX for later
	PUSH	EAX

	PUSH	EAX
	LEA		EDX,	amountOfDigits
	PUSH	EDX
	CALL	findDigitPlace

	MOV		EBX,	amountOfDigits

	; find the power of 10 currently being evaluated
	LEA		EDX,		powerOfTen
	PUSH	EDX
	PUSH	EBX
	CALL	powersOfTen
	
	; in case powerOfTen ever becomes 0
	CMP		powerOfTen,	0
	JE		_safeForDividing
	JMP		_nowToDivide

_safeForDividing:
	INC		powerOfTen

_nowToDivide:
	; Find the base component in EAX
	MOV		EDX,	0
	DIV		powerOfTen

	; this is the previous value of EAX -- work with this later
	POP		fullNum

	; EAX is now the single number
	PUSH	EAX

_addToString:
	; put the single number into the string to display to the screen
	ADD		EAX,		48
	MOV		singleNum,	EAX
	MOV		AL,			BYTE PTR singleNum

	STOSB

	; take that individual number and find it's power of ten
	POP		EAX
	MOV		EBX,	powerOfTen
	MUL		EBX

	; prepare the power of ten number to be subtracted later from the full number
	MOV		EBX,	EAX

	MOV		EAX,	fullNum

	JMP		_breakDownEachElement

_printToScreen:
	
	
_loadNextNum:
	LOOP	_loadNumFromArray
	RET 12

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
; [EBP+12] = the current number being evaluated
; [EBP+8]  = amountOfDigits
;
; returns: the amount of digits in the current number being evaluated
; ---------------------------------------------------------------------------------
findDigitPlace PROC
	LOCAL	ten:DWORD

	PUSHAD

	; EBX will act as a counter
	MOV		EBX,	0
	MOV		ten,	10

	; EDX is initialized to the highest 10s allowed
	MOV		EAX,		1000000000

	; Compare each item 
_findCount:
	MOV		EDX,	0
	CMP		[EBP+12],	EAX
	JAE		_increaseCount
	DIV		ten
	CMP		EAX,	0
	JNZ		_findCount
	JZ		_endOfProc

_increaseCount:
	INC		EBX
	MOV		EDX,	0
	DIV		ten
	CMP		EAX,	0
	JZ		_endOfProc
	JMP		_findCount

_endOfProc:
	
	MOV		EDX,	[EBP+8]
	MOV		[EDX],	EBX
	POPAD

	RET	8
findDigitPlace ENDP

END main


;------------------------------------------------
; Program Description
;------------------------------------------------


; Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):
; I. Implement and test two macros for string processing. These macros may use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
; a. mGetSring:  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
; b. mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).
; II. Implement and test two procedures for signed integers which use string primitive instructions


; ReadVal: 
; 1. Invoke the mGetSring macro (see parameter requirements above) to get user input in the form of a string of digits.
; 2. Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
; 3. Store this value in a memory variable (output parameter, by reference). 


; WriteVal: 
; 1. Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
; 2. Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.


; Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:
; 1. Get 10 valid integers from the user.
; 2. Stores these numeric values in an array.
; 3. Display the integers, their sum, and their average.


;----------------------------------------------------
; Program Requirements
;----------------------------------------------------
; 1. User’s numeric input must be validated the hard way:
;	a. Read the user's input as a string and convert the string to numeric form.
;	b. If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
;	c. If the user enters nothing (empty input), display an error and re-prompt.
; 2. ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.
; 3. Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.
; 4. All procedure parameters must be passed on the runtime stack. Strings must be passed by reference
; 5. Prompts, identifying strings, and other memory locations must be passed by address to the macros.
; 6. Used registers must be saved and restored by the called procedures and macros.
; 7. The stack frame must be cleaned up by the called procedure.
; 8. Procedures (except main) must not reference data segment variables or constants by name. 
; 9. The program must use Register Indirect addressing for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
; 10. Procedures may use local variables when appropriate.
; 11. The program must be fully documented and laid out according to the CS271 Style Guide. This includes a complete header block for identification, description, etc., a comment outline to explain each section of code, and proper procedure headers/documentation.


;------------------------------------------------------
; Notes
;------------------------------------------------------
; 1. For this assignment you are allowed to assume that the total sum of the numbers will fit inside a 32 bit register.
; 2. We will be testing this program with positive and negative values.
; 3. When displaying the average, you may round down (floor) to the nearest integer. For example if the sum of the 10 numbers is 356.8 you may display the average as 356.
; 4. Check the Course SyllabusPreview the document for late submission guidelines.
; 5. Find the assembly language instruction syntax and help in the CS271 Instructions Guide.
; 6. To create, assemble, run,  and modify your program, follow the instructions on the course Syllabus Page’s "Tools" tab.

; ---------------------------------------------------
; Example execution
; ---------------------------------------------------
; PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures 
; Written by: Sheperd Cooper 
; 
; Please provide 10 signed decimal integers.  
; Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value. 
;  
; Please enter an signed number: 156 
; Please enter an signed number: 51d6fd 
; ERROR: You did not enter a signed number or your number was too big. 
; Please try again: 34 
; Please enter a signed number: -186 
; Please enter a signed number: 115616148561615630 
; ERROR: You did not enter an signed number or your number was too big. 
; Please try again: -145
; Please enter a signed number: 5 
; Please enter a signed number: +23 
; Please enter a signed number: 51 
; Please enter a signed number: 0 
; Please enter a signed number: 56 
; Please enter a signed number: 11 
; 
; You entered the following numbers: 
; 156, 34, -186, -145, 5, 23, 51, 0, 56, 11 
; The sum of these numbers is: 5 
; The rounded average is: 1 
 
; Thanks for playing! 