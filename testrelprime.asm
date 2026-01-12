#**********************************************************************
# CSSE 232 - Tests for GCD and relPrime
# Rose-Hulman Institute of Technology
#
# This file contains a test procedure for the RISCV assembly language
# implementation of gcd.
#
# 2024 - Sid Stamm <stammsl@rose-hulman.edu>
#**********************************************************************

.globl runtests

.data
# set this to 1 if you want to test gcd
TEST_GCD:      .word 0

# set this to 1 if you want to test relPrime
TEST_RELPRIME: .word 1

# You can add more GCD tests by extending the arrays below.
# Since gcd() takes two arguments, the inputs are in the 
#     same array (a0, b0, a1, b1, ...).  The test loads them
#     two at a time.
# note: Values are tested in REVERSE order (right to left)
gcd_input_pairs:      .word 12,8,  1,5,  310,24
gcd_expected_results: .word 4,     1,    2
gcd_num_tests:        .word 3

# You can add more relPrime tests by extending the arrays below.
# note: Values are tested in REVERSE order (right to left)
relprime_inputs:	          .word 30030, 5040,  2, 1
relprime_expected_results:    .word    17,   11,  3, 2
relprime_num_tests:           .word 4

# These are strings for printing.
g_gcdtestmsg:   .asciz "testing gcd with values "
g_relprimemsg:  .asciz "testing relprime with value "
g_comma:        .asciz ","
g_dots:         .asciz "... "
g_passmsg:      .asciz " -> pass\n"
g_failmsg:      .asciz " -> FAIL\n"
g_sreg_notpres: .asciz "ERROR: one of the callee-saves registers was not preserved. Ending execution so you can debug (look for callee-saves register without value -1).\n"

.text

###
### This is the main subroutine that runs GCD and relPrime tests.
###
runtests:
	######################################################
	# do we want to test GCD?
    la   t0, TEST_GCD
    lw   t0, 0(t0)
    addi t0, t0, -1
    bne  t0, x0 _nogcd

	la t0, gcd_num_tests
	lw t0, 0(t0) #number of tests
	addi sp, sp, -4
	sw t0, 0(sp) #save num tests on stack

	_test_gcd_next:
	# wipe everything
	jal ra, wipeTRegisters
	jal ra, wipeSRegisters

	# get test num off the stack
	lw t0, 0(sp)
	bge x0, t0 _test_gcd_done #if num tests left is <= 0, stop.

	addi t0, t0, -1
	sw   t0, 0(sp)
	
	# set arguments a, b
	la t1, gcd_input_pairs
	slli t0, t0, 3
	add  t0, t0, t1 #base plus offset
	lw   a0, 0(t0)
	lw   a1, 4(t0)
	jal ra, printGCDmsg

	#####################################################
	#### CALL TO GCD PROCEDURE (the one we're testing) ##
    jal ra, gcd
	#####################################################

	# print return value
	addi a7, x0, 1
	ecall

	# get test num off the stack (is num-1 for zero-indexing)
	lw t0, 0(sp)
	la t1, gcd_expected_results
	slli t0, t0, 2
	add  t0, t0, t1 #base plus offset
	lw   t0, 0(t0)

	# check return value
	bne a0, t0, _fail_gcd

	_pass_gcd:
	la a0, g_passmsg
	addi a7, x0, 4
	ecall
    beq x0, x0, _test_gcd_looptrailer

	_fail_gcd:
	la a0, g_failmsg
	addi a7, x0, 4
	ecall

    _test_gcd_looptrailer:
    # check s registers were saved
    jal ra, verifySRegisters
	
    # re-run the loop
	beq x0, x0, _test_gcd_next

	_test_gcd_done:
	addi sp, sp, 4 # give back space

    _nogcd:

	######################################################
	# do we want to test RELPRIME?
    la   t0, TEST_RELPRIME
    lw   t0, 0(t0)
    addi t0, t0, -1
    bne  t0, x0 _norelprime

	la t0, relprime_num_tests
	lw t0, 0(t0) #number of tests
	addi sp, sp, -4
	sw t0, 0(sp) #save num tests on stack

	_test_rp_next:
	# wipe everything
	jal ra, wipeTRegisters
	jal ra, wipeSRegisters

	# get test num off the stack
	lw t0, 0(sp)
	bge x0, t0 _test_rp_done #if num tests left is <= 0, stop.

	addi t0, t0, -1
	sw   t0, 0(sp)
	
	# set argument n
	la t1, relprime_inputs
	slli t0, t0, 2
	add  t0, t0, t1 #base plus offset
	lw   a0, 0(t0)
	jal ra, printRelPrimeMsg


	###########################################################
	#### CALL TO RELPRIME PROCEDURE (the one we're testing)  ##
    jal ra, relPrime
	###########################################################

	# print return value
	addi a7, x0, 1
	ecall

	# get test num off the stack (is num-1 for zero-indexing)
	lw t0, 0(sp)
	la t1, relprime_expected_results
	slli t0, t0, 2
	add  t0, t0, t1 #base plus offset
	lw   t0, 0(t0)

	# check return value
	bne a0, t0, _fail_rp
	
	_pass_rp:
	la a0, g_passmsg
	addi a7, x0, 4
	ecall
	beq x0, x0, _test_rp_looptrailer

	_fail_rp:
	la a0, g_failmsg
	addi a7, x0, 4
	ecall

    _test_rp_looptrailer:
    # check s registers were saved
    jal ra, verifySRegisters
	
    # re-run the loop
	beq x0, x0, _test_rp_next

	_test_rp_done:
	addi sp, sp, 4 # give back space

	_norelprime:

	# halt
	addi a7, x0, 10
	ecall


# prints "testing gcd a,b..." (a=a0, b=a1)
printGCDmsg:
	addi t0, a0, 0 #stash a0/a1 (ecalls don't mess with t regs)
	addi t1, a1, 0

	la a0, g_gcdtestmsg # print testing message
	addi a7, x0, 4 #print str
	ecall
	add  a0, x0, t0
	addi a7, x0, 1 #print int
	ecall
	la a0, g_comma
	addi a7, x0, 4 #print str
	ecall
	add  a0, x0, t1
	addi a7, x0, 1 #print int
	ecall
	la a0, g_dots
	addi a7, x0, 4 #print str
	ecall

	# put a0/a1 back
	addi a0, t0, 0
	addi a1, t1, 0
	jalr x0, 0(ra)

# prints "testing relPrime n..." (n=a0)
printRelPrimeMsg:
	addi t0, a0, 0 #stash a0 (ecalls don't mess with t regs)

	la a0, g_relprimemsg # print testing message
	addi a7, x0, 4 #print str
	ecall
	add  a0, x0, t0
	addi a7, x0, 1 #print int
	ecall
	la a0, g_dots
	addi a7, x0, 4 #print str
	ecall

	# put a0/a1 back
	addi a0, t0, 0
	jalr x0, 0(ra)

# subroutine to wipe all temp registers (NOT A PROCEDURE)
wipeTRegisters:
    addi a0, x0, -1
    addi a1, x0, -1
    addi a2, x0, -1
    addi a3, x0, -1
    addi a4, x0, -1
    addi a5, x0, -1
    addi a6, x0, -1
    addi a7, x0, -1
    addi t0, x0, -1
    addi t1, x0, -1
    addi t2, x0, -1
    addi t3, x0, -1
    addi t4, x0, -1
    addi t5, x0, -1
    jalr x0, 0(ra)

# subroutine to wipe all saved registers (NOT A PROCEDURE)
wipeSRegisters:
    addi s0, x0, -1
    addi s1, x0, -1
    addi s2, x0, -1
    addi s3, x0, -1
    addi s4, x0, -1
    addi s5, x0, -1
    addi s6, x0, -1
    addi s7, x0, -1
    addi s8, x0, -1
    addi s9, x0, -1
    addi s10, x0, -1
    addi s11, x0, -1
    jalr x0, 0(ra)

saveSRegisters:
    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10,40(sp)
    sw s11,44(sp)
    sw ra, 48(sp)
    jalr x0, 0(ra)

verifySRegisters:
    addi x31, x0, -1
    bne s0, x31, _vs_FAIL
    bne s1, x31, _vs_FAIL
    bne s2, x31, _vs_FAIL
    bne s3, x31, _vs_FAIL
    bne s4, x31, _vs_FAIL
    bne s5, x31, _vs_FAIL
    bne s6, x31, _vs_FAIL
    bne s7, x31, _vs_FAIL
    bne s8, x31, _vs_FAIL
    bne s9, x31, _vs_FAIL
    bne s10, x31, _vs_FAIL
    bne s11, x31, _vs_FAIL
    jalr x0, 0(ra)
_vs_FAIL:
	la a0, g_sreg_notpres #error message
    addi a1, x0, 0
	addi a7, x0, 55 # error dialog
	ecall
    # HALT for debugging
    addi a7, x0, 10 #exit
	ecall



restoreSRegisters:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10,40(sp)
    lw s11,44(sp)
    lw ra, 48(sp)
    addi sp, sp, 52
    jalr x0, 0(ra)
