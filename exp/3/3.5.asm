org 100h                          

jmp  start

MENU_TEXT     db 'MENU', '$'
FIRST_CHOICE  db '1 - HORIZONTAL STRIPES', '$'
SECOND_CHOICE db '2 - VERTICAL STRIPES', '$'
THIRD_CHOICE  db 'F2 - CHECKERED PATTERN', '$'
QUIT_MSG      db 'Q - QUIT', '$'
CHOICE_MSG    db 'ENTER CHOICE: ', '$'
KEY_PROMPT    db 'Press any key to continue.', '$'

start:
    push cs                       
    pop  ds
    mov  ax, 0003h                
    int  10h
    jmp  MAIN_PANEL               


MAIN_PANEL:
    call CLEAR_SCREEN             
    call INIT_MOUSE               
    call DISP_MESS                
    jmp  INPUT_LOOP               

INPUT_LOOP:
    mov  ah, 01h                  
    int  16h
    jz   CHECK_MOUSE              

    mov  ah, 00h                  
    int  16h

    cmp  al, 00h                  
    jne  KB_ASCII                 


    cmp  ah, 3Bh                  
    je   CHECKERED                
    cmp  ah, 3Ch                  
    je   CHECKERED
    jmp  INPUT_LOOP               

KB_ASCII:
    cmp  al, '1'                  
    jne  KB_CHK_2
    mov  dl, '1'                  
    mov  ah, 02h
    int  21h
    jmp  HORIZONTAL

KB_CHK_2:
    cmp  al, '2'                  
    jne  KB_CHK_Q
    mov  dl, '2'
    mov  ah, 02h
    int  21h
    jmp  VERTICAL

KB_CHK_Q:
    cmp  al, 'q'                  
    je   QUIT
    cmp  al, 'Q'                  
    je   QUIT


    cmp  al, '3'                  
    je   CHECKERED
    cmp  al, 'c'                  
    je   CHECKERED
    cmp  al, 'C'                  
    je   CHECKERED

    jmp  INPUT_LOOP               


CHECK_MOUSE:
    mov  ax, 0003h               
    int  33h                   
    test bx, 0001b                
    jz   INPUT_LOOP               

    mov  ax, cx                   
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1                    
    mov  si, ax                   

    mov  ax, dx                   
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1                    
    mov  di, ax                   

    cmp  di, 6
    je   HORIZONTAL
    cmp  di, 7
    je   VERTICAL
    cmp  di, 8
    je   CHECKERED
    cmp  di, 10
    je   QUIT
    jmp  INPUT_LOOP              


CLEAR_SCREEN:
    mov  ah, 06h                  
    mov  al, 00h                  
    mov  bh, 1Eh                  
    mov  cx, 0000h                
    mov  dx, 184Fh                
    int  10h

    mov  ah, 02h                  
    xor  bx, bx                   
    xor  dx, dx                   
    int  10h
    ret

INIT_MOUSE:
    mov  ax, 0001h                
    int  33h
    mov  ax, 0002h                
    int  33h
    ret


DISP_MESS:
    mov  ah, 02h                  
    mov  bh, 0
    mov  dh, 03h
    mov  dl, 25h
    int  10h
    mov  ah, 09h                  
    mov  dx, OFFSET MENU_TEXT
    int  21h

    mov  ah, 02h
    mov  dh, 06h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET FIRST_CHOICE
    int  21h

    mov  ah, 02h
    mov  dh, 07h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET SECOND_CHOICE
    int  21h

    mov  ah, 02h
    mov  dh, 08h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET THIRD_CHOICE
    int  21h

    mov  ah, 02h
    mov  dh, 10
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET QUIT_MSG
    int  21h
    
    mov  ah, 02h
    mov  dh, 14
    mov  dl, 15h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET CHOICE_MSG
    int  21h
    ret


HORIZONTAL:
    call CLEAR_SCREEN           

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0Fh                 
    mov  cx, 0000h               
    mov  dx, 054Fh               
    int  10h

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0DFh                 
    mov  cx, 0600h               
    mov  dx, 0B4Fh               
    int  10h

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0EFh                 
    mov  cx, 0C00h               
    mov  dx, 114Fh               
    int  10h

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 9Fh                 
    mov  cx, 1200h               
    mov  dx, 184Fh               
    int  10h

    mov  ah, 02h                 
    mov  bh, 0
    mov  dh, 21                  
    mov  dl, 27                  
    int  10h
    mov  ah, 09h                 
    mov  dx, OFFSET KEY_PROMPT
    int  21h    

    mov  ah, 00h                 
    int  16h
    jmp  MAIN_PANEL              

VERTICAL:
    call CLEAR_SCREEN

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0Fh                 
    mov  cx, 0000h               
    mov  dx, 1813h               
    int  10h

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0DFh                 
    mov  cx, 0014h               
    mov  dx, 1827h               
    int  10h

    mov  ah, 06h                 
    xor  al, al
    mov  bh, 0EFh                 
    mov  cx, 0028h               
    mov  dx, 183Bh               
    int  10h

    mov  ah, 06h                
    xor  al, al
    mov  bh, 9Fh                 
    mov  cx, 003Ch               
    mov  dx, 184Fh               
    int  10h

    mov  ah, 02h                 
    mov  bh, 0
    mov  dh, 12
    mov  dl, 27
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h                 
    int  16h
    jmp  MAIN_PANEL

CHECKERED:
    call CLEAR_SCREEN
    mov  ah, 06h
    xor  al, al

    mov  bh, 0Fh                
    mov  cx, 0000h
    mov  dx, 0513h
    int  10h
    
    mov  bh, 5Fh                
    mov  cx, 0014h
    mov  dx, 0527h
    int  10h
    
    mov  bh, 6Fh                
    mov  cx, 0028h
    mov  dx, 053Bh
    int  10h
    
    mov  bh, 1Fh                
    mov  cx, 003Ch
    mov  dx, 054Fh
    int  10h

    mov  ch, 6
    mov  dh, 11
    mov  bh, 1Fh                
    mov  cl, 0
    mov  dl, 19
    int  10h
    
    mov  bh, 0Fh                
    mov  cl, 20
    mov  dl, 39
    int  10h
    
    mov  bh, 5Fh                
    mov  cl, 40
    mov  dl, 59
    int  10h
    
    mov  bh, 6Fh                
    mov  cl, 60
    mov  dl, 79
    int  10h

    
    mov  ch, 12
    mov  dh, 17
    mov  bh, 6Fh                
    mov  cl, 0
    mov  dl, 19
    int  10h
    
    mov  bh, 1Fh                
    mov  cl, 20
    mov  dl, 39
    int  10h
    
    mov  bh, 0Fh                
    mov  cl, 40
    mov  dl, 59
    int  10h
    
    mov  bh, 5Fh                
    mov  cl, 60
    mov  dl, 79
    int  10h

    mov  ch, 18
    mov  dh, 24
    mov  bh, 5Fh                
    mov  cl, 0
    mov  dl, 19
    int  10h
    
    mov  bh, 6Fh                
    mov  cl, 20
    mov  dl, 39
    int  10h
    
    mov  bh, 1Fh                
    mov  cl, 40
    mov  dl, 59
    int  10h
    
    mov  bh, 0Fh                
    mov  cl, 60
    mov  dl, 79
    int  10h

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 22
    mov  dl, 27
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h                
    int  16h
    jmp  MAIN_PANEL

QUIT:
    mov  dl, 'Q'
    mov  ah, 02h
    int  21h
    mov  ax, 4C00h              
    int  21h

