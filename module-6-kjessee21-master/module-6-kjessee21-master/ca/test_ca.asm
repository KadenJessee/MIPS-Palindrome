#
# Test ca.asm floating point parser with some examples
#
# s0 - num of tests left to run
# s1 - position of strings
# s2 - position of words
# s3 - expected output
# s4 - fail reason
#
#
# all procedures of ca.asm must:
# - be named as specified and declared as global
# - read parameters from a0 and a1
# - follow the convention of using the t0-9 registers for temporary storage
# - (if it uses s0-7 then it is responsible for pushing existing values to the stack then popping them back off before returning)
# - write the return value to v0

.data

# number of test cases
n: .word 10
# input values (null terminated) & expected output values (word sized ints)
ins: .asciiz "avid diva"
.space 2
.asciiz "aibohphobia"
.asciiz "civic"
.space 6
.asciiz "racecar"
.space 4
.asciiz "never"
.space 6
.asciiz "abcdecba"
.space 3
.asciiz "words"
.space 6
.asciiz "dada"
.space 7
.asciiz "mama"
.space 7
.asciiz "acdedcb"
.align 2
_rev: .asciiz "avid diva"
.space 2
.asciiz "aibohphobia"
.asciiz "civic"
.space 6
.asciiz "racecar"
.space 4
.asciiz "reven"
.space 6
.asciiz "abcedcba"
.space 3
.asciiz "sdrow"
.space 6
.asciiz "adad"
.space 7
.asciiz "amam"
.space 7
.asciiz "bcdedca"
.align 2
lengths: .word 9, 11, 5, 7, 5, 8, 5, 4, 4, 7
k_palin: .word 0, 0, 0, 0, 4, 2, 8, 2, 2, 4
output: .space 12
reason: .ascii "\nlength\00\nreverse\00\nkpalindrome\00"
failedtest: .asciiz "failed test number: "
failmsg: .asciiz "\nfailed for test input: "
okmsg: .asciiz "all tests passed"


.text

runner:
        lw      $s0, n
        li      $s1, 0
        li      $s2, 0
        li      $s3, 0

run_test:
        la      $a0, ins($s1)           # get input
        jal     strlen                 # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lb      $s3, lengths($s2)       # read expected output from memory
        li      $s4, 0
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        la      $a0, ins($s1)           # get input
        la      $a1, output
        jal     reverse_string          # call subroutine under test

        la      $s3, _rev($s1)       # read expected output from memory
        jal     strcmp
        li      $s4, 9
        bnez    $v0, exit_fail          # if expected doesn't match actual, jump to fail

        la      $a0, ins($s1)           # get input
        la      $a1, _rev($s1)
        lw      $a2, lengths($s2)
        lw      $a3, lengths($s2)
        jal     k_palindrome            # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall

        lw      $s3, k_palin($s2)       # read expected output from memory
        li      $s4, 19
        bne     $v1, $s3, exit_fail     # if expected doesn't match actual, jump to fail

        addi    $s1, $s1, 12             # move to next inputs/outputs
        addi    $s2, $s2, 4             # move to next signs
        sub     $s0, $s0, 1             # decrement num of tests left to run
        bgt     $s0, $zero, run_test    # if more than zero tests to run, jump to run_test

exit_ok:
        la      $a0, okmsg              # put address of okmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        li      $v0, 10                 # 10 is exit with zero status (clean exit)
        syscall

exit_fail:
        la      $a0, failedtest         # put address of failmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        srl     $a0, $s2, 2
        li      $v0, 1
        syscall
        
        la      $a0, failmsg            # put address of failmsg into a0
        li      $v0, 4                  # 4 is print string
        syscall

        la      $a0, ins($s1)          # print input that failed on
        li      $v0, 4
        syscall
        
        la      $a0, reason($s4)
        li      $v0, 4
        syscall

        li      $a0, 1                  # set error code to 1
        li      $v0, 17                 # 17 is exit with error
        syscall


strcmp:
	move $t0, $a0
	move $t1, $a1
cmp_loop:
	lbu   $t2, ($t0)
	lbu   $t3, ($t1)
	sub   $v0, $t2, $t3
	bnez  $v0, end_strcpy
	addi  $t0, $t0, 1
	addi  $t1, $t1, 1
	bnez  $t2, cmp_loop
end_strcmp:
	jr    $ra

# # Include your implementation here if you wish to run this from the MARS GUI.
 .include "ca.asm"
