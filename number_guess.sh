#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

USER_INFO () {
echo -e "\nEnter your username:"
read USERNAME
# get user_id 
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'");

# if not found
if [[ -z $USER_ID ]]
then 
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
# insert username and return user_id but r
USER_ID=$(echo $($PSQL "INSERT INTO users(username) VALUES('$USERNAME') returning user_id") | sed -r 's/^([0-9]+).*/\1/' );
else
#if found
# get player info
PLAYER_INFO=$($PSQL "SELECT COUNT(guesses),MIN(guesses) FROM users FULL JOIN games USING(user_id) WHERE username='$USERNAME'")
echo $PLAYER_INFO | while IFS='|' read COUNT MIN
do 
# welcom message with highscore and total games played.
echo -e "\nWelcome back, $USERNAME! You have played $COUNT games, and your best game took $MIN guesses."
done
fi


}

GUESS_NUMBER () {
  NUMBER=$(( ($RANDOM % 1000)+1 ))
  #echo -e "\n$NUMBER" # for testing app
  GUESS_COUNT=0
  # add a while loop 
  # no need to define GUESS AT FIRST
  while [[ $GUESS != $NUMBER ]]
  do
  # if guess number not defined
  if [[ ! $GUESS ]]
  then
    # ask for input
    echo -e "\nGuess the secret number between 1 and 1000:"
    # get guess number. 
    read GUESS
    INTEGER_CHECK
  else
    if (( GUESS>NUMBER ))
    then
      # if it lower, print that
      echo -e "\nIt's lower than that, guess again:"
      # get guess number. 
    read GUESS
    INTEGER_CHECK
    else
      # if higher print
      echo -e "It's higher than that, guess again:"
      # get guess number. 
      read GUESS
      INTEGER_CHECK
    fi
  fi
  (( GUESS_COUNT++ ))
  done

  # print win message
  echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
  # insert game data in to games table.
  [[ $($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)") ]]
}

function INTEGER_CHECK {
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do 
  echo "That is not an integer, guess again:"
  read GUESS
  (( GUESS_COUNT++ ))
  done
}

USER_INFO
GUESS_NUMBER
