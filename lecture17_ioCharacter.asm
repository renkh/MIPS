# Memory mapped address of device registers.
# 0xFFFF0000 rcv (=receiver, or keyboard) contrl
# 0xFFFF0004 rcv data
# 0xFFFF0008 tx (=transmitter, or display) contrl
# 0xFFFF000c tx data
.text
main:
     jal  getc		# call getc() to get char
     ori  $a0, $v0, 0	# put its return value into arg.
     jal  putc		# call putc() to put char
     move $a0, $v0	# put its return value into arg.
     li   $v0, 11	# enable printing of character
     syscall
     
exit:
     li      $v0, 10	# exit program
     syscall
     
getc:
#    v0 = received byte
     lui  $t0, 0xffff	# set $t0 to base address of rcv
     
gcloop:
     lw   $t1, 0($t0)		# read rcv ctrl
     andi $t1, $t1, 0x0001	# extract ready bit as soon as 1
     beq  $t1, $0, gcloop	# keep polling till ready
     lw   $v0, 4($t0)		# read data and rtn
     jr   $ra
     
putc:
#    a0 = byte to transmit
     lui  $t0, 0xffff		# set $t0 to base address of rcv
     
pcloop:
     lw   $t1, 8($t0)		# read tx ctrl
     andi $t1, $t1, 0x0001	# extract ready bit
     beq  $t1, $0, pcloop	# wait till ready
     sw   $a0, 12($t0)		# write data
     jr   $ra
.data
