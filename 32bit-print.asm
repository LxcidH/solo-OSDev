[bits 32] ; Using 32 bit protected mode

; This is how constants are defined
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f ; The color byte for each character

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY

print_string_pm_loop:
  mov al, [ebx]   ; [ebx] is the address of our character
  mov ah, WHITE_ON_BLACK

  cmp al, 0 ; Check for end of string
  je print_string_pm_done

  mov [edx], ax ; Store character + attr in video memory
  add ebx, 1  ; Next character
  add edx, 2  ; Next video memory position

  jmp print_string_pm_loop

print_string_pm_done:
  popa
  ret
