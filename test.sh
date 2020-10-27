#!/bin/bash
make
for FILE in tests/*; do
	./parser < $FILE;
done
make clean
