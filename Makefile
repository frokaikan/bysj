CC = gcc
CXX = g++
FOR = gfortran
FLAGS = -O3 -g3

.PHONY : all
all :
	python makeit.py make
	
.PHONY : test
test :
	python makeit.py test
	
.PHONY : clear
clear :
	python makeit.py clear