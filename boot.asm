[BITS 16]
[ORG 0x7c00]

start:
    xor ax,ax           ; Init Segment registers and set all to 0 (xor in something to itself results in 0)
    mov ds,ax           
    mov es,ax           
    mov ss,ax           
    mov sp,0x7c00       ; Stack grows downwards from 0x7c00 to 0

TestDiskExtension:
    mov [DriveId],dl
    mov ah,0x41
    mov bx,0x55aa
    int 0x13
    jc NotSupport
    cmp bx,0xaa55
    jne NotSupport

LoadLoader:
    mov si,[ReadPacket]
    mov word[si],0x10   ; Size
    mov word[si+2],5    ; Number of sectors to read
    mov word[si+4],0x7e00
    mov word[si+6],0
    mov dword[si+8],1
    mov dword[si+0xc],0
    mov dl,[DriveId]    ; Set dl to drive number
    mov ah,0x42         ; Use disk extension service
    int 0x13
    jc ReadError

    mov dl,[DriveId]
    jmp 0x7e00

ReadError:
NotSupport:
    mov ah,0x13         ; 0x13 means "print string"
    mov al,1            ; specifies write mode, cursor placed at end of string
    mov bx,0xa          ; bh = page num, bl = info abt char attributes. 0xa means char is printed in bright green
    xor dx,dx           ; dh = rows, dl = cols. set them to 0 to print at beginning of the screen
    mov bp,Message      ; bp = addr of msg to print
    mov cx,MessageLen   ; cx = sizeof(msg)
    int 0x10

End:
    hlt
    jmp End

DriveId: db 0
Message: db "We have an error in the boot process"
MessageLen: equ $-Message       ; $ = end of message - addr of message to get size of string (how many chars in str)
ReadPacket: times 16 db 0

times (0x1be-($-$$)) db 0       ; pad rest of file with 0s

    db 80h                      ; Boot indicator
    db 0,2,0                    ; Starting CHS - cylinder, head, sector
    db 0f0h                     ; Type
    db 0ffh,0ffh,0ffh           ; Ending CHS - ff max value for byte
    dd 1                        ; Starting sector - LBA starting sector - Logical block address
    dd (20*16*63-1)             ; Size - 10MB

    times (16*3) db 0

    db 0x55
    db 0xaa