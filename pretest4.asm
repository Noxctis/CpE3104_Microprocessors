; ==========================================
; HEX (1–2 digits) -> Binary (two nibbles) & Octal
; EMU8086 .COM program
; ==========================================

org 100h
    jmp start

; ---------- DATA ----------
prompt      db 'Enter hex (00-FF): $'
nl          db 0Dh,0Ah,'$'
msg_bin     db 0Dh,0Ah,'Binary : $'
msg_oct     db 0Dh,0Ah,'Octal  : $'

value       db 0        ; parsed byte 0..255
digits      db 0        ; 1 or 2 digits entered

; lookup table: 16 nibbles ? 4 ASCII chars each
bin4_tbl    db '0000','0001','0010','0011'
            db '0100','0101','0110','0111'
            db '1000','1001','1010','1011'
            db '1100','1101','1110','1111'

; ---------- CODE ----------
start:
    push cs
    pop  ds

    ; prompt
    mov dx, offset prompt
    mov ah, 9
    int 21h

    ; reset
    mov [digits], 0
    mov [value],  0

    ; ---- read first char ----
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je done_input            ; Enter immediately ? value=0
    call HEX_TO_NIBBLE
    jnc done_input           ; not hex ? quit
    mov bl, al               ; first nibble (0..15)
    mov [digits], 1

    ; ---- read second char (optional) ----
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je one_digit
    call HEX_TO_NIBBLE
    jnc one_digit
    ; two digits: value = (first<<4) | second
    mov bh, bl
    shl bh, 4
    or  bh, al
    mov [value], bh
    mov [digits], 2
    jmp parsed

one_digit:
    ; one digit -> low nibble only
    mov [value], bl

parsed:
done_input:
    ; newline
    mov dx, offset nl
    mov ah, 9
    int 21h

    ; ----- Binary -----
    mov dx, offset msg_bin
    mov ah, 9
    int 21h
    call PRINT_BIN_NIBBLES

    ; ----- Octal -----
    mov dx, offset msg_oct
    mov ah, 9
    int 21h
    call PRINT_OCT

    ; newline + exit
    mov dx, offset nl
    mov ah, 9
    int 21h
    mov ax, 4C00h
    int 21h

; ---------- ROUTINES ----------

; Convert ASCII hex char in AL ? nibble in AL, CF=1 if valid
HEX_TO_NIBBLE:
    cmp al,'0'
    jb  HN_BAD
    cmp al,'9'
    jbe HN_09
    cmp al,'A'
    jb  HN_a_check
    cmp al,'F'
    jbe HN_AF
    cmp al,'a'
    jb  HN_BAD
    cmp al,'f'
    ja  HN_BAD
    sub al,87         ; 'a'(97) ? 10
    stc
    ret
HN_AF:
    sub al,55         ; 'A'(65) ? 10
    stc
    ret
HN_09:
    sub al,'0'
    stc
    ret
HN_a_check:
    cmp al,'a'
    jb  HN_BAD
    cmp al,'f'
    ja  HN_BAD
    sub al,87
    stc
    ret
HN_BAD:
    clc
    ret

; Print binary as two 4-bit groups with a space
; If digits=1: prints "0000" then low nibble
; If digits=2: prints high nibble then low nibble
PRINT_BIN_NIBBLES:
    mov al,[digits]
    cmp al,1
    jne two_digits

    ; ---- one digit ----
    ; print "0000"
    mov si, offset bin4_tbl
    call PRINT_4CHARS
    ; space
    mov dl,' '
    mov ah,2
    int 21h
    ; print low nibble
    mov al,[value]
    and al,0Fh
    mov ah,0
    mov bx,ax
    shl bx,2           ; index = nibble*4
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    ret

two_digits:
    ; ---- two digits ----
    ; high nibble
    mov al,[value]
    mov ah,0
    shr al,4           ; AL = high nibble
    mov bx,ax
    shl bx,2
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    ; space
    mov dl,' '
    mov ah,2
    int 21h
    ; low nibble
    mov al,[value]
    and al,0Fh
    mov ah,0
    mov bx,ax
    shl bx,2
    mov si, offset bin4_tbl
    add si,bx
    call PRINT_4CHARS
    ret

; Print 4 ASCII chars from [SI]
PRINT_4CHARS:
    mov cx,4
P4C_LOOP:
    lodsb
    mov dl,al
    mov ah,2
    int 21h
    loop P4C_LOOP
    ret

; Print value in octal (0..255)
PRINT_OCT:
    mov al,[value]
    xor ah,ah
    mov cx,0
    cmp ax,0
    jne OCT_LOOP
    mov dl,'0'
    mov ah,2
    int 21h
    ret
OCT_LOOP:
    mov bl,8
    div bl
    add ah,'0'
    push ax
    inc cx
    mov ah,0
    cmp al,0
    jne OCT_LOOP
OCT_PRINT:
    cmp cx,0
    je  OCT_DONE
    pop ax
    mov dl,ah
    mov ah,2
    int 21h
    dec cx
    jmp OCT_PRINT
OCT_DONE:
    ret
