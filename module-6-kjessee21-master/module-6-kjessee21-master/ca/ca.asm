# Author: Kaden Jessee
# Date: 14 Apr 2022
# Description: 

.globl main			# Do not remove this line

# Data for the program goes here
.data
prompt: .asciiz  "Enter up to 16 strings (max length 31 characters) 1 per line.\nEnter a blank line to finishing inputing strings.\n"
next: .asciiz "Next string: "
orig: .asciiz "\nOrig: "
len: .asciiz "\nLength: "
rev: .asciiz "\nReverse: "
kpal: .asciiz "\nK-palindrome: "
#Arrays to store the user inputted strings and the reverse.
strings: .space 512  #16 strings of up to 32 characters each including the null character
reversed: .space 512 #16 strings of up to 32 characters each including the null character
# Create additional arrays here if needed
integer: .space 64  #16 words (4 bytes each)
kpali: .space 64


.text
main:

	# Step 1: Read user-inputted strings
	move $s0, $zero			# index for string arrays
	move $s1, $zero			# index of integer arrays
	move $s2, $zero			# input_loop index
	move $s3, $zero                 # string length value
	#print_str(prompt)		# Print prompt label
	la $a0, prompt
	li $v0, 4
	syscall
	
	
input_loop:
	la $a0, next			#setup getinput
	la $a1, strings($s0)
	la $a2, 31
	#branches 16 total strings
	beq $s2, 16, end_input_loop
	jal get_input
	
	#lbu $t0 from ($v0)
	#beq $t0, 0xA (new line) end_input_loop
	lbu $t0, strings($s0)
	beq $t0, 0xA, end_input_loop
	
	#need to truncate the newline character
	la $a0, strings($s0)
	jal strtrunc
	
	# Step 2: Calculate string lengths
	la $a0, strings($s0)
	jal strlen
	move $s3, $v0
	sw $s3, integer($s1)	#integers[i] = s3
	
	# Step 3: Reverse the strings
	la $a0, strings($s0)
	la $a1, reversed($s0)
	jal reverse_string
	
	# Step 4: Compute 2k k-palindrome value
	la $a0, strings($s0)	#X
	la $a1, reversed($s0)	#Y
	lw $a2, integer($s1)	#m
	lw $a3, integer($s1)	#n
	jal k_palindrome
	sw $v0, kpali($s1)
	
	# Update all your indexes
	addi $s0, $s0, 32
	addi $s1, $s1, 4
	addi $s2, $s2, 1
	j input_loop
end_input_loop:
	move $s7, $s0	#calculate total strings entered
	# Step 5: Print the results
	
	# Reset your indexes to print array information
	move $s0, $zero			# index for string arrays
	move $s1, $zero			# index of integer arrays
	move $s2, $zero			# input_loop index
print_loop:
	beq $s0, $s7, end_print_loop
	la $a0, orig			#print origin string
	li $v0, 4
	syscall
	la $a0, strings($s0)		#print inputted string from user
	li $v0, 4
	syscall
	la $a0, len			#print length string
	li $v0, 4
	syscall
	lw $a0, integer($s1)		#print length number
	li $v0, 1
	syscall
	la $a0, rev			#print reverse string
	li $v0, 4
	syscall
	la $a0, reversed($s0)		#print reversed inputted string from user
	li $v0, 4
	syscall
	la $a0, kpal
	li $v0, 4
	syscall
	lw $a0, kpali($s1)		#print kpalindrome
	div $a0, $a0, 2			#make sure result is just k
	li $v0, 1
	syscall
	
	
	addi $s0, $s0, 32		#increment counters
	addi $s1, $s1, 4
	addi $s2, $s2, 1
	j print_loop
end_print_loop:
	j exit_main
	
## end of ca.asm
exit_main:
	li   $v0, 10			# 10 is the exit program syscall
	syscall				# execute call

###############################################################
# Calculates 2k where k is the minimum number of deletions required to
# turn a string into a palindrome.
#
# Argument parameters:
# $a0 - the address of the string
# $a1 - the address of the string in reverse
# $a2 - the length of the string
# $a3 - the length of the string in reverse
# $v0 - 2*k where k is the minimum number of deletions required to convert the
#       string in $a0 into a palindrome.
k_palindrome:				#(string X, string Y, int m, int n)
	
	# Possible Pseudocode.
	# Store registers 
	subu $sp, $sp, 32	#frame size = 32 (begin allocation)
	sw $ra, 28($sp)		#preserve the return address (required)
	sw $fp, 24($sp)		#preserve the frame pointer (required)
	sw $s0, 20($sp)		#preserve $s0 (if needed)
	sw $s1, 16($sp)		#preserve $s1 (if needed)
	sw $s2, 12($sp)		#preserve $s2
	sw $s3, 8($sp)		#preserve $s3
	sw $s4, 4($sp)		#preserve $s4
	addu $fp, $sp, 32	#move frame pointer to base frame (end allocation)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# if either string is empty, return the sum of the lengths
	beqz $s2, sum	 #if (m==0 || n==0)
	beqz $s3, sum
	# ignore last characters of both strings if they are same
	# and recur for remaining characters
	#if (X[m-1] == Y[n-1])
	subi $t0, $s2, 1 	#m-1
	subi $t1, $s3, 1	#n-1
	add $t0, $s0, $t0
	add $t1, $s1, $t1	#calculates offset for word/byte
	lbu $t0, ($t0)		#$a0($t0)
	lbu $t1, ($t1)
	beq $t0, $t1, recur
	# ignore last character from the first string and recur
	#int x = iskpali(X, m-1, Y, n);
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	subi $a2, $a2, 1
	jal k_palindrome
	move $s4, $v0
	# ignore last character from the second string and recur
	#int y = iskpali(X, m, Y, n-1);
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	move $a3, $s3
	subi $a3, $a3, 1
	jal k_palindrome
	move $t0, $v0
	# return minimum of above two operations plus one
	#return 1+min(x,y); x -- $s4, y -- $t0
	blt $s4, $t0, x
	addi $v0, $t0, 1
	j end_k_palindrome
x:
	addi $v0, $s4, 1
	j end_k_palindrome

sum:
	add $t0, $s2, $s3
	move $v0, $t0	#return n + m;
	j end_k_palindrome
	
recur:
	#return isKpalindrome(X, m-1, Y, n-1)
	#$a0,$a1 already have addresses
	subi $t0, $s2, 1 	#m-1
	subi $t1, $s3, 1	#n-1
	move $a2, $t0
	move $a3, $t1
	jal k_palindrome

end_k_palindrome:
	# Load registers 
	# Restore registers from Stack
	lw $ra, 28($sp)		#restore the return address (required)
	lw $fp, 24($sp)		#restore the fram pointer (required)
	lw $s0, 20($sp)		#restore $s0 (if needed)
	lw $s1, 16($sp)		#restore $s1 (if needed)
	lw $s2, 12($sp)		#restore $s2
	lw $s3, 8($sp)		#restore $s3
	lw $s4, 4($sp)		#restore $s4
	addu $sp, $sp, 32	#move frame pointer to base frame (end allocation)
	jr $ra
###############################################################
# Reverses a null-terminated string and stores the result at the specified location
# Assumes that the string is 31 characters or less and that the result Address
# has enough space for the entire string (including the null character).
# Creates a local array for storing the intermediate result.
#
# Argument parameters:
# $a0 - Address of the string
# $a1 - Address of the result
reverse_string:
	subi $sp, $sp, 516
	sw $ra, 512($sp)
	move $t0, $a0
	addi $t1, $sp, 511	#doesn't include null character
	sb $zero, ($t1)
num_loop:
	lbu $t2, ($t0)
	beqz $t2, end_reverse_string
	subi $t1, $t1, 1
	sb $t2, ($t1)
incr:
	addi $t0, $t0, 1
	j num_loop
	
end_reverse_string:
	move $a0, $t1
	#$a1 already has adress
	jal strcopy
	lw $ra, 512($sp)
	jr $ra	

	
###############################################################
# Calcualtes the length of a null-terminated string
#
# Argument parameters:
# $a0 - Address of the string
# Return Value:
# $v0 - number of characters in the string (do not count the null character)
strlen:
	move $t0, $zero
	move $t1, $a0

len_loop:
	lbu $t2, ($t1)
	beq $t2, 0x0 end_strlen
	beq $t2, 0, end_strlen
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j len_loop
end_strlen:
	sb $zero, ($t1)
	move $v0, $t0
	jr $ra
# Add additional procedures here if needed
#Get Input procedure
#$a0 - address of prompt to print
#$a1 - address to store string
#$a2 - max string length
#returns
#$v0 - length of string
get_input:
	subi $sp, $sp, 4
	sw $ra, 0($sp)
	li $v0, 4
	syscall
	move $a0, $a1
	move $a1, $a2
	li $v0, 8
	syscall
end_get_input:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
#Truncate a string at '\n' return length
#$a0 - address of string
#returns
#$v0 - length	
strtrunc:	
	move $t0, $zero
	move $t1, $a0
str_loop:	
	lbu $t2, ($t1)
	beq $t2, 0xA, end_strtrunc
	beq $t2, 0, end_strtrunc
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j str_loop
	
end_strtrunc:	
	sb $zero, ($t1)
	move $v0, $t0
	jr $ra
	
	
#Copy a string from one location to another
#$a0 - address of original string
#$a1 - address of new location
strcopy:	
	move $t0, $a0
	move $t1, $a1
str_cloop:	
	lbu $t2, ($t0)
	sb $t2, ($t1)
	beq $t2, 0, end_strcopy
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j str_cloop
	
end_strcopy:	
	jr $ra
