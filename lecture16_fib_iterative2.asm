# Compute several Fibonacci numbers and put in array, then print
.data
	n: .word 5 

.text
     	# LOAD NUMBER n 
	la $t0, n 
	lw $a0, 0($t0) 
      
      	li   $s2, 1           # 1 is the known value of first and second Fib. number
      	sw   $s2, 0($s0)      # F[0] = 1
      	sw   $s2, 4($s0)      # F[1] = F[0] = 1
	addi $s1, $s5, -2     # Counter for loop, will execute (size-2) times
	
	addiu $sp, $sp, -16
	sw    $fp, 0($sp)     # address of the topmost word of the frame
	move  $fp, $sp
	sw $a0 , 4 ($fp)
	sw $t0 , 8 ($fp)
	sw $s0 , 12 ($fp)
	sw $ra , 16 ($fp)
	move $t0, $a0 # load argument in temporary register, for n-1 and n-2 
	addi $t1, $zero, 1 # put 1 in $t1 
      
# Loop to compute each Fibonacci number using the previous two Fib. numbers.
loop: 
	addiu $sp, $sp, -16
	sw    $fp, 0($sp)     # address of the topmost word of the frame
	move  $fp, $sp
	sw $a0 , 4 ($fp)
	sw $t0 , 8 ($fp)
	sw $s0 , 12 ($fp)
	sw $ra , 16 ($fp)
	move $t0, $a0 # load argument in temporary register, for n-1 and n-2 
	addi $t1, $zero, 1 # put 1 in $t1 
	
      	add  $s2, $s3, $s4    # F[n] = F[n-1] + F[n-2]
      	sw   $s2, 8($s0)      # Store newly computed F[n] in array
      	move $s0, $s2
      	addi $s0, $s0, 4      # increment address to now-known Fib. number storage
      	addi $s1, $s1, -1     # decrement loop counter
      	bgtz $s1, loop        # repeat while not finished
      	
      	j end
      	# Fibonacci numbers are computed and stored in array. Print them.
      	add  $a1, $zero, $s5  # second argument for print (size)
      	jal  print            # call print routine. 

      	# The program is finished. Exit.
      	li   $v0, 10          # system call for exit
      	syscall               # Exit!
      	
end:
	lw $ra, 16($fp)     # return address $ra
	lw $s0, 12($fp)     # pad
	lw $t0, 8($fp)      # saved register holding the cumulative sum 
	lw $a0, 4($fp)      # input argument $a0=n
	lw $fp, 0($fp)	    # address of the topmost word of the frame
	addiu $sp, $sp, 24  # pop the stack
	jr $ra
		
###############################################################
# Subroutine to print the numbers on one line.
      .data
space:.asciiz  " "          # space to insert between numbers
head: .asciiz  "The Fibonacci numbers are:\n"
      .text
print:
	add  $t0, $zero, $a0  # starting address of array of data to be printed
      	add  $t1, $zero, $a1  # initialize loop counter to array size
      	la   $a0, head        # load address of the print heading string
      	li   $v0, 4           # specify Print String service
      	syscall               # print the heading string
      
out:  
	lw   $a0, 0($t0)      # load the integer to be printed (the current Fib. number)
      	li   $v0, 1           # specify Print Integer service
      	syscall               # print fibonacci number
      
      	la   $a0, space       # load address of spacer for syscall
      	li   $v0, 4           # specify Print String service
      	syscall               # print the spacer string
      
      	addi $t0, $t0, 4      # increment address of data to be printed
      	addi $t1, $t1, -1     # decrement loop counter
      	bgtz $t1, out         # repeat while not finished
      
      	jr   $ra              # return from subroutine
# End of subroutine to print the numbers on one line
###############################################################

