# computer_architechture_assembly_language
Computer Architechture and Aseembly Languae Portfolio Project

Implemented and tested two macros for string processing. 

mGetString:  Displays a prompt (input parameter, by reference), then gets the user’s keyboard input into a memory location (output parameter, by reference). 

mDisplayString:  Prints the string which is stored in a specified memory location (input parameter, by reference).

Implemented and tested two procedures for signed integers which use string primitive instructions.

ReadVal: 
Invokes the mGetString macro to get user input in the form of a string of digits.
Converts (using string primitives) the string of ASCII digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
This numver is stored in a memory variable (output parameter, by reference). 

WriteVal: 
Converts a numeric SDWORD value (input parameter, by value) to a string of ASCII digits
Invokes the mDisplayString macro to print the ASCII representation of the SDWORD value to the output.
Writes a test program (in main) which uses the ReadVal and WriteVal procedures above to:
Get 10 valid integers from the user. ReadVal is called within the loop in main.

Displays the integers, their sum, and their average (truncated to its integer part).
ReadVal is called within the loop in main. 

User’s numeric input is validated in this way:
1. Reads the user's input as a string and converts the string to numeric form.
2. If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message is displayed and the number is discarded.
3. If the user enters nothing (empty input), an error is display and user is re-prompted. ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.

Conversion routines uses the LODSB and/or STOSB operators for dealing with strings. All procedure parameters are passed on the runtime stack using the STDCall calling convention. Strings are also passed by reference.

Prompts, identifying strings, and other memory locations are passed by address to the macros. Used registers must be saved and restored by the called procedures and macros.

Procedures (except main) do not reference data segment variables by name. The program uses Register Indirect addressing for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.

Notes:
1. This program accepts both positive and negative values.
2. When displaying the average, only the integer part is displayed.

