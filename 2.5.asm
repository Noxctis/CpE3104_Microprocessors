org 100h

start:
    ; tiny-model: DS = CS so data labels work
    push cs
    pop  ds

    ; 80x25 color text (mode 3)
    mov  ax, 0003h
    int  10h

    ; ---------- prompt & read ----------
    mov  dx, offset msg_prompt   ; "$"-terminated prompt
    mov  ah, 09h                 ; DOS print string
    int  21h

    mov  dx, offset inbuf        ; DS:DX -> [max][len][data...]
    mov  ah, 0Ah                 ; DOS buffered line input
    int  21h                     ; inbuf+1 = length (no CR), inbuf+2.. data

    ; >>> Clear the screen *after* input so the prompt disappears <<<
    mov  ah, 06h                 ; BIOS scroll/clear
    mov  al, 00h                 ; 0 = clear/fill
    mov  bh, 07h                 ; fill with attr 07h (white on black)
    mov  cx, 0000h               ; top-left  (row 0, col 0)
    mov  dx, 184Fh               ; bot-right (row 24, col 79)
    int  10h

    ; ---------- set up for BIOS write-string ----------
    lea  si, [inbuf+2]           ; SI -> first user char
    mov  ax, ds
    mov  es, ax                  ; ES = DS
    mov  bp, si                  ; ES:BP -> string data

    mov  bl, 06h                 ; attribute: brown on black (fg=6, bg=0)
    xor  bh, bh                  ; page = 0

    ; we'll keep the row in DH directly (8-bit counter)
    xor  dh, dh                  ; DH = 0 (row 0)

row_loop:
    mov  dl, 39                  ; DL = column 39 (assignment's "center")

    ; CX must be the length each time (AH=13h uses it)
    mov  cl, [inbuf+1]
    xor  ch, ch

    ; BIOS Write String:
    ; AH=13h, AL=01 update cursor, BH=page, BL=attr,
    ; CX=len, DH=row, DL=col, ES:BP=string
    mov  ah, 13h
    mov  al, 01h
    int  10h

    inc  dh                      ; next row
    cmp  dh, 25                  ; rows 0..24 (25 total)
    jb   row_loop

    ; hold screen
    mov  dx, offset done_msg
    mov  ah, 09h
    int  21h
    mov  ah, 00h
    int  16h

    ; exit to DOS
    mov  ax, 4C00h
    int  21h

; ---------- data ----------
msg_prompt db 'Type exactly: This will be displayed on the screen.',13,10
           db 'Press Enter when done: $'
done_msg   db 13,10,'(Press any key to exit.)$'

BUFMAX     equ 80
inbuf      db BUFMAX          ; [0] max (not counting CR)
           db 0               ; [1] actual length entered (no CR)
           db BUFMAX dup(?)   ; [2..] characters (CR stored after them by DOS)
