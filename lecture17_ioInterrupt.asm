#------------------------------------------------------------------------------
# Author: Renat Khalikov
# Class: CSCI 260 
# Date: 11/28/16
# Homework: Write a MIPS assembly program simulating MMIO to accept as input a
#			string from, and output it to, the MMIO console.
#------------------------------------------------------------------------------
# Very simple interrupt driven I/O
.text
main:						# user program
	ori  $t1, $zero, 0		# initialize $t1 with 0s
	la   $t7, enable_rxint	# load address of enable_rxint()
    jalr $t7				# jump to that address
    
loop:
	beq  $zero, $zero, loop	# increment $t1
	addi $t1, $t1, 1		# infinite loop

exit:
	li   $v0, 10			# enable program exit
	syscall
.ktext 0x80000180			# Forces interrupt routine below to be
							# located at address 0x80000180.
interp:
	# INTERRUPT HANDLER—all registers are precious
     addiu $sp, $sp, -32	# Save registers.
.set noat					# Tell assembler to stop using $at
	sw $at, 28($sp)			# so we can use it.
.set at						# Now give back $at to the assembler.
	# SAVE REGISTERS
	# Remember, this is an interrupt routine
	# so it has to save anything it touches,
	# including $t registers.
	sw   $ra, 24($sp)
	sw   $a0, 20($sp)
	sw   $v0, 16($sp)
	sw   $t3, 12($sp)
	sw   $t2, 8($sp)
	sw   $t1, 4($sp)
	sw   $t0, 0($sp)
	
	lui  $t0, 0xffff		# get address of control regs
	lw   $t1, 0($t0)		# read rcv (receiver) ctrl
	andi $t1, $t1, 1		# extract ready bit
	beq  $t1, $zero, intDone
	lw   $a0, 4($t0)		# read key
	lw   $t1, 8($t0)		# read tx (transmitter) ctrl
	andi $t1, $t1, 0x0001	# extract ready bit
	beq  $t1, $0, intDone   # still busy discard
	sw   $a0, 0xc($t0)		# write key


intDone:
    # Clear Cause register
    mfc0 $t0, $13			# get Cause reg, then clear it
    mtc0 $zero, $13
     
    # Restore registers
    lw   $t0, 0($sp)
    lw   $t1, 4($sp)
    lw   $t2, 8($sp)
    lw   $t3, 12($sp)
    lw   $v0, 16($sp)
    lw   $a0, 20($sp)
    lw   $ra, 24($sp)
.set noat
    lw   $at, 28($sp)
.set at
    addi $sp, $sp, 32
	eret           			# rtn from int and reenable ints

enable_rxint:
     mfc0 $t0, $12			# record interrupt state
     andi $t0, $t0, 0xFFFE	# clear int enable flag
     mtc0 $t0, $12			# Turn interrupts off.
     lui  $t0, 0xffff
     lw   $t1, 0($t0)		# read rcv ctrl
     ori  $t1, $t1, 0x0002	# set the input interrupt enable
     sw   $t1, 0($t0)		# update rcv ctrl
     mfc0 $t0, $12			# record interrupt state
     ori  $t0, $t0, 0x0001	# set int enable flag
     mtc0 $t0, $12			# Turn interrupts on
     jr   $ra
.data

#--------------------------------I/O-------------------------------------------
#	this program creates an output in the MIMO console
#------------------------------------------------------------------------------
