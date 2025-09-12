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

; ----------------------------
; Code
; ----------------------------
start:
    ; DS = CS (so our data prints correctly in .COM)
    push cs
    pop  ds

input_loop:
    ; show prompt
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    ; read a line into the buffer (0Ah)
    mov dx, offset InMax
    mov ah, 0Ah
    int 21h

    ; parse signed integer from InData -> AX, CF=1 on error
    call parse_int
    jc   input_bad

    ; AX has Fahrenheit
    ; Celsius = (F - 32) * 5 / 9  (signed, trunc toward 0)
    sub ax, 32
    cwd                 ; sign-extend into DX
    mov bx, 5
    imul bx             ; DX:AX = (F-32) * 5
    mov bx, 9
    idiv bx             ; AX = Celsius

    ; print label + result
    mov dx, offset res_label
    mov ah, 09h
    int 21h
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

input_bad:
    mov dx, offset err_msg
    mov ah, 09h
    int 21h
    jmp input_loop

; ---------------------------------------------------------
; parse_int
;   Parses a signed decimal integer from DOS 0Ah buffer.
;   Ignores InLen; reads InData until 0Dh (carriage return).
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

    lea si, InData      ; SI points to first typed char

; skip leading spaces
pi_skip_lead:
    mov al, [si]
    cmp al, 0Dh
    je  pi_err          ; blank line ? error
    cmp al, ' '
    jne pi_sign
    inc si
    jmp pi_skip_lead

; optional sign
pi_sign:
    xor dl, dl          ; DL = 0 => positive, 1 => negative
    mov al, [si]
    cmp al, '+'
    jne pi_chk_minus
    inc si
    jmp pi_need_digit

pi_chk_minus:
    cmp al, '-'
    jne pi_need_digit
    mov dl, 1
    inc si

; must start with a digit
pi_need_digit:
    mov al, [si]
    cmp al, '0'
    jb  pi_err
    cmp al, '9'
    ja  pi_err

    xor ax, ax          ; AX = result

; read digits
pi_digits:
    mov al, [si]
    cmp al, '0'
    jb  pi_after_digits
    cmp al, '9'
    ja  pi_after_digits

    ; AX = AX*10 + digit (8086-safe multiply by 10)
    mov di, ax
    shl di, 1           ; *2
    shl di, 1           ; *4
    shl di, 1           ; *8
    shl ax, 1           ; *2
    add ax, di          ; *10 total

    mov bl, [si]
    sub bl, '0'
    xor bh, bh
    add ax, bx

    inc si
    jmp pi_digits

; allow trailing spaces, then require CR
pi_after_digits:
pi_trim_trail:
    mov al, [si]
    cmp al, 0Dh
    je  pi_apply_sign
    cmp al, ' '
    jne pi_err
    inc si
    jmp pi_trim_trail

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
