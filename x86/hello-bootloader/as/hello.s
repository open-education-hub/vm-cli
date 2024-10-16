.code16                         # use 16 bits

.global init

init:
  mov $msg, %si                 # loads the address of msg into si
  mov $0xe, %ah                 # loads 0xe (function number for int 0x10) into ah
print_char:
  lodsb                         # loads the byte from the address in si into al and increments si
  cmp $0, %al                   # compares content in AL with zero
  je done                       # if al == 0, go to "done"
  int $0x10                     # prints the character in al to screen
  jmp print_char                # repeat with next byte
done:
  hlt                           # stop execution

msg: .asciz "Hello, World!\r\n"

.fill 510-(.-init), 1, 0        # add zeroes to make it 510 bytes long
.word 0xaa55                    # magic bytes that tell BIOS that this is bootable
