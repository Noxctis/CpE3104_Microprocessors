; ==========================================
; Count vowels & consonants (EMU8086 .COM)
; org 100h, data on top, jmp start
; ==========================================

org 100h
        jmp start

; ---------- DATA ----------
prompt      db 'Input string [max. 20]: $'
; DOS 0Ah input buffer: [0]=max, [1]=len, [2..]=data, [2+len]=CR
inbuf       db 20
inlen       db 0
intext      db 20 dup(0)

s_chars     db ' - chars inputted',0Dh,0Ah,'$'
s_a         db ' - a''s',0Dh,0Ah,'$'
s_e         db ' - e''s',0Dh,0Ah,'$'
s_i         db ' - i''s',0Dh,0Ah,'$'
s_o         db ' - o''s',0Dh,0Ah,'$'
s_u         db ' - u''s',0Dh,0Ah,'$'
s_vow       db ' - total vowels',0Dh,0Ah,'$'
s_con       db ' - total consonants',0Dh,0Ah,'$'
newline     db 0Dh,0Ah,'$'

cnt_len     dw 0
cnt_a       dw 0
cnt_e       dw 0
cnt_i       dw 0
cnt_o       dw 0
cnt_u       dw 0
cnt_v       dw 0
cnt_c       dw 0

; ---------- CODE ----------
start:
        push cs
        pop  ds

        mov  dx, offset prompt
        mov  ah, 9
        int  21h

        mov  dx, offset inbuf
        mov  ah, 0Ah
        int  21h

        ; clear counters
        xor  ax, ax
        mov  cnt_len, ax
        mov  cnt_a,   ax
        mov  cnt_e,   ax
        mov  cnt_i,   ax
        mov  cnt_o,   ax
        mov  cnt_u,   ax
        mov  cnt_v,   ax
        mov  cnt_c,   ax

        ; total characters
        mov  al, inlen
        cbw
        mov  cnt_len, ax

        ; scan characters
        mov  si, offset intext
        mov  cl, inlen
        xor  ch, ch

scan_loop:
        cmp  cx, 0
        je   show_results

        lodsb                        ; AL = char

        ; to uppercase if 'a'..'z'
        cmp  al, 'a'
        jb   chk_letter
        cmp  al, 'z'
        ja   chk_letter
        sub  al, 20h                 ; 'a'..'z' -> 'A'..'Z'

chk_letter:
        ; only letters A..Z count
        cmp  al, 'A'
        jb   next_char
        cmp  al, 'Z'
        ja   next_char

        ; vowel?
        cmp  al, 'A'     ; A
        je   is_A
        cmp  al, 'E'     ; E
        je   is_E
        cmp  al, 'I'     ; I
        je   is_I
        cmp  al, 'O'     ; O
        je   is_O
        cmp  al, 'U'     ; U
        je   is_U

        inc  word ptr cnt_c
        jmp  next_char

is_A:   inc  word ptr cnt_a
        inc  word ptr cnt_v
        jmp  next_char
is_E:   inc  word ptr cnt_e
        inc  word ptr cnt_v
        jmp  next_char
is_I:   inc  word ptr cnt_i
        inc  word ptr cnt_v
        jmp  next_char
is_O:   inc  word ptr cnt_o
        inc  word ptr cnt_v
        jmp  next_char
is_U:   inc  word ptr cnt_u
        inc  word ptr cnt_v

next_char:
        dec  cx
        jmp  scan_loop

; ---------- OUTPUT ----------
show_results:
        ; print a blank line before results
        mov  dx, offset newline
        mov  ah, 9
        int  21h
        
        mov  ax, cnt_len
        call print_2d
        mov  ah, 9
        mov  dx, offset s_chars
        int  21h

        mov  ax, cnt_a
        call print_2d
        mov  ah, 9
        mov  dx, offset s_a
        int  21h

        mov  ax, cnt_e
        call print_2d
        mov  ah, 9
        mov  dx, offset s_e
        int  21h

        mov  ax, cnt_i
        call print_2d
        mov  ah, 9
        mov  dx, offset s_i
        int  21h

        mov  ax, cnt_o
        call print_2d
        mov  ah, 9
        mov  dx, offset s_o
        int  21h

        mov  ax, cnt_u
        call print_2d
        mov  ah, 9
        mov  dx, offset s_u
        int  21h

        mov  ax, cnt_v
        call print_2d
        mov  ah, 9
        mov  dx, offset s_vow
        int  21h

        mov  ax, cnt_c
        call print_2d
        mov  ah, 9
        mov  dx, offset s_con
        int  21h

        mov  ax, 4C00h
        int  21h

; ---------- routines ----------
; print_2d: print AX as two decimal digits (00..99)
; FIX: preserve DX (remainder) while printing tens.
print_2d:
        cmp  ax, 99
        jbe  short p2_go
        mov  ax, 99
p2_go:
        xor  dx, dx
        mov  bx, 10
        div  bx            ; AX=quotient (tens), DX=remainder (ones)
        ; tens
        push dx            ; save ones
        mov  dl, al
        add  dl, '0'
        mov  ah, 2
        int  21h
        ; ones
        pop  dx            ; restore remainder
        mov  dl, dl        ; DL already = ones (0..9)
        add  dl, '0'
        mov  ah, 2
        int  21h
        ret
