#!/bin/bash

#PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Generate random number between 1 and 1000
TARGET_NUMBER=$((RANDOM % 1000 + 1))
#echo $TARGET_NUMBER

#Ask for username
echo "Enter your username:"
read PLAYER_USERNAME

#Check for username 
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$PLAYER_USERNAME'; ")

if [[ -z $USERNAME ]]
then
	#If username is not located
	echo "Welcome, $PLAYER_USERNAME! It looks like this is your first time here."
else
	#if username is located
	VARIABLES=$($PSQL "SELECT games_played,best_game FROM users WHERE username = '$USERNAME';")

	IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$VARIABLES"
	echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#COUNTER
GUESS_NUMBER=-1
NUMBER_OF_GUESSES=0

#Start game
echo "Guess the secret number between 1 and 1000:"

until [[ $GUESS_NUMBER == $TARGET_NUMBER ]]
do
	
	read GUESS_NUMBER
	((NUMBER_OF_GUESSES++))
	
	if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
	then 
		echo "That is not an integer, guess again:"
		continue
	elif [[ $GUESS_NUMBER -gt $TARGET_NUMBER ]]
	then
		echo "It's lower than that, guess again:"
	elif [[ $GUESS_NUMBER -lt $TARGET_NUMBER ]]
	then
		echo "It's higher than that, guess again:"
	else
		echo  "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $TARGET_NUMBER. Nice job!"
		
	fi  
	
	
done

#Add or update users table
if [[ -z $USERNAME ]]
then
	#Add row to users table
	INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$PLAYER_USERNAME',1,$NUMBER_OF_GUESSES);")
else
	#variable values
	GAMES_PLAYED_RECORD=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
	BEST_GAME_PLAYED=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
	
	#updates values
	NEW_GAMES_PLAYED=$(($GAMES_PLAYED_RECORD + 1))
	
	if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME_PLAYED ]]
	then
		NEW_BEST_GAME=$NUMBER_OF_GUESSES
	else
		NEW_BEST_GAME=$BEST_GAME_PLAYED
	fi
	
	#UPDATE VALUES
	
	UPDATE_VALUES=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $NEW_BEST_GAME WHERE username = '$USERNAME';")
	
	
fi
