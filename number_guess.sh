#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

LENGTH=${#USERNAME}

#Username length
if [[ "$LENGTH" -gt 22 ]]

  then
    echo "Username too long"

  else
  #get username from database
    INSERT_USERNAME=$($PSQL "SELECT username FROM guesses WHERE username = '$USERNAME'")
    
    #if it's a new user
    if [[ -z $INSERT_USERNAME ]]
    then
      INSERT_USERNAME=$($PSQL "INSERT INTO guesses (username) VALUES ('$USERNAME')")
      echo "Welcome, $USERNAME! It looks like this is your first time here."

    #if it's a returning user
    else    
      DETAILS=$($PSQL "SELECT games_played, best_game FROM guesses WHERE username = '$USERNAME'")
      echo "$DETAILS" | while IFS="|" read GAMES_PLAYED BEST_GAME
      do echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      done
    fi

  #generate random number <=1000
  NUMBER=$(( $RANDOM % 1000 ))
  echo $NUMBER

fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUMBER_OF_GUESSES=1

until [[ "$GUESS" -eq "$NUMBER" ]]
do

  #until they guess an interger
  until [[ $GUESS =~ ^[0-9]+$ ]] ;
  do
  echo "That is not an integer, guess again:"
  read GUESS
  done

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
  
  if [[ "$GUESS" -lt "$NUMBER" ]]
    then
      echo "It's higher than that, guess again:"
  elif [[ "$GUESS" -gt "$NUMBER" ]]
    then
      echo "It's lower than that, guess again:"
  fi

read GUESS
done


BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username = '$USERNAME'")
if [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
  then
  BEST_GAME=$($PSQL "UPDATE guesses SET best_game = '$NUMBER_OF_GUESSES' WHERE username = '$USERNAME'")
fi

NUMBER_OF_GAMES=$($PSQL "SELECT games_played FROM guesses WHERE username = '$USERNAME'")
NUMBER_OF_GAMES=$((NUMBER_OF_GAMES + 1))
NUMBER_OF_GAMES=$($PSQL "UPDATE guesses SET games_played = $NUMBER_OF_GAMES WHERE username = '$USERNAME'")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

