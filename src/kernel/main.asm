org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
  jmp main

;
; Prints a string to the screen
; Params:
;     - ds:si points to string

puts:
  ; Save registers we will modify
  push si
  push ax


.loop:
  lodsb     ; Loads next char in al
  or al, al ; Checks if next char is null
  jz .done  ; Jumps to '.done' if the zero flag is set from or-ing al to itself

  mov ah, 0x0e
  mov bh, 0
  int 0x10

  jmp .loop


.done:
  pop ax    ; Pop the registers we pushed to stack in reverse order
  pop si
  ret


main:

  ; Setup Data Segments
  mov ax, 0
  mov ds, ax
  mov es, ax

  ; Setup stack
  mov ss, ax    
  mov sp, 0x7C00  ; Stack grows downwards from where we are in memory


  mov si, msg_hello
  call puts

  hlt


.halt:
  jmp .halt


msg_hello: db 'Hello, World!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
