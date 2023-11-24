#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  PLAYER_RECORD=$($PSQL "SELECT COUNT(guesses), MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "$PLAYER_RECORD" | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
NUMBER=$(($RANDOM % 1000 + 1))
COUNTER=0
echo Guess the secret number between 1 and 1000:
echo $NUMBER
until [[ $GUESS -eq $NUMBER ]]
do
  ((COUNTER++))
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done
INSERT_GAME=$($PSQL "INSERT INTO games(user_id,guesses) VALUES($USER_ID, $COUNTER)")
echo "You guessed it in $COUNTER tries. The secret number was $NUMBER. Nice job!"
exit
