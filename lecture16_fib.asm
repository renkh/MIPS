#------------------------------------------------------------------------------
# Author: Renat Khalikov
# Class: CSCI 260 
# Date: 11/21/16
# Homework: Rewrite the Fibonacci recursive version using the frame pointer.
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
	# ALLOCATE FRAME STACK: 1. arguments, 2. saved registers, 3. return address,
	# 			4. pad, 5. local data 
	addiu $sp $sp -24    # push stack frame stored at addresses 0($sp) to 24($sp)
	sw    $fp, 0($sp)    # address of the topmost word of the frame
	move  $fp, $sp
	sw    $a0, 4($fp)   # input argument $a0=n, will be rewritten 
	sw    $t0, 8($fp)   # saved register holding the cumulative sum 
	sw    $s0, 12($fp)  # pad	
	sw    $ra, 16($fp)  # return address $ra to save across fib() calls 
	
	move $t0, $a0 # load argument in temporary register, for n-1 and n-2 
	

base0: 
	bne $t0, $zero, base1 # if n!=0, go to test for n==1 
	li $v0, 0 
	j end 
	
base1: 
	addi $t1, $zero, 1 # put 1 in $t1 
	bne $t0, $t1, recursive # if n!=1, go to recursive case 

	li $v0, 1 
	j end 
	
recursive: 
	la $a0, mess_recursive 
	li $v0, 4 
	syscall 
	
	move $a0, $t0 
	li $v0, 1 
	syscall 
	
	la $a0, eol 
	li $v0, 4 
	syscall 
	
	addi $a0, $t0, -1 	# calculate n-1 
	jal fib 	  		# call fib(n-1) 
	move $s0, $v0     	# store result in $s0 
	
	addi $a0, $t0, -2 	# calculate n-2 
	jal fib 	  		# call fib(n-2)
	add $s0, $s0, $v0 	# store fib(n-1)+fib(n-2) in $s0 
	move $v0, $s0     	# store return value

end:
	lw $ra, 16($fp)     # return address $ra
	lw $s0, 12($fp)     # pad
	lw $t0, 8($fp)      # saved register holding the cumulative sum 
	lw $a0, 4($fp)      # input argument $a0=n
	lw $fp, 0($fp)	    # address of the topmost word of the frame
	addiu $sp, $sp, 24  # pop the stack
	jr $ra

#--------------------------------I/O-------------------------------------------
# Calling fib() with n=5
# Calling fib() with n=4
# Calling fib() with n=3
# Calling fib() with n=2
# Calling fib() with n=2
# Calling fib() with n=3
# Calling fib() with n=2
# The final value is: 5
# -- program is finished running --
#------------------------------------------------------------------------------
