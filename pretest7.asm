org 100h

jmp start

; ----------------------------
; Data
; ----------------------------
prompt      db 'Enter Fahrenheit (integer): $'
err_msg     db 13,10,'Invalid input. Try again.',13,10,'$'
res_label   db 13,10,'Celsius: $'
done_msg    db 13,10,13,10,'Press any key to exit...$'

; DOS 0Ah input buffer (keyboard line input)
InMax       db 16          ; maximum chars user may type
InLen       db 0           ; actual chars read (unused here)
InData      db 16 dup(0)   ; the typed data (not zero-terminated)

; Hardcoded Fahrenheit input (change this value as needed)
F_IN        dw 100         ; e.g., 100F -> 37C

; ----------------------------
; Code
; ----------------------------
start:
    ; DS = CS (so our data prints correctly in .COM)
    push cs
    pop  ds

; Direct conversion using hardcoded Fahrenheit value
do_convert:
    ; Show prompt and the hardcoded Fahrenheit value
    mov dx, offset prompt
    mov ah, 09h
    int 21h
    mov ax, [F_IN]
    call print_int

    ; Reload AX with Fahrenheit for conversion
    mov ax, [F_IN]      ; AX = Fahrenheit (hardcoded)
    
    ; Celsius = (F - 32) * 5 / 9  (signed, trunc toward 0)
    sub ax, 32
    cwd                 ; sign-extend into DX
    mov bx, 5
    imul bx             ; DX:AX = (F-32) * 5
    mov bx, 9
    idiv bx             ; AX = Celsius

    ; print label + result (preserve AX across DOS 09h)
    push ax                   ; save Celsius
    mov dx, offset res_label
    mov ah, 09h
    int 21h
    pop  ax                   ; restore Celsius
    call print_int

    ; finish message
    mov dx, offset done_msg
    mov ah, 09h
    int 21h

    ; wait for a key, then exit
    mov ah, 08h
    int 21h
    mov ax, 4C00h
    int 21h

; ---------------------------------------------------------
; parse_int
;   Parses a signed decimal integer from DOS 0Ah buffer.
;   Uses InLen to limit parsing (more robust than scanning for 0Dh).
;   Allows leading/trailing spaces, optional '+'/'-'.
;   Returns: AX = value, CF = 0 on success, CF = 1 on error.
;   Destroys: AX,BX,CX,DX,SI,DI (but restores via pushes).
; ---------------------------------------------------------
parse_int:
    push bx
    push cx
    push dx
    push si
    push di

    lea si, InData           ; SI -> first typed char
    xor cx, cx
    mov cl, [InLen]          ; CX = number of chars typed (no CR)
    jcxz pi_err              ; empty line

; skip leading spaces (bounded by CX)
pi_skip_lead:
    cmp byte ptr [si], ' '
    jne pi_sign
    inc si
    loop pi_skip_lead        ; dec cx; jnz
    jmp pi_err               ; all spaces -> error

; optional sign (if chars remain)
pi_sign:
    xor dl, dl               ; DL = 0 => positive, 1 => negative
    jcxz pi_err              ; nothing left
    cmp byte ptr [si], '+'
    jne pi_chk_minus
    inc si
    dec cx
    jmp pi_need_digit

pi_chk_minus:
    cmp byte ptr [si], '-'
    jne pi_need_digit
    mov dl, 1
    inc si
    dec cx

; must start with a digit
pi_need_digit:
    jcxz pi_err
    mov bl, [si]
    cmp bl, '0'
    jb  pi_err
    cmp bl, '9'
    ja  pi_err

    xor ax, ax               ; AX = result

; read digits (bounded by CX)
pi_digits:
    jcxz pi_after_digits
    mov bl, [si]
    cmp bl, '0'
    jb  pi_after_digits
    cmp bl, '9'
    ja  pi_after_digits

    ; AX = AX*10 + digit
    mov di, ax
    shl di, 1                ; *2
    shl di, 1                ; *4
    shl di, 1                ; *8
    shl ax, 1                ; *2
    add ax, di               ; *10 total

    sub bl, '0'
    xor bh, bh
    add ax, bx

    inc si
    dec cx
    jmp pi_digits

; allow trailing spaces (consume remaining spaces)
pi_after_digits:
    jcxz pi_apply_sign
pi_trim_trail:
    cmp byte ptr [si], ' '
    jne pi_check_leftover
    inc si
    loop pi_trim_trail

pi_check_leftover:
    jcxz pi_apply_sign       ; ok if nothing remains
    jmp pi_err               ; leftover non-space chars -> error

; apply sign from DL
pi_apply_sign:
    test dl, dl
    jz   pi_ok
    neg  ax

pi_ok:
    clc
    jmp  pi_exit

pi_err:
    stc

pi_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

; ---------------------------------------------------------
; print_int
;   Prints signed AX in decimal using DOS int 21h/AH=02h.
;   Destroys AX,BX,CX,DX.
; ---------------------------------------------------------
print_int:
    push bx
    push cx
    push dx

    ; sign handling
    cmp ax, 0
    jge pi_abs
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

pi_abs:
    ; zero special-case
    cmp ax, 0
    jne pi_conv
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp pi_done

; push digits (remainder method)
pi_conv:
    xor cx, cx
    mov bx, 10
pi_div:
    xor dx, dx
    div bx              ; AX = AX/10 (unsigned OK, AX>=0 here), DX = rem
    push dx
    inc cx
    test ax, ax
    jnz pi_div

; pop and print digits
pi_out:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pi_out

pi_done:
    pop dx
    pop cx
    pop bx
    ret
