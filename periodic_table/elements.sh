#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

ELEMENT_TAG=$1

if [[ -z $ELEMENT_TAG ]]
then
  echo "Please provide an element as an argument."
else
  ELEMENTS=$($PSQL "select \
  e.atomic_number atomic_number, \
  e.name as name, \
  e.symbol, \
  t.type, \
  p.atomic_mass, \
  p.melting_point_celsius, \
  p.boiling_point_celsius \
  from elements e \
  left join properties p using (atomic_number) \
  left join types t using (type_id) \
  where e.symbol = '$ELEMENT_TAG' \
  or e.name = '$ELEMENT_TAG' \
  or e.atomic_number = CAST(REGEXP_REPLACE(COALESCE('$ELEMENT_TAG','0'), '[^0-9]+', '0', 'g') AS INTEGER);")

  echo "$ELEMENTS" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
  do
    if [[ -z $ATOMIC_NUMBER || -z $ATOMIC_NUMBER || -z $NAME || -z $SYMBOL || -z $TYPE || -z $ATOMIC_MASS || -z $MELTING_POINT || -z $BOILING_POINT ]]
    then
      echo "I could not find that element in the database."
    else
      echo "The element with atomic number $TRIM_SPACES$ATOMIC_NUMBER is $TRIM_SPACES$NAME ($TRIM_SPACES$SYMBOL). It's a $TRIM_SPACES$TYPE, with a mass of $TRIM_SPACES$ATOMIC_MASS amu. $TRIM_SPACES$NAME has a melting point of $TRIM_SPACES$MELTING_POINT celsius and a boiling point of $TRIM_SPACES$BOILING_POINT celsius."
    fi
  done
fi

TRIM_SPACES() {
  $(echo $1 | sed -r 's/^* | *$//')
}
