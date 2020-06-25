LOG=-D LOG_0
CFLAGS=-pedantic -W -Wall -Wextra -g

SRC=src
NAME=toml2json

#gcc $(LOG) $(CFLAGS) -o $(NAME) $(SRC)/*.c

all:
	flex -o $(SRC)/lex.yy.c $(SRC)/$(NAME).l
	yacc -d -o $(SRC)/y.tab.c $(SRC)/$(NAME).y
	gcc -o $(NAME) $(CFLAGS) $(SRC)/*.c

clean:
	rm -rf $(BUILD)
