org 100h

start:
    ; ensure DS = CS (safe for .COM before using data)
    push cs
    pop  ds

; --- Display prompt using BIOS teletype ---
    lea si, prompt
print_prompt:
    mov al, [si]
    cmp al, 0
    je  done_prompt
    mov ah, 0Eh          ; teletype output
    xor bh, bh           ; page 0
    mov bl, 07h          ; light gray on black
    int 10h
    inc si
    jmp print_prompt
done_prompt:

; --- Read and echo initials (BIOS keyboard) ---
    call read_and_echo
    mov  [first],  al

    call read_and_echo
    mov  [middle], al

    call read_and_echo
    mov  [last],   al

; --- Display initials vertically ---
    call new_line
    mov  al, [first]
    call print_char
    call new_line
    mov  al, [middle]
    call print_char
    call new_line
    mov  al, [last]
    call print_char
    call new_line

; --- Exit cleanly ---
    mov ax, 4C00h
    int 21h

; ===== Subroutines =====

; Read a key (BIOS) and echo it using teletype
read_and_echo:
    mov ah, 00h          ; BIOS wait for key
    int 16h              ; AL = char
    ; echo the same AL
    call print_char
    ret

; Print AL using BIOS teletype (page 0, attr 07h)
print_char:
    mov ah, 0Eh
    xor bh, bh
    mov bl, 07h
    int 10h
    ret

; Print CRLF
new_line:
    mov al, 13           ; CR
    call print_char
    mov al, 10           ; LF
    call print_char
    ret

; ===== Data =====
prompt db 'Enter your initials (first, middle, last): ', 0
first  db ?
middle db ?
last   db ?
