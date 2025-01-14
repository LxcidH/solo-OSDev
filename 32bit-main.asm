[org 0x7c00] ; bootloader offset
  mov bp, 0x9000 ; Set the stack
  mov sp, bp

  mov bx, MSG_REAL_MODE
  call print  ;  This will be written after the BIOS msgs

  call switch_to_pm
  jmp $ ; This will never be executed

%include "../solo-OSDev/boot_sect_print.asm"
%include "../solo-OSDev/32bit-gdt.asm"
%include "../solo-OSDev/32bit-print.asm"
%include "../solo-OSDev/32bit-switch.asm"

[bits 32]
BEGIN_PM:   ; After the switch we will get here
  mov ebx, MSG_PROT_MODE
  call print_string_pm    ;  Will be written @ top left corner
  jmp $

MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0

; bootsector
times 510-($-$$) db 0
dw 0xaa55

