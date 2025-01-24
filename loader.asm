[bits 16]
[org 0x7e00]

start:
    mov [DriveId],dl    ; Save drive number

    mov eax,0x80000000
    cpuid
    cmp eax,0x80000001
    jb NotSupport       ; Jumps if below
    mov eax,0x80000001  ; Returns processor features
    cpuid
    test edx,(1<<29)    ; Test bit 29 && 26
    jz NotSupport
    test edx,(1<<26)
    jz NotSupport

    mov ah,0x13         ; 0x13 means "print string"
    mov al,1            ; specifies write mode, cursor placed at end of string
    mov bx,0xa          ; bh = page num, bl = info abt char attributes. 0xa means char is printed in bright green
    xor dx,dx           ; dh = rows, dl = cols. set them to 0 to print at beginning of the screen
    mov bp,Message      ; bp = addr of msg to print
    mov cx,MessageLen   ; cx = sizeof(msg)
    int 0x10

NotSupport:

End:
    hlt
    jmp End

DriveId: db 0
Message: db "Long mode supported"
MessageLen: equ $-Message