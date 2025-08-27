ORG 100h

; --- Setup video memory segment ---
MOV AX, 0B800h
MOV ES, AX

; --- Display prompt ---
LEA SI, prompt
MOV DI, 0           ; Start at top-left corner
print_prompt:
    MOV AL, [SI]
    CMP AL, 0
    JE done_prompt
    MOV AH, 07h         ; Attribute: light gray on black
    MOV [ES:DI], AL     ; Write character
    MOV [ES:DI+1], AH   ; Write attribute
    ADD DI, 2           ; Move to next screen cell
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

; --- Display initials vertically in first column ---
MOV CX, 0              ; Line counter (row index)
MOV AL, first
CALL print_left_column

MOV AL, middle
CALL print_left_column

MOV AL, last
CALL print_left_column

RET

; --- Subroutine: Read and echo a character ---
read_and_echo:
    MOV AH, 00h
    INT 16h
    ; Echo to screen
    MOV AH, 07h
    MOV BX, DI         ; Save DI
    MOV DI, 1600       ; Echo at bottom of screen (row 25)
    MOV [ES:DI], AL
    MOV [ES:DI+1], AH
    MOV DI, BX         ; Restore DI
    RET

; --- Subroutine: Print character in left column ---
print_left_column:
    MOV AH, 07h
    MOV DI, CX
    SHL DI, 1          ; Multiply by 2 (each cell = 2 bytes)
    SHL DI, 5          ; Multiply by 32 (2 * 16 = 32)
    SHL DI, 1          ; Multiply by 2 again (32 * 2 = 64)
    ; Now DI = row * 160 (80 cols * 2 bytes)
    MOV [ES:DI], AL
    MOV [ES:DI+1], AH
    INC CX             ; Next row
    RET

; --- Data section ---
prompt DB 'Enter your initials (first, middle, last): ', 0
first DB ?
middle DB ?
last DB ?
