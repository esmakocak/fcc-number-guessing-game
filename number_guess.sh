#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

DISPLAY(){
    echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

    echo "Enter your username: "
    read USERNAME

    NAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

    #If this user didn't play the game before
    if [[ -z $NAME ]] 
    then
        echo -e "Welcome, $USERNAME! It looks like this is your first time here."
        INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')") 
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    else
        GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) from games where user_id = '$USER_ID'")
        BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = '$USER_ID'")
        echo -e "Welcome back, $USERNAME ! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
    GAME
}

GAME() {
    #secret number
    SECRET=$(( RANDOM % 1000+1 ))

    #count guesses
    TRIES=0

    GUESSED=0
    echo -e "Guess the secret number between 1 and 1000:"

    while [[ $GUESSED = 0 ]]; do
        read GUESS

        #if not a number
        if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        echo -e "\nThat is not an integer, guess again:"
        #if correct guess
        elif [[ $SECRET = $GUESS ]]; then
        TRIES=$(($TRIES + 1))
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
        #insert into db
        INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES('$USER_ID', '$TRIES')")
        GUESSED=1
        #if greater
        elif [[ $SECRET -gt $GUESS ]]; then
        TRIES=$(($TRIES + 1))
        echo -e "\nIt's higher than that, guess again:"
        #if smaller
        else
        TRIES=$(($TRIES + 1))
        echo -e "\nIt's lower than that, guess again:"
        fi
    done

  echo -e "\nThanks for playing :)\n"

 
}

DISPLAY
