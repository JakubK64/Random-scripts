#!/usr/bin/env python3
from pwn import *
from Crypto.Util.number import inverse

# Connection to server
try:
    r = remote("2019shell1.picoctf.com", 61751)
except:
    print("Connection failed")

def GetQ(text):
    # change new line character to white character to split string easier
    text = text.replace("\\n"," ")

    # split string for list of single words
    list_lines = text.split(' ')

    # Finding index of "q" after which we have value of q
    tmp = list_lines.index("q")

    # Reading 2 elements after "q" which is always value o q
    q = list_lines[tmp+2]

    # Parse value of "q" from string to int
    q = int(q)
    return q

def GetP(text):
    text = text.replace("\\n"," ")
    list_lines = text.split(' ')
    tmp = list_lines.index('p')
    p = list_lines[tmp+2]
    p = int(p)
    return p

def GetN(text):
    text = text.replace("\\n", " ")
    list_lines = text.split(' ')
    tmp = list_lines.index('n')
    n = list_lines[tmp+2]
    n = int(n)
    return n

def GetE(text):
    text = text.replace("\\n", " ")
    list_lines = text.split(' ')
    tmp = list_lines.index('e')
    e = list_lines[tmp+2]
    e = int(e)
    return e

def GetPlainText(text):
    text = text.replace("\\n", " ")
    list_lines = text.split(' ')
    tmp = list_lines.index('plaintext')
    plaintext = list_lines[tmp+2]
    plaintext = int(plaintext)
    return plaintext

def GetCipherText(text):
    text = text.replace("\\n", " ")
    list_lines = text.split(' ')
    tmp = list_lines.index('ciphertext')
    ciphertext = list_lines[tmp+2]
    ciphertext = int(ciphertext)
    return ciphertext

# Sending answer to server
def SendAnswer(r,TaskNumber,answer=0):
    # Get line when we send answer for question: IS IT POSSIBLE and FEASIBLE?
    r.recvuntil("(Y/N):")

    # Send answer from prepered earlier list
    r.sendline(yn[TaskNumber-1])

    # Check if answer for first question is "no". If it is "no" there will be no second question to answer.
    if yn[TaskNumber-1] == "n" or answer == 0:
        return

    # Get until line when you need to send answer for task
    r.recvuntil(":")

    # Parse answer from int to string and send it to server
    r.sendline(str(answer))

def Task1(r):
    # Receive until we get parameters for task
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")

    # Parse object to simple string
    lines = str(lines)

    # Get value of "q" parameter from text
    q = GetQ(lines)

    # Get value of "p" parameter from text
    p = GetP(lines)

    # Solve task - produce n
    n = p * q

    # Send answer to server
    SendAnswer(r,1,n)

    # log info that Task is done to console
    log.info("Task 1 done!")

def Task2(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    lines = str(lines)
    p = GetP(lines)
    n = GetN(lines)
    q = n / p
    q = int(q)
    SendAnswer(r,2,q)
    log.info("Task 2 done!")

def Task3(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    SendAnswer(r,3)
    log.info("Task 3 done!")

def Task4(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    lines = str(lines)
    p = GetP(lines)
    q = GetQ(lines)
    totient = (p-1) * (q-1)
    totient = int(totient)
    SendAnswer(r,4,totient)
    log.info("Task 4 done!")

def Task5(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    lines = str(lines)
    PT = GetPlainText(lines)
    e = GetE(lines)
    n = GetN(lines)
    CT = pow(PT,e,n)
    CT = int(CT)
    SendAnswer(r,5,CT)
    log.info("Task 5 done!")

def Task6(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    SendAnswer(r,6)
    log.info("Task 6 done!")

def Task7(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    lines = str(lines)
    q = GetQ(lines)
    p = GetP(lines)
    e = GetE(lines)
    totient = (p-1) * (q-1)
    from Crypto.Util.number import inverse
    d = inverse(e,totient)
    d = int(d)
    SendAnswer(r,7,d)
    log.info("Task 7 done!")

def Task8(r):
    lines = r.recvuntil("##### PRODUCE THE FOLLOWING ####")
    lines = str(lines)
    p = GetP(lines)
    CT = GetCipherText(lines)
    e = GetE(lines)
    n = GetN(lines)
    q = int(n // p) # To get good version of flag we need to divide numbers with floored-division operator
    t = int((p-1) * (q-1))
    d = int(inverse(e,t))
    log.info("Task 8 done!")
    log.info("Decoding the flag...")
    tmp_flag = pow(CT,d,n)
    tmp_flag = hex(tmp_flag)[2:]
    Flag = bytes.fromhex(tmp_flag)
    print(Flag.decode("ASCII"))


# prepared list of answers for question: Is this possible and feasible?
yn = ["y","y","n","y","y","n","y","y"]

r.recvuntil("#### NEW PROBLEM ####")
Task1(r)
r.recvuntil("#### NEW PROBLEM ####")
Task2(r)
r.recvuntil("#### NEW PROBLEM ####")
Task3(r)
r.recvuntil("#### NEW PROBLEM ####")
Task4(r)
r.recvuntil("#### NEW PROBLEM ####")
Task5(r)
r.recvuntil("#### NEW PROBLEM ####")
Task6(r)
r.recvuntil("#### NEW PROBLEM ####")
Task7(r)
r.recvuntil("#### NEW PROBLEM ####")
Task8(r)

