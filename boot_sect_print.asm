print:
  pusha

  ; Keep this in mind:
  ; While (string[i] != 0) { print string[i]; i++ }
  
start:
  mov al, [bx] ; bx is the base address for the string
  cmp al, 0
  je done

  mov ah, 0x0e
  int 0x10 ; al contains the char we need to print already

  add bx, 1 ; Increment pointer and do next loop
  jmp start

done:
  popa
  ret

print_nl:
  pusha

  mov ah, 0x0e
  mov al, 0x0a ; Newline char
  int 0x10
  mov al, 0x0d ; Carriage return
  int 0x10

  popa
  ret
