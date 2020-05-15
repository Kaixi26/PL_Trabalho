LOG=-D LOG_0
CFLAGS=-pedantic -W -Wall -Wextra

SRC=src
NAME=mkfromtemplate

exe:
	flex -o $(SRC)/$(NAME).c $(SRC)/$(NAME).l
	gcc $(LOG) $(CFLAGS) -o $(NAME) $(SRC)/*.c

clean:
	rm $(SRC)/$(NAME).c
	rm $(NAME)
