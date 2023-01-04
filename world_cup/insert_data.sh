#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "drop table if exists teams cascade;"
$PSQL "drop table if exists games cascade;"

$PSQL "create table if not exists teams(\
team_id serial primary key,\
name text unique not null);"

$PSQL "create table if not exists games(\
game_id serial primary key,\
year int not null,\
round varchar not null,\
winner_goals int not null,\
opponent_goals int not null,\
winner_id int references teams(team_id) not null,\
opponent_id int references teams(team_id) not null);"

# get team id
# if null, inser into teams

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    if [[ -z $WINNER_ID ]]
    then
      $PSQL "insert into teams (name) values ('$WINNER');"
      WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER';")
    fi

    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "insert into teams (name) values ('$OPPONENT');"
      OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT';")
    fi
    $PSQL "insert into games (year, round, winner_goals, opponent_goals, winner_id, opponent_id) values ($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID);"
  fi
done
