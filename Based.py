#!/usr/bin/env python3

from pwn import *
import socket

# Connection to server
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("2019shell1.picoctf.com", 25180))
except Exception:
    print("Connection failed")

text = s.makefile('rb')

def Task_1(linijka,tekst):
    tablica = linijka.split(' ')  # split this line to single words
    x = tablica.index('the')  # finding index of last word before our "binary text"
    y = tablica.index('as')  # finding index of first word after our "binary text"
    tablica = tablica[x + 1:y]  # cut only binary elements from list
    dlugosc_tablicy = len(tablica)
    i = 0
    wynik = ''

    # converting list elements from string "binary" elements to letters and save it in string
    while i != dlugosc_tablicy:
        wynik += chr(int(tablica[i], base=2))
        i += 1
    wynik += "\n"

    # finding input place
    tekst = text.readline()
    s.send(wynik.encode("utf-8"))

def Task_2(linijka,tekst):
    tablica = linijka.split(' ')
    x = tablica.index('the')
    y = tablica.index('as')
    tablica = tablica[x + 2:y]
    dlugosc_tablicy = len(tablica)
    i = 0
    wynik = ''

    while i != dlugosc_tablicy:
        wynik += chr(int(tablica[i], base=8))
        i += 1
    wynik += "\n"
    tekst = text.readline()
    s.send(wynik.encode("utf-8"))

def Task_3(linijka,teskt):
    tablica = linijka.split(' ')
    x = tablica.index('the')
    y = tablica.index('as')
    tablica = tablica[x + 1:y]
    wartosc = tablica[0]
    tablica = []
    j = 0

    # converting data from string to list of letters in hex type
    for j in range(0, len(wartosc), 2):
        tablica.append(wartosc[j] + wartosc[j+1])
    i = 0
    dlugosc_tablicy = len(tablica)
    wynik = ''
    while i != dlugosc_tablicy:
        wynik += chr(int(tablica[i], base=16))
        i += 1
    wynik += "\n"
    tekst = text.readline()
    s.send(wynik.encode("utf-8"))
# receiving text from console
while True:
    tekst = text.readline()
    linijka = repr(tekst)
    print(linijka)

    # finding line with first task
    if "Please give the" in linijka:
        Task_1(linijka,tekst)

    # finding line with second task
    if "Please give me the  " in linijka:
        Task_2(linijka,tekst)

    # finding line with third task (to find difference between second and third task we take 6 and 7 to searching string
    # all data starts on 6 or 7
    if "Please give me the 6" in linijka:
        Task_3(linijka,tekst)
    elif "Please give me the 7" in linijka:
        Task_3(linijka,tekst)

    if "WRONG!" in linijka:
        break

    if "picoCTF" in linijka:
        break