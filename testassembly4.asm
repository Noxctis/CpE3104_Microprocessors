org 100h

; Code section
mov ax, 0xb800      ; Load the video memory segment address
mov es, ax          ; Set ES to the video memory segment

mov si, offset message  ; SI points to the start of the message
mov di, 0               ; DI points to the start of the screen

print_char:
    mov al, [si]            ; Get a character from the string
    cmp al, 0               ; Check for the null terminator
    je end_program          ; If it's 0, the string is done

    mov ah, 0x07            ; Set the color attribute (light gray on black)
    mov word ptr es:[di], ax ; Write the character and color to video memory

    inc si                  ; Move to the next character in the string
    add di, 2               ; Move to the next position on the screen
    jmp print_char          ; Repeat the loop

end_program:
    int 20h                 ; Exit to DOS       
    

; Data section to hold the message
message db 'Hello, World!', 0