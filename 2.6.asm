org 100h                          ; .COM programs start at offset 0100h

start:
    push cs                       ; DS must equal CS in tiny (.COM) model
    pop  ds
    mov  ax, 0003h                ; BIOS video mode 03h = 80x25 color text
    int  10h
    jmp  MAIN_PANEL               ; go draw the main menu

; -------------------------------------------------
MAIN_PANEL:
    call CLEAR_SCREEN             ; clear screen (blue bg / yellow fg)
    call INIT_MOUSE               ; initialize + show mouse pointer
    call DISP_MESS                ; print all menu lines
    jmp  INPUT_LOOP               ; wait for keyboard or mouse input

; -------------------------------------------------
INPUT_LOOP:
    mov  ah, 01h                  ; BIOS keyboard: is a key ready?
    int  16h
    jz   CHECK_MOUSE              ; ZF=1 ? none; go check mouse instead

    mov  ah, 00h                  ; BIOS keyboard: read key (AL=ASCII or 00h, AH=scan)
    int  16h

    cmp  al, 00h                  ; is it an extended key? (AL==00h)
    jne  KB_ASCII                 ; no ? handle ASCII keys

    ; ----- extended keys here (AL==00h) -----
    cmp  ah, 3Bh                  ; scan 3Bh = F1 (Emu8086 IDE may swallow it)
    je   CHECKERED                ; if it arrives, go show checkered pattern
    cmp  ah, 3Ch                  ; scan 3Ch = F2 (fallback function key)
    je   CHECKERED
    jmp  INPUT_LOOP               ; other extended ? ignore & re-poll

KB_ASCII:
    cmp  al, '1'                  ; '1' ? Horizontal stripes
    jne  KB_CHK_2
    mov  dl, '1'                  ; echo chosen key after "ENTER CHOICE: "
    mov  ah, 02h
    int  21h
    jmp  HORIZONTAL

KB_CHK_2:
    cmp  al, '2'                  ; '2' ? Vertical stripes
    jne  KB_CHK_Q
    mov  dl, '2'
    mov  ah, 02h
    int  21h
    jmp  VERTICAL

KB_CHK_Q:
    cmp  al, 'q'                  ; 'q' ? Quit
    je   QUIT
    cmp  al, 'Q'                  ; 'Q' ? Quit
    je   QUIT

    ; ASCII fallbacks for checkered (when F1 is eaten by IDE)
    cmp  al, '3'                  ; allow '3'
    je   CHECKERED
    cmp  al, 'c'                  ; allow 'c'
    je   CHECKERED
    cmp  al, 'C'                  ; allow 'C'
    je   CHECKERED

    jmp  INPUT_LOOP               ; anything else ? ignore and re-poll

; -------------------------------------------------
CHECK_MOUSE:
    mov  ax, 0003h                ; INT 33h fn=03h: get mouse pos/buttons
    int  33h                      ; returns BX=buttons, CX=X px, DX=Y px
    test bx, 0001b                ; left button down?
    jz   INPUT_LOOP               ; no ? loop back to poll again

    mov  ax, cx                   ; convert pixel X to text column (�8)
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1                    ; AX = column 0..79
    mov  si, ax                   ; SI = column

    mov  ax, dx                   ; convert pixel Y to text row (�8)
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1                    ; AX = row 0..24
    mov  di, ax                   ; DI = row

    ; Hit-test exact rows where we printed menu items:
    ; row 6: "1 - HORIZONTAL STRIPES"
    ; row 7: "2 - VERTICAL STRIPES"
    ; row 8: "F1 - CHECKERED PATTERN"
    ; row 10: "Q - QUIT"
    cmp  di, 6
    je   HORIZONTAL
    cmp  di, 7
    je   VERTICAL
    cmp  di, 8
    je   CHECKERED
    cmp  di, 10
    je   QUIT
    jmp  INPUT_LOOP               ; click elsewhere ? ignore

; -------------------------------------------------
CLEAR_SCREEN:
    mov  ah, 06h                  ; BIOS scroll/clear window
    mov  al, 00h                  ; AL=0 ? clear & fill whole region
    mov  bh, 1Eh                  ; attribute: blue bg (1), bright yellow fg (E)
    mov  cx, 0000h                ; top-left:  row=0, col=0
    mov  dx, 184Fh                ; bottom-right: row=24, col=79
    int  10h

    mov  ah, 02h                  ; BIOS: set cursor position
    xor  bx, bx                   ; BH=page 0
    xor  dx, dx                   ; row=0, col=0
    int  10h
    ret

; -------------------------------------------------
INIT_MOUSE:
    mov  ax, 0001h                ; INT 33h fn=01h: reset & init mouse
    int  33h
    mov  ax, 0002h                ; INT 33h fn=02h: show mouse pointer
    int  33h
    ret

; -------------------------------------------------
DISP_MESS:
    ; "MENU" at (3,25)
    mov  ah, 02h                  ; set cursor
    mov  bh, 0
    mov  dh, 03h
    mov  dl, 25h
    int  10h
    mov  ah, 09h                  ; DOS print $-terminated string
    mov  dx, OFFSET MENU_TEXT
    int  21h

    ; "1 - HORIZONTAL STRIPES" at (6,0)
    mov  ah, 02h
    mov  dh, 06h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET FIRST_CHOICE
    int  21h

    ; "2 - VERTICAL STRIPES" at (7,0)
    mov  ah, 02h
    mov  dh, 07h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET SECOND_CHOICE
    int  21h

    ; "F1 - CHECKERED PATTERN" at (8,0)  (F2 / C / c / 3 also accepted)
    mov  ah, 02h
    mov  dh, 08h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET THIRD_CHOICE
    int  21h

    ; "Q - QUIT" at (10,0)
    mov  ah, 02h
    mov  dh, 10
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET QUIT_MSG
    int  21h

    ; "ENTER CHOICE: " at (14,15). Cursor stays right after this text.
    mov  ah, 02h
    mov  dh, 14
    mov  dl, 15h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET CHOICE_MSG
    int  21h
    ret

; -------------------------------------------------
; HORIZONTAL STRIPES (4 bands): black, magenta, brown, blue
; -------------------------------------------------
HORIZONTAL:
    call CLEAR_SCREEN            ; fresh background

    mov  ah, 06h                 ; band 0: rows 0..5, cols 0..79
    xor  al, al
    mov  bh, 0Fh                 ; white on black
    mov  cx, 0000h               ; (0,0)
    mov  dx, 054Fh               ; (5,79)
    int  10h

    mov  ah, 06h                 ; band 1: rows 6..11
    xor  al, al
    mov  bh, 5Fh                 ; white on magenta
    mov  cx, 0600h               ; (6,0)
    mov  dx, 0B4Fh               ; (11,79)
    int  10h

    mov  ah, 06h                 ; band 2: rows 12..17
    xor  al, al
    mov  bh, 6Fh                 ; white on brown (yellow-ish)
    mov  cx, 0C00h               ; (12,0)
    mov  dx, 114Fh               ; (17,79)
    int  10h

    mov  ah, 06h                 ; band 3: rows 18..24
    xor  al, al
    mov  bh, 1Fh                 ; white on blue
    mov  cx, 1200h               ; (18,0)
    mov  dx, 184Fh               ; (24,79)
    int  10h

    mov  ah, 02h                 ; place message near center of bottom band
    mov  bh, 0
    mov  dh, 21                  ; row 21
    mov  dl, 27                  ; col 27 � centered for 26-char message
    int  10h
    mov  ah, 09h                 ; print "Press any key to continue."
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h                 ; wait for any key
    int  16h
    jmp  MAIN_PANEL              ; back to menu

; -------------------------------------------------
; VERTICAL STRIPES (4 bands): cols 0..19, 20..39, 40..59, 60..79
; -------------------------------------------------
VERTICAL:
    call CLEAR_SCREEN

    mov  ah, 06h                 ; band 0: cols 0..19, rows 0..24
    xor  al, al
    mov  bh, 0Fh                 ; white on black
    mov  cx, 0000h               ; top-left (0,0)
    mov  dx, 1813h               ; bottom-right (24,19)
    int  10h

    mov  ah, 06h                 ; band 1: cols 20..39
    xor  al, al
    mov  bh, 5Fh                 ; white on magenta
    mov  cx, 0014h               ; (0,20)
    mov  dx, 1827h               ; (24,39)
    int  10h

    mov  ah, 06h                 ; band 2: cols 40..59
    xor  al, al
    mov  bh, 6Fh                 ; white on brown
    mov  cx, 0028h               ; (0,40)
    mov  dx, 183Bh               ; (24,59)
    int  10h

    mov  ah, 06h                 ; band 3: cols 60..79
    xor  al, al
    mov  bh, 1Fh                 ; white on blue
    mov  cx, 003Ch               ; (0,60)
    mov  dx, 184Fh               ; (24,79)
    int  10h

    mov  ah, 02h                 ; place message mid-screen
    mov  bh, 0
    mov  dh, 12
    mov  dl, 27
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h                 ; wait key
    int  16h
    jmp  MAIN_PANEL

; -------------------------------------------------
; CHECKERED PATTERN (4 � 4 blocks using the same 4 colors)
; -------------------------------------------------
CHECKERED:
    call CLEAR_SCREEN
    mov  ah, 06h
    xor  al, al

    ; Block rows: 0..5, 6..11, 12..17, 18..24
    ; Block cols: 0..19, 20..39, 40..59, 60..79
    ; Pattern alternates: 0Fh,5Fh,6Fh,1Fh in a checker fashion

    ; rows 0..5
    mov  bh, 0Fh                ; (0..5, 0..19)
    mov  cx, 0000h
    mov  dx, 0513h
    int  10h
    mov  bh, 5Fh                ; (0..5, 20..39)
    mov  cx, 0014h
    mov  dx, 0527h
    int  10h
    mov  bh, 6Fh                ; (0..5, 40..59)
    mov  cx, 0028h
    mov  dx, 053Bh
    int  10h
    mov  bh, 1Fh                ; (0..5, 60..79)
    mov  cx, 003Ch
    mov  dx, 054Fh
    int  10h

    ; rows 6..11
    mov  ch, 6
    mov  dh, 11
    mov  bh, 1Fh                ; (6..11, 0..19)
    mov  cl, 0
    mov  dl, 19
    int  10h
    mov  bh, 0Fh                ; (6..11, 20..39)
    mov  cl, 20
    mov  dl, 39
    int  10h
    mov  bh, 5Fh                ; (6..11, 40..59)
    mov  cl, 40
    mov  dl, 59
    int  10h
    mov  bh, 6Fh                ; (6..11, 60..79)
    mov  cl, 60
    mov  dl, 79
    int  10h

    ; rows 12..17
    mov  ch, 12
    mov  dh, 17
    mov  bh, 6Fh                ; (12..17, 0..19)
    mov  cl, 0
    mov  dl, 19
    int  10h
    mov  bh, 1Fh                ; (12..17, 20..39)
    mov  cl, 20
    mov  dl, 39
    int  10h
    mov  bh, 0Fh                ; (12..17, 40..59)
    mov  cl, 40
    mov  dl, 59
    int  10h
    mov  bh, 5Fh                ; (12..17, 60..79)
    mov  cl, 60
    mov  dl, 79
    int  10h

    ; rows 18..24
    mov  ch, 18
    mov  dh, 24
    mov  bh, 5Fh                ; (18..24, 0..19)
    mov  cl, 0
    mov  dl, 19
    int  10h
    mov  bh, 6Fh                ; (18..24, 20..39)
    mov  cl, 20
    mov  dl, 39
    int  10h
    mov  bh, 1Fh                ; (18..24, 40..59)
    mov  cl, 40
    mov  dl, 59
    int  10h
    mov  bh, 0Fh                ; (18..24, 60..79)
    mov  cl, 60
    mov  dl, 79
    int  10h

    ; message near bottom center
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 22
    mov  dl, 27
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h                ; wait key
    int  16h
    jmp  MAIN_PANEL

; -------------------------------------------------
QUIT:
    mov  ax, 4C00h              ; DOS terminate program
    int  21h

; -------------------------------------------------
; STRINGS (all '$'-terminated for INT 21h / AH=09h)
; -------------------------------------------------
MENU_TEXT     db 'MENU', '$'
FIRST_CHOICE  db '1 - HORIZONTAL STRIPES', '$'
SECOND_CHOICE db '2 - VERTICAL STRIPES', '$'
THIRD_CHOICE  db 'F1 - CHECKERED PATTERN', '$'   ; F2 / C / c / 3 also valid
QUIT_MSG      db 'Q - QUIT', '$'
CHOICE_MSG    db 'ENTER CHOICE: ', '$'
KEY_PROMPT    db 'Press any key to continue.', '$'
