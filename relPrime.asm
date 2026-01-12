#**********************************************************************
# CSSE 232 Homework Assignment 
# Rose-Hulman Institute of Technology
#
# NAME: Reagan Lorenzen
# DATE: 1/12/2026
#
#**********************************************************************

# Some globals to tell the test file where to find this stuff.
.global gcd
.global relPrime
.globl TEST_GCD
.globl TEST_RELPRIME

.data

# set this to 1 if you want to test gcd
TEST_GCD:      .word 1

# set this to 1 if you want to test relPrime
TEST_RELPRIME: .word 1


.text

# This causes a few tests to run.  Don't remove this!
jal x0, runtests

##############################################################
# PROCEDURE - gcd(a, b)
##############################################################
gcd:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp) #a0 = a
    sw a1, 8(sp) #a1 = b

    beq a0, x0, RETURN_B

WHILE_LOOP:
    beq a1, x0, EXIT
    bgt a0, a1, GREATER_A
    sub a1, a1, a0
    j WHILE_LOOP
    
GREATER_A:
    sub a0, a0, a1
    j WHILE_LOOP
    
EXIT:
    lw ra, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)

RETURN_B:
    addi a0, a1, 0
##############################################################
# PROCEDURE - relPrime(n)
##############################################################
relPrime:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp) #a0 = n
    addi t0, x0, 2 #t0 = m = 2
    sw t0, 8(sp) #store on stack 
    
    WHILE:
    lw a0, 4(sp) #a0 = n
    lw a1, 8(sp) #a1 = m
    jal ra, gcd #call gcd(n, m)
    
    addi t0, x0, 1 # t0 = 1
    beq a0, t0, DONE #if gcd == 1, return m 
    
    lw t1, 8(sp) #t1 = m
    addi t1, t1, 1 #m += 1
    sw t1, 8(sp) # t1 = m + 1
    jal x0, WHILE
    
    DONE:
    lw a0, 8(sp) #a0 = m
    lw ra, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)
