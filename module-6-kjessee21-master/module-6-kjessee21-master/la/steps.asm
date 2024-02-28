# Author: Kaden Jessee
# Desc:
# Date: 12 Apr 2022

.data	# your "data"


.text	# actual instructions
.globl main
main:
	li $a0, 3
	jal steps
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $a0, 0xA
	li $v0, 11
	syscall
	
	li $a0, 4
	jal steps
	move $a0, $v0
	li $v0, 1
	syscall
	
	li $a0, 0xA
	li $v0, 11
	syscall
	
	li $a0, 5
	jal steps
	move $a0, $v0
	li $v0, 1
	syscall

exit:
	# exit program
	li $v0, 10
	syscall

#Compute the number of ways those steps can be climbed
#according to this relationships steps(n) = steps(n-1) + steps(n-2) + steps(n-3)
#$a0 - number of steps remaining to be climbed
#Returns $v0 - the number of ways those steps can be climbed
steps:
	subi $sp, $sp, 12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, ($sp)
	move $s0, $a0
	bgez $s0, not_lt_zero	#if (remining steps < 0)
	li $v0, 0		#return 0;
	j end_steps
	
not_lt_zero:
	bgtz $s0,  not_zero	#if (remaining steps == 0)
	li $v0, 1		#return 1;
	j end_steps
not_zero:	
	subi $a0, $s0, 1		
	jal steps			#return steps(remainingsteps-1)
	move $s1, $v0
	subi $a0, $s0, 2
	jal steps			#steps(remaining-2)
	add $s1, $s1, $v0
	subi $a0, $s0, 3
	jal steps			#steps(reamining-3)
	add $v0, $s1, $v0
	j end_steps
end_steps:
	lw $ra, 8($sp)
	lw $s0, 4($sp)
	lw $s1, ($sp)
	addi $sp, $sp, 12
	jr $ra