#!/bin/bash

# Creates necessary files.
make

# Iterates through test cases to check lexer and parser.
for FILE in tests/*; do
	./parser < $FILE;
done

# Removes all the created files
make clean
