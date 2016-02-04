CC = arm-xilinx-linux-gnueabi-gcc
CFLAGS = -O0 -DJSMN_PARENT_LINKS=1

OBJ = main.o parser.o jsmn.o ip.o

tico: $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@

main.o: main.c parser.h jsmn.h ip.h
	$(CC) -c $(CFLAGS) -o $@ $<

ip.o: ip.c ip.h
	$(CC) -c $(CFLAGS) -o $@ $<

parser.o: parser.c parser.h jsmn.h
	$(CC) -c $(CFLAGS) -o $@ $<

jsmn.o: jsmn.c jsmn.h
	$(CC) -c $(CFLAGS) -o $@ $<

test-parser: test/test-parser.c parser.c jsmn.c parser.h jsmn.h
	gcc -I. -o test/$@ $^

test-comparison: test/test-comparison.c parser.c jsmn.c parser.h jsmn.h
	gcc -I. -o test/$@ $^

test: test-parser test-comparison
	cd test; sh test.sh; cd ..

.PHONY : clean
clean:
	rm -f tico test/test-parser test/test-comparison $(OBJ)