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
    addi sp, sp, -8
    sw ra, 0(sp) 

    sw a0, 0(sp) #a0 = a
    sw a1, 4(sp) #a1 = b

    bne a0, 0, ELSE

    addi a0, a1, 0 #return b

ELSE:

    beq a1, 0, RETURN_A

    ble a0, a1, ELSE_B
    sub a0, a0, a1

ELSE_B:
    sub a1, a1, a0

RETURN_A:
    
    lw ra, 0(sp)
    addi sp, sp, 8
    jalr x0, 0(ra)

##############################################################
# PROCEDURE - relPrime(n)
##############################################################
relPrime:
    #TODO: implement this procedure here