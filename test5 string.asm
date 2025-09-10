org 100h
jmp start

attr       db 09Eh

string     db 'hello',0
strlen     equ ($ - string - 1)   ; number of visible chars (exclude 0)

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

    ; Row: "The strong string is: " + string
    call POS_FROM_ROWCOL
    lea  si, hdr1
    call PRINT_Z
    lea  si, string
    call PRINT_Z

    ; next row: "Output:"
    inc [ROW]
    call POS_FROM_ROWCOL
    lea  si, hdr2
    call PRINT_Z

    ; next row: original + all LEFT rotations
    inc [ROW]
    mov  cx, strlen+1          ; print original + all left-rotations

next_line:
    call POS_FROM_ROWCOL
    lea  si, string
    call PRINT_Z

    ; ---- rotate string LEFT by 1 (in-place) ----
    lea  si, string
    mov  al, [si]              ; save first char
    mov  bx, si
    mov  dx, strlen
    dec  dx                    ; DX = strlen-1 (moves to perform)
    jz   rot_done_left         ; length 1 → no-op

rot_shift_left:
    mov  ah, [bx+1]            ; shift each char one left
    mov  [bx], ah
    inc  bx
    dec  dx
    jnz  rot_shift_left

    mov  [si+strlen-1], al     ; put original first char at end
rot_done_left:

    inc [ROW]            ; next row
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

; POS_FROM_ROWCOL: DI = ((ROW*80)+COL)*2
; input: [ROW], [COL]
POS_FROM_ROWCOL:
    mov  al, [ROW]             ; AL = row
    xor  ah, ah
    mov  bl, 80
    mul  bl                    ; AX = row*80
    xor  dx, dx
    mov  dl, [COL]             ; DX = col
    add  ax, dx                ; AX = row*80 + col
    shl  ax, 1                 ; *2 bytes per cell
    mov  di, ax
    ret