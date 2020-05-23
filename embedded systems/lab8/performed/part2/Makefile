CC = gcc

CFLAGS += -Wall
LIBS += -lm

OBJ = part2.o audio.o physical.o
DEPS = audio.h physical.h


%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

main: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

debug_main: $(OBJ)
	$(CC) -g -o $@ $^ $(CFLAGS) $(LIBS)

clean:
	rm -f *.o main
