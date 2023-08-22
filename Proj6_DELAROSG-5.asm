TITLE Program Template     (template.asm)

; Author: Guyllian Dela Rosa
; Last Modified: 8/18/23
; OSU email address: delarosg@oregonstate.edu
; Course number/section: 271  CS271 Section 400
; Project Number: 6                Due Date: 8/18/23
; Description: This program uses macros and procedures to prompt the user to enter 10 valid numbers as strings. 
;	The program then converts these strings to their numeric representations and stores them in an array. It also performs
;	validation for each string and re-prompts user if invalid string is entered. The converted strings are saved into an 
;	array, later outputted, and the sum, and average are also displayed. 
;            

INCLUDE Irvine32.inc

; (insert macro definitions here)

; ----- mGetString ----------------------------------------------------------------------------------
; This macro outputs a passed in message, and also takes a user input and saves it to a given memory.
; Pre-Conditions: requires the calling procedure to pass in pEnterMessage, pEnteredNum, and pLengthString
; Post-Conditions: EDX is used for pEnterNumMessage, and pEnteredNum. ECX is loaded with 32 for 32 bits. EAX holds
;	the length of the string.
; Receives:
;		[EBP+16] = enterNumMessage
;		[EBP+20] = enteredNum
;		[EBP+24] = lengthString
; Returns: this returns the enteredNum to be the string the user entered, and also the length of it
; ------------------------------------------------------------------------------------------


	;displays a prompt and takes and saves the user's input. 
	mGetString MACRO pEnterNumMessage, pEnteredNum, pLengthString
		PUSH	EDX
		PUSH	ECX
		PUSH	EAX
		MOV		EDX,	pEnterNumMessage		; prompt user to enter a num
		CALL	WriteString
		MOV		EDX,	pEnteredNum			; address of buffer
		MOV		ECX,	32
		CALL	ReadString							; input the string to enteredNum
		MOV		pLengthString,	EAX					; save length of the string
		POP		EAX
		POP		ECX	
		POP		EDX
	ENDM


; ----- mDisplayString ----------------------------------------------------------------------------------
; This macro displays the string passed in through buffer. 
; Pre-Conditions: assumes that the string variable that is being passed in this macro is OFFSET already. 
; Post-Conditions: PUSH and POP EDX
; Receives: 
;		[EBP+12] = this is whatever string needs to be outputted. 
; Returns: returns the string that has to be outputted to the console. 
; ------------------------------------------------------------------------------------------

	;prints string which is stored in a specificed memory location(buffer)
	mDisplayString MACRO	buffer
		PUSH	EDX
		MOV		EDX,	buffer
		CALL	WriteString
		POP		EDX
	ENDM

; (insert constant definitions here)

.data	
; (insert variable definitions here)
	;these are the variables used in this program. 
	progTitle		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
					BYTE	"Written by: Guyllian Dela Rosa",13,10,13,10,0
	progDescription	BYTE	"Please provide 10 signed decimal integers.",13,10
					BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10
					BYTE	"After you have finished inputting the raw numbers, I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	enterNumMessage	BYTE	"Please enter a signed number: ",0
	enteredNum		BYTE	33 DUP(0)		; this holds the string entered waiting to be verified
	lengthString	DWORD	?				; this will tell us how many characters are in the entered string
	numToString		BYTE	12 DUP(0)		; this is the temporary holder of the num before it gets turned into a string. 

	errorMessage	BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0

	count			DWORD	10
	displayNums		BYTE	"You entered the following numbers:",0
	validNumsArray	SDWORD	10 DUP(0)		; this is the array where all the validated nums will be stored. 
	sumHolder		SDWORD	1	DUP(0)		; this holds the sum of the nums in the array.
	sumMessage		BYTE	"The sum of these numbers is: ",0
	avgMessage		BYTE	"The truncated average is: ",0

	goodbyeMessage	BYTE	"Thanks for playing and joining me for this summer 2023 term! Have a wonderful day ! =) ",13,10,0


.code

; ----- Main ----------------------------------------------------------------------------------
; This is the main procedure and calls all the other procedures. 
; Pre-Conditions: all data variables must exist. 
; Post-Conditions:main makes all the calls. 
; Receives: all the variables are used here
; Returns: none
; ------------------------------------------------------------------------------------------

main PROC

; (insert executable instructions here)
	mDisplayString	OFFSET	progTitle						;display program title and program description. 
	mDisplayString	OFFSET	progDescription

	;This block sets up to loop 10 times prompting the user to enter strings and validating if they are valid. Saves them 
	;in validNumsArray.
	MOV		ECX,	count
	MOV		EAX,	OFFSET		validNumsArray
	;this is the start of the loop that calls ReadVal 10 times. 
	_getTenValidNums:
		PUSH	OFFSET			enterNumMessage						;here i start pushing all the variables I need for the ReadVal Proc
		PUSH	OFFSET			enteredNum		
		PUSH	lengthString
		PUSH	OFFSET			errorMessage
		PUSH	EAX
		CALL	ReadVal
		ADD		EAX,			4									; I add 4 to EAX to move to the next index in the validNumsArray.
		LOOP	_getTenValidNums
		Call	Crlf

	;this is the colde block that returns the 10 nums the user entered. 
	_outputNumAsString:
				
		MOV		EAX,	OFFSET		validNumsArray
		PUSH	OFFSET	numToString
		PUSH	count
		PUSH	OFFSET	displayNums
		PUSH	EAX
		CALL	WriteVal

	;this block in main is responsible for calculating the sum of the inputted numbers
	;it also calls WriteVal, passes the calculated sum to it, and WriteVal turns this number to a string
	;by invoking mDisplayString macro
	_calcSum:
		CALL	CrLf
		MOV		EAX,	0
		MOV		ECX,	count
		MOV		ESI,	OFFSET		validNumsArray
		_addNumsLoop:	
			ADD		EAX,	[ESI]				; add each value in validNumsArray one at a time. 
			ADD		ESI, 	4					; add 4 bytes to go to next index in the array
			LOOP	_addNumsLoop
		MOV		ESI,	OFFSET		sumHolder
		MOV		[ESI],	EAX

		PUSH	OFFSET		numToString		;EBP+20	
		PUSH	1							;EBP+16
		PUSH	OFFSET		sumMessage		;EBP+12	
		PUSH	ESI							;EBP+8
		CALL	WriteVal

	; this code block takes the sum, and divides it by count.
	;it also calls WriteVal, passes the calculated avg to it, and WriteVal turns this number to a string
	;by invoking mDisplayString macro
	_calcAvg:
		CALL	Crlf
		CDQ
		MOV		EBX,	count				; load count in EBX
		IDIV	EBX							; divide EAX by EBX

		MOV		ESI,	OFFSET		sumHolder
		MOV		[ESI],	EAX
		PUSH	OFFSET		numToString		;EBP+20	
		PUSH	1							;EBP+16
		PUSH	OFFSET		avgMessage		;EBP+12	
		PUSH	ESI							;EBP+8
		CALL	WriteVal
	CALL CrLf
	CALL CrLf
	; good bye message :) 
	mDisplayString	OFFSET goodbyeMessage
			
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)


; ----- ReadVal ----------------------------------------------------------------------------------
; This procedure calls the mReadString to get user inputted string, then turns this string into a number
;	and fills an array with it. It also verifies that the string is valid, that it's only all numbers, and 32 bits max.
; Pre-Conditions: validNumsArray, count, all exist. It also assumes the mReadString macro is written already.
; Post-Conditions: EAX = contains the num, EBX = contains the count which is 10, ECX = contains lengthString, 
;	EDX = contains 10, the divisor, and EDI = contains validNumsArray
; Receives:
;		[EBP+8] = validNumsArray
;		[EBP+12] = errorMessage
;		[EBP+16] = lengthString
;		[EBP+20] = enteredNum
;		[EBP+24] = enterNumPrompt
; Returns: ReadVal does not return anything. All it does is prompt the user to enter in 10 valid nums, validate those nums,
;		and fill validNumsArray.
; ------------------------------------------------------------------------------------------

ReadVal	PROC
		; PUSH all registers needed for this Proc.
		PUSH	EBP
		MOV		EBP,	ESP
		PUSH	EAX
		PUSH	EBX
		PUSH	ECX
		PUSH	EDX
		PUSH	EDI
		PUSH	ESI
		MOV		EDI,	[EBP+8]						; load validNumsArray to EDI

	_getString:
		mGetString [EBP+24], [EBP+20], [EBP+16]   ;24 is prompt, 20 is where num is saved, 16 is length
	
		;EBP+20 now has the string the user inputted, time to turn it into a number
		MOV		ESI,	[EBP+20]					; enteredNum
		MOV		EDX,	10
		MOV		ECX,	[EBP+16]					;lengthString
		MOV		EAX,	0
		MOV		EBX,	0
		MOV		AL,		[ESI]						;Each char in the string. 
		
		CLD
		CMP		AL,		45							; check if first char is -
		JE		_negativeNum
		CMP		AL,		43							; check if first char is +
		JE		_positiveNum
		JMP		_positiveLooper						; if first char is not - or +, it is a postive number, so jump to positiveLooper

		; if num is positive, this is the code block that handles it's conversion
		_positiveNum:
			LODSB									; since + is the first char, go to next char
			SUB		ECX,	1						; decrement ECX since moving to next char

			; this loop goes through each character and turns it to a number.
			_positiveLooper:
				LODSB
				CMP		AL,		48
				JL		_notValidEntry				; if ASCII less than 48, char not valid, so JMP to _notValidEntry code block. 
				CMP		AL,		57					; if ASCII greater than 57, char not valid, so JMP to _notValidEntry code block. 
				JG		_notValidEntry
				SUB		AL,		48					; this line start the algorithm that turns char to num. 
				IMUL	EBX,	10
				ADD		EBX,	EAX	
				JO		_notValidEntry
				LOOP	_positiveLooper

		JMP	_addToArray

		; if num is negative, this is the code block that handles it's conversion
		_negativeNum:
			LODSB
			SUB		ECX,	1					
			; this loop goes through each character and turns it to a number.
			_negativeLooper:
				LODSB
				CMP		AL,		48
				JL		_notValidEntry
				CMP		AL,		57
				JG		_notValidEntry
				SUB		AL,		48
				IMUL	EBX,	10
				SUB		EBX,	EAX
				JO		_notValidEntry					;check overflow register 
				LOOP	_negativeLooper
		
		;if num is valid, jump to the _addToArray code block.
		JMP	_addToArray

		; codeblock to JMP and invoke mDisplayString macro to output the error messae, then to re-prompt user for another string 
		_notValidEntry:
			mDisplayString	[EBP+12]
			JMP		_getString

		; this access the correct spot in the Array to input the number. 
		_addToArray:
			MOV		[EDI],	EBX

	;POP all registers used. 
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET 20
ReadVal	ENDP


; ----- WriteVal ----------------------------------------------------------------------------------
; This procedure goes through the whole validNumsArray, index by index turns the nums contained within into their
;	respective strings. It also invokes mDisplayString macro to display them. 
; Pre-Conditions: validNumsArray, count, displayNums all exist. It also assumes validNumsArray has validated
;	all nums and are stored as nums. 
; Post-Conditions: EAX = contains the num to turn into string, and used as Dividend. ECX = loop to go through the array.
;		ESI = contains validNumsArray, EDI = contains the temporary array containing the ASCII chars to pass to mDisplayStrings
; Receives:
;		[EBP+8] = validNumsArray
;		[EBP+12] = displayNums
;		[EBP+16] = count
;		[EBP+20] = numsToString
; Returns: This returns the nums that were entered in as strings. 
; ------------------------------------------------------------------------------------------

WriteVal PROC
	; PUSH all registers needed for this Proc.
	PUSH	EBP
	MOV		EBP,	ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		ECX,	[EBP+16]		; this is count
	MOV		ESI,	[EBP+8]			; this is validNumsArray

	mDisplayString [EBP+12]			; display the displayNums string

	_outerLooper:
		PUSH	ECX
		MOV		EAX,	[ESI]					; load validsNumsArray to EAX
		MOV		EDI,	[EBP+20]				; load the temporary array that will hold the ASCII values of the string to EDI
		MOV		ECX,	0

		CMP		EAX,	0
		JL		_numIsNegative
		JMP		_innerLoop

		; this code block is if num is negative.
		_numIsNegative:
			SUB		EAX,	EAX					; i subtract the negativ num from itself to get it to 0
			SUB		EAX,	[ESI]				; i subtract again to turn it positive. 
			PUSH	EAX			
			MOV		AL,		45					; here i append the minus sign to EDI so the string printed later would have -
			STOSB								; add it to EDI
			POP		EAX				

		;this loop is responsible for separting out each digit of the number so each digit can be converted to ASCII characters. 
		;each digit is pushed to the stack starting from the 1s place. 
		_innerLoop:
			CDQ
			MOV		EBX,	10					; divide by 10 to separate each digit out, starting from the digit at the 1s place.
			IDIV	EBX
			PUSH	EDX							; EDX holds the remainder of the division
			INC		ECX							; ECX by the end of this loop will 
			CMP		EAX,	0					; this checks if i've reached the beginning of the number, so i can stop looping. 
			JG		_innerLoop

		; this loop is responsible of popping the digits off stack, and converting them to their ASCII counter parts. 
		_numToString:
			CLD
			POP		EAX							; put in EAX
			ADD		AL,	48						; the number + 48 will give their ASCII representation. 
			STOSB								; add to EDI and increment EDI's pointer
			DEC		ECX							; decrement ECX which holds the amount of digits that were pushed to the stack. 
			CMP		ECX, 0
			JG		_numToString

		; This loop is responsible for invoking the mDisplayString macro to display the string representation of the numbers. 
		_endLooper:
			MOV		AL,		32					; this is to add a space 
			STOSB
			MOV		AL,		0					; add a null terminator
			STOSB
			MOV		EDI,	[EBP+20]			; re-point EDI to the start of the string
			mDisplayString	EDI					; invoke macro to display the string
			ADD		ESI,	4					; move to the next number (next index) in validNumsArray
			POP		ECX
			LOOP	_outerLooper

	;POP all registers used. 
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EBP
	RET		16


WriteVal ENDP


END main
