gdt_start:
  ; The GDT starts with a null 8-byte
  dd 0x0 ; 4 byte
  dd 0x0

; GDT for code segment. base = 0x00000000, length = 0xfffff

gdt_code:
  dw 0xffff     ; Segment length, bits 0-15
  dw 0x0        ; Segment base, bits 0-15
  db 0x0        ; Segment base, bits 16-23
  db 10011010b  ; Flags (8 bits)
  db 11001111b  ; Flags (4 bits) + segment length, bits 16-19
  db 0x0        ; Segment base, bits 24-31

; GDT for data segment. base and length identical to code Segment

gdt_data:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1    ; Size (16 bit), always one less than its true size
  dd gdt_start                  ; Address (32 bit)

; Consts for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
