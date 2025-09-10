org 100h
jmp start

attr       db 09Eh

string     db 'hello'
strlen     equ $ - string
str0       db 0                    ; zero terminator for PRINT_Z

hdr1       db 'The strong string is: ',0
hdr2       db 'Output:',0

START_ROW  db 12
START_COL  db 30

ROW        db 0
COL        db 0

start:
    push cs
    pop  ds
    mov  ax, 0B800h
    mov  es, ax
    cld

    ; load starting row/col
    mov  al, [START_ROW]
    mov  [ROW], al
    mov  al, [START_COL]
    mov  [COL], al

    ; ---- Row: "The strong string is: " + string ----
    call POS_FROM_ROWCOL
    lea  si, hdr1
    call PRINT_Z
    lea  si, string
    call PRINT_Z

    ; next row
    inc [ROW]

    ; ---- Row: "Output:" ----
    call POS_FROM_ROWCOL
    lea  si, hdr2
    call PRINT_Z

    ; next row
    inc [ROW]

    ; ---- Rows: original + all right-rotations ----
    mov  cx, strlen+1

next_line:
    call POS_FROM_ROWCOL
    lea  si, string
    call PRINT_Z

    ; rotate string right by 1 (in place)
    lea  si, string
    mov  bx, si
    add  bx, strlen-1
    mov  al, [bx]           ; save last char
rshift:
    cmp  bx, si
    je   rot_done
    mov  dl, [bx-1]
    mov  [bx], dl
    dec  bx
    jmp  rshift
rot_done:
    mov  [si], al

    inc [ROW]         ; move to next row for next line
    loop next_line

hang: jmp hang

; ---------------- helpers ----------------

; PRINT_Z: print zero-terminated string at ES:DI using [attr]
PRINT_Z:
    mov  ah, [attr]
pz_loop:
    lodsb
    test al, al
    jz   pz_done
    stosw
    jmp  pz_loop
pz_done:
    ret

; POS_FROM_ROWCOL: sets DI from current ROW/COL
;   DI = ((ROW*80)+COL)*2
POS_FROM_ROWCOL:
    mov  al, [ROW]          ; AL=row
    mov  dl, [COL]          ; DL=col
    mov  ah, 0
    mov  bl, 80
    mul  bl                 ; AX = row*80
    add  ax, dx             ; + col
    shl  ax, 1              ; * 2 bytes per cell
    mov  di, ax
    ret
