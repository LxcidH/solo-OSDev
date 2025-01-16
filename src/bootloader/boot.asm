org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;
; FAT12 Headers
;

jmp short start
nop
bdb_oem:                      db 'MSWIN4.1'             ; 8 bytes
bdb_bytes_per_sector:         dw  512
bdb_sectors_per_cluster:      db  1
bdb_reserved_sectors:         dw  1
bdb_fat_count:                db  2
bdb_dir_entries_count:        dw  0E0h
bdb_total_sectors:            dw  2880                  ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:    db  0F0h                  ; 3.5' Floppy disk
bdb_sectors_per_fat:          dw  9                     ; 9 sectors/FAT
bdb_sectors_per_track:        dw  18 
bdb_heads:                    dw  2
bdb_hidden_sectors:           dd  0  
bdb_large_sector_count:       dd  0

; Extended boot record
ebr_drive_number              db  0                     ; 0x00 = Floppy, 0x80 = hdd
                              db  0                     ; Reserved byte
ebr_signature:                db  29h
ebr_volume_id:                db  12h, 34h, 56h, 78h    ; Serial Number, value doesn't matter
ebr_volume_label:             db  'LXCID OS   '         ; 11 bytes, padded with spaces
ebr_system_id:                db  'FAT12   '            ; 8 bytes, padded with spaces

;
; Code goes here
;


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


  ; Read something from disk
  ; BIOS should set drive number
  mov [ebr_drive_number], dl

  mov ax, 1        ; Read the second sector
  mov cl, 1        ; 1 sector to read
  mov bx, 0x7E00   ; Data should be after the bootloader
  call disk_read


  mov si, msg_hello
  call puts

  hlt

;
; Error handlers
;

floppy_error:
  mov si, msg_read_failed
  call puts
  jmp wait_key_and_reboot
  
wait_key_and_reboot:
  mov ah, 0
  int 16h                 ; Wait for keypress from user
  jmp 0FFFFh:0            ; Jump to beginning of bios, should restart

.halt:
  cli                     ; Disable interrupts, that way CPU cant get out of halt state
  hlt


;
; Disk routines
;

;
; Converts LSA address to CHS address
; Parameters:
;   - cx [bits 0-5]: sector number
;   - cx [bits 6-15]: cylinder
;   - dh: head
;

lba_to_chs:
  push ax
  push dx
  
  xor dx, dx                                    ; dx = 0
  div word [bdb_sectors_per_track]              ; ax = LBA / SectorsPerTrack
                                                ; dx = LBA % SectorsPerTrack
  
  inc dx                                        ; dx = (LBA % SectorsPerTrack + 1)  = Sector
  mov cx, dx                                    ; cx = sector

  xor dx, dx                                    ; dx = 0
  div word [bdb_heads]                          ; ax = (LBA / SectorsPerTrack) / Heads = Cylinder
                                                ; dx = (LBA / SectorsPerTrack) % Heads = head
  mov dh, dl                                    ; dl = head
  mov cl, al                                    ; ch = cylinder (lower 8 bits)
  shl ah, 6                                     ; shift bits in ah left 6
  or cl, ah                                     ; put upper 2 bits of cylinder in cl

  pop ax
  mov dl, al                                    ; restore dl
  pop ax

  ret 


;
; Reads sectors from a disk
; parameters:
;   - ax: LBA Address
;   - cl: Num of sectors to read (up to 128)
;   - dl: Drive number
;   - es:bx:  Memory address where to store read data
;
disk_read:
  push ax                                     ; Save registers that will be modified
  push bx
  push cx
  push dx
  push di

  push cx                                       ; Temporarily save cl (number of sectors to read)
  call lba_to_chs                               ; Compute CHS
  pop ax                                        ; AL = Number of sectors to read

  mov ah, 02h
  mov di, 3                                      ;  Retry count


.retry:
  pusha                                           ; Save all registers to stack
  stc                                             ; Set carry flag since some BIOS's forget to set it
  int 13h                                         ; Carry flag cleared = success
  jnc .done                                       ; Jump if carry not set

  ; Read failed
  popa
  call disk_reset

  dec di
  test di, di
  jnz .retry

.fail:
  ; all attempts are exhausted
  jmp floppy_error

.done:
  popa

  push di                                           ; Restore registers
  push dx
  push cx
  push bx
  push ax
  ret

;
; Resets disk controller
; Parameters:
;   dl: Drive number
;

disk_reset:
  mov ah, 0
  stc
  int 13h
  jc floppy_error
  popa
  ret


msg_hello: db 'Hello, World!', ENDL, 0
msg_read_failed: db 'Read from disk Failed! :(', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h
