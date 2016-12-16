#------------------------------------------------------------------------------
# Author: Renat Khalikov
# Class: CSCI 260 
# Date: 11/28/16
# Homework: Write an exception handler for FP arithmetic overflow. The action 
# 			of the handler should be to display a message to the console and 
#			to stop the program execution.
#------------------------------------------------------------------------------
.data 
	n: .word 5 
	mess_base0: .asciiz "In base 0 case...\n" 
	mess_base1: .asciiz "In base 1 case...\n" 
	mess_recursive: .asciiz "Calling fib() with n=" 
	mess_exit: .asciiz "The final value is: " 
	eol: .asciiz "\n" 
	plus: .asciiz "+" 
	
.text 
main: 
	# LOAD NUMBER n 
	la $t0, n 
	lw $a0, 0($t0) 
	
	# CALL fib() FUNCTION 
	jal fib 
	move $t0, $v0 
	
	# PRINT RESULT TEXT 
	la $a0, mess_exit 
	li $v0, 4 
	syscall
	
	# PRINT RESULT 
	move $a0, $t0 
	li $v0, 1 
	syscall 
	
	# EXIT PROGRAM 
	li $v0, 10 
	syscall 
	
fib: 
	# ALLOCATE FRAME STACK: 1. arguments, 2. saved registers, 3. return address
	# 			4. pad, 5. local data 
	addiu $sp $sp -24    # push stack frame stored at addresses 0($sp) to 
						 # 24($sp)
	sw    $fp, 0($sp)    # address of the topmost word of the frame
	move  $fp, $sp
	sw    $a0, 4($fp)   # input argument $a0=n, will be rewritten 
	sw    $t0, 8($fp)   # saved register holding the cumulative sum 
	sw    $s0, 12($fp)  # pad	
	sw    $ra, 16($fp)  # return address $ra to save across fib() calls 
	
	
	# Load 2147483647 into $s1
	lui $s1, 32767
	ori $s2, $s1, 65535

	# Add 1 to $s1 and store in $s2. This should produce an overflow 
	# exception
	addi $s3, $s1, 1

	teq $s3, $s3  # trap because $s3 contains 2147483648

end:
	lw $ra, 16($fp)     # return address $ra
	lw $s0, 12($fp)     # pad
	lw $t0, 8($fp)      # saved register holding the cumulative sum 
	lw $a0, 4($fp)      # input argument $a0=n
	lw $fp, 0($fp)	    # address of the topmost word of the frame
	addiu $sp, $sp, 24  # pop the stack
	jr $ra

# Trap handler in the standard MIPS32 kernel text segment
	.ktext 0x80000180
   	move $k0,$v0   # Save $v0 value
   	move $k1,$a0   # Save $a0 value
   	la   $a0, msg  # address of string to print
   	li   $v0, 4    # Print String service
   	syscall
   	move $v0,$k0   # Restore $v0
   	move $a0,$k1   # Restore $a0
   	mfc0 $k0,$14   # Coprocessor 0 register $14 has address 
   				  # of trapping instruction
   	addi $k0,$k0,4 # Add 4 to point to next instruction
   	mtc0 $k0,$14   # Store new address back into $14
   	# EXIT PROGRAM 
	li $v0, 10 
	syscall 
   	eret           # Error return; set PC to value in $14
   .kdata	
   
msg:   
   .asciiz "Trap generated, arithmetic overflow"
	
#--------------------------------I/O-------------------------------------------
#	Trap generated, arithmetic overflow
#	-- program is finished running --
#------------------------------------------------------------------------------
