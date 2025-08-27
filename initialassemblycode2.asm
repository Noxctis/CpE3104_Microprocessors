ORG 100h

; --- Display prompt using BIOS ---
LEA SI, prompt
print_prompt:
    MOV AL, [SI]
    CMP AL, 0
    JE done_prompt
    MOV AH, 0Eh       ; BIOS teletype output
    MOV BH, 00h       ; Page number
    MOV BL, 07h       ; Text attribute (light gray)
    INT 10h
    INC SI
    JMP print_prompt
done_prompt:

; --- Read and echo initials ---
CALL read_and_echo
MOV first, AL

CALL read_and_echo
MOV middle, AL

CALL read_and_echo
MOV last, AL

; --- Display initials vertically ---
CALL new_line
MOV AL, first
CALL print_char
CALL new_line
MOV AL, middle
CALL print_char
CALL new_line
MOV AL, last
CALL print_char
CALL new_line

RET

; --- Subroutine: Read and echo a character ---
read_and_echo:
    MOV AH, 00h       ; BIOS: Wait for key press
    INT 16h           ; AL = character
    CALL print_char   ; Echo the character
    RET

; --- Subroutine: Print a character to screen ---
print_char:
    MOV AH, 0Eh       ; BIOS: Teletype output
    MOV BH, 00h
    MOV BL, 07h
    INT 10h
    RET

; --- Subroutine: Print newline ---
new_line:
    MOV AL, 13        ; Carriage return
    CALL print_char
    MOV AL, 10        ; Line feed
    CALL print_char
    RET

; --- Data section ---
prompt DB 'Enter your initials (first, middle, last): ', 0
first DB ?
middle DB ?
last DB ?
