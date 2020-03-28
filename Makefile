LOG=-d LOG_1
CFLAGS=--std=c11 -pedantic -W -Wall -Wextra

SRC=src
NAME=mkfromtemplate

$(NAME):
	flex -o $(SRC)/$(NAME).c $(SRC)/$(NAME).l
	gcc $(LOG) $(CFLAGS) -o $(NAME) $(SRC)/*.c

clean:
	rm $(SRC)/$(NAME).c
	rm $(NAME)