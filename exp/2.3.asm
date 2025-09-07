; ==========================================
; Activity #2 — per-char input until '$'
; then display N times with one delay loop
; Emu8086 / .COM
; ==========================================
org 100h
jmp start

; -------------------------
; Data
; -------------------------
msgIntro db 'Enter your COMPLETE NAME, PROGRAM, and YEAR LEVEL.',13,10
         db 'Type continuously. Press $ to finish.',13,10,'$'
msgTimes db 13,10,'How many times to display? $'
crlf     db 13,10,'$'

; main text buffer for the whole set
BUFMAX   equ 200
len      db 0
buf      db BUFMAX dup(?)

; count input buffer (AH=0Ah line input)
CNTMAX   equ 5                   ; up to 5 digits
cntbuf   db CNTMAX               ; [0] max count of chars user can type
         db 0                    ; [1] actual count typed (no CR)
         db CNTMAX dup(?)        ; [2..] data; DOS places CR at data[len]

; -------------------------
; Code
; -------------------------
start:
    ; .COM setup: DS = CS
    push cs
    pop  ds

    ; --- Prompt for the whole set ---
    mov  dx, offset msgIntro
    mov  ah, 09h
    int  21h

    ; prepare buffer: DI = write pointer, len = 0
    mov  di, offset buf
    mov  byte ptr [len], 0

; ===== Per-character input until '$' =====
read_loop:
    mov  ah, 01h                 ; read char (echoed)
    int  21h                     ; AL = char

    cmp  al, '$'                 ; finish input?
    je   input_done

    cmp  al, 0Dh                 ; Enter? store CR+LF (if room)
    jne  store_char

    ; store CR
    mov  bl, [len]
    cmp  bl, BUFMAX
    jae  read_loop
    mov  [di], al
    inc  di
    inc  byte ptr [len]
    ; store LF if room
    mov  bl, [len]
    cmp  bl, BUFMAX
    jae  read_loop
    mov  byte ptr [di], 0Ah
    inc  di
    inc  byte ptr [len]
    jmp  read_loop

store_char:
    mov  bl, [len]               ; normal char: store if room
    cmp  bl, BUFMAX
    jae  read_loop
    mov  [di], al
    inc  di
    inc  byte ptr [len]
    jmp  read_loop

input_done:
    ; CRLF after finishing input
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

; ===== Ask for N (how many times) =====
    mov  dx, offset msgTimes
    mov  ah, 09h
    int  21h

    ; read number line with AH=0Ah (user types digits then Enter)
    mov  dx, offset cntbuf
    mov  ah, 0Ah
    int  21h

    ; immediate CRLF after pressing Enter
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

    ; -------- Parse decimal cntbuf into AX (accumulator) --------
    xor  ax, ax                  ; AX = 0
    mov  si, offset cntbuf
    mov  cl, [si+1]              ; CL = number of typed chars (no CR)
    xor  ch, ch
    lea  si, [si+2]              ; SI -> first data char

parse_loop:
    jcxz parsed
    mov  bl, [si]                ; BL = next char
    inc  si
    dec  cl
    cmp  bl, '0'
    jb   parse_loop              ; ignore non-digit
    cmp  bl, '9'
    ja   parse_loop
    sub  bl, '0'                 ; BL = digit (0..9)

    ; AX = AX*10 + BL  (use shifts: *10 = *8 + *2)
    mov  dx, ax                  ; DX = old AX
    shl  ax, 3                   ; AX = old * 8
    shl  dx, 1                   ; DX = old * 2
    add  ax, dx                  ; AX = old * 10
    xor  bh, bh
    add  ax, bx                  ; add digit (BL)
    jmp  parse_loop

parsed:
    mov  si, ax                  ; SI = repeat count
    test si, si
    jz   done

; ===== Display SI times (CX only used for lengths) =====
display_again:
    push si                      ; protect counter across DOS calls

    ; write exactly [len] bytes from buf
    mov  bx, 1                   ; handle 1 = STDOUT
    mov  ah, 40h
    mov  dx, offset buf
    mov  cl, [len]
    xor  ch, ch
    int  21h

    ; CRLF to separate runs
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

    pop  si                      ; restore counter

    ; ONE short delay: loop CX = 30
    call delay_30

    dec  si
    jnz  display_again

done:
    mov  ax, 4C00h
    int  21h

; ------------------------------------------
; delay_30: one simple loop of 30 iterations
; ------------------------------------------
delay_30:
    push cx
    mov  cx, 30
d30_loop:
    loop d30_loop
    pop  cx
    ret
