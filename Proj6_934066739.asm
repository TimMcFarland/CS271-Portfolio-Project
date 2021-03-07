TITLE Proj6_934066739     (Proj6_934066739.asm)

; Author: Tim McFarland
; Last Modified: 3/6/2021
; OSU email address: mcfarlti@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6              Due Date: 3/14/2021
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; Macro Definitions
mGetString   MACRO prompt, userInput, characterCount  
	; Display a prompt (input parameter by reference)
		; Get the user's keyboard input into a memory location (output parameter, by reference)
	; Provide count for length of input string
	LOCAL _sumLoop
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	
	MOV		EDX,	prompt
	CALL	WriteString
	MOV		EDX,	userInput
	MOV		ECX,	characterCount
	MOV		characterCount,	EAX
	CALL	ReadString
	POP		EDX
	POP		EBX
	POP		EAX
ENDM

; (insert constant definitions here)
upperValidation = 2147483647	; this is the maximum number allowed for input
lowerValidation = -2147482648	; this is the minimum number allowed for input

.data
; variables used in introduction
programHeader			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10
						BYTE		"Written by: Tim McFarland",13, 10, 0

programInstructions		BYTE		"Please provide 10 signed decimal integers.", 13, 10, 10
						BYTE		"Each number needs to fit inside a 32 bit register; range of [-2,147,482,648 to 2,147,483,647].", 13, 10, 10
						BYTE		"After you have finished inputting the raw numbers, I will display the following:", 13, 10 
						BYTE		"a list of integers, their sum, and their raw average value. -- Neat, right?", 13, 10, 0

userPrompt				BYTE		"please enter a signed number: ", 0

inputFromUser			BYTE		12	DUP(0)		; set to a size of 12 since -2,147,482,648 is the longest character allowed
; variables used in data validation
errorMessage			BYTE		"ERROR: You did not enter a signed number or your number was too big.", 13, 10, 0

.code
main PROC
	; Introduction is shown
	PUSH	OFFSET	programInstructions
	PUSH	OFFSET	programHeader
	CALL	introduction

	PUSH	SIZEOF inputFromUser
	PUSH	OFFSET	inputFromUser
	PUSH	OFFSET	userPrompt
	CALL	ReadVal
	CALL	WriteVal

	Invoke ExitProcess, 0	; exit to operating system
main ENDP

; (insert additional procedures here)

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Provides introduction to program and gives information to user on how to input information
;
; Preconditions: variables programHeader and programInstructions are string variables
;
; Postconditions: None
;
; Receives:
; [ebp+12] = programInstructions
; [ebp+8] = programHeader
;
; returns: None
; ---------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP	
	MOV		EBP,	ESP
	MOV		EDX,	[EBP+8]				; programHeader
	CALL	WriteString
	MOV		EDX,	[EBP+12]			; programInstructions
	CALL	CrLf
	CALL	WriteString
	POP		EBP
	RET		8
introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Provides introduction to program and gives information to user on how to input information
;
; Preconditions: variables programHeader and programInstructions are string variables
;
; Postconditions: None
;
; Receives:
; [EBP+16] = SIZEOF inputFromUser
; [EBP+12] = inputFromUser
; [EBP+8] = userPrompt
;
; returns: None
; ---------------------------------------------------------------------------------
ReadVal	PROC
	PUSH	EBP	
	MOV		EBP,	ESP
	; MUST invoke the mGetString Macro to get user input in the form of a string of digits
	; Convert (using string primitives) the string of ASCII digits to its numeric value representation (SDWORD)
		;	Validate the user's input is a valid number (no letters, symbols, etc).
	; Store this value in a memory variable
	mGetString [EBP+8], [EBP+12], [EBP+16]
	POP		EBP
	RET		12
ReadVal ENDP

WriteVal PROC
	; Convert a numeric SDWORD value (input parameter, by value) to a string of ASCII digits
	; Invoke the mDisplayString macro to print the ASCII representation of the SDWORD value to the output
WriteVal ENDP
END main
	


;------------------------------------------------
; Program Description
;------------------------------------------------
; Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):
; I. Implement and test two macros for string processing. These macros may use Irvine�s ReadString to get input from the user, and WriteString procedures to display output.
; a. mGetSring:  Display a prompt (input parameter, by reference), then get the user�s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
; b. mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).
; II. Implement and test two procedures for signed integers which use string primitive instructions
; ReadVal: 
; 1. Invoke the mGetSring macro (see parameter requirements above) to get user input in the form of a string of digits.
; 2. Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user�s input is a valid number (no letters, symbols, etc).
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
; 1. User�s numeric input must be validated the hard way:
; a. Read the user's input as a string and convert the string to numeric form.
; b. If the user enters non-digits other than something which will indicate sign (e.g. �+� or �-�), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
; c. If the user enters nothing (empty input), display an error and re-prompt.
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
; 3. When displaying the average, you may round down (floor) to the nearest integer. For example if the sum of the 10 numbers is 3568 you may display the average as 356.
; 4. Check the Course SyllabusPreview the document for late submission guidelines.
; 5. Find the assembly language instruction syntax and help in the CS271 Instructions Guide.
; 6. To create, assemble, run,  and modify your program, follow the instructions on the course Syllabus Page�s "Tools" tab.

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