#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# pg_dump salon db `pg_dump -cC --inserts -U freecodecamp salon > salon.sql`
# read data from pg_dump `psql -U postgres < salon.sql`

# $PSQL "drop table if exists customers cascade;"
# $PSQL "drop table if exists appointments cascade;"
# $PSQL "drop table if exists services cascade;"

# $PSQL "create table if not exists customers( \
#   customer_id serial primary key, \
#   phone varchar unique, \
#   name varchar(30) not null);"

# $PSQL "create table if not exists services( \
#   service_id serial primary key, \
#   name varchar not null);"

# $PSQL "create table if not exists appointments( \
#   appointment_id serial primary key, \
#   customer_id int references customers(customer_id) not null, \
#   service_id int references services(service_id) not null, \
#   time varchar);"

# $PSQL "insert into services (name) values ('Shaving'), ('Washing hair'), ('Dying hair');"

MAIN_MENU() {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n~~~ Welcome to the salon ~~~\n"
  echo -e "\nHere is the list of our services:"

  SERVICES=$($PSQL "select service_id, name from services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWhat type of service would you like to choose?"
  read SERVICE_ID_SELECTED
  # get the service
  SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED;")
  # if service does not exist
  if [[ -z $SERVICE_ID ]]
  then
    # return to the main menu
    MAIN_MENU "Unfortunately, we don't provide this type of service."
  else
    CHOOSE_SERVICE
  fi
}

CHOOSE_SERVICE() {
  echo -e "\nTell us your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nTell us your name:"
    read CUSTOMER_NAME
    $PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  fi
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
  echo -e "\nAt what time would you like to have an appointment?"
  read SERVICE_TIME
  $PSQL "insert into appointments (customer_id, service_id, time) values ('$CUSTOMER_ID', '$SERVICE_ID', '$SERVICE_TIME');"
  SERVICE_SUMMARY=$($PSQL "select services.name service_name, appointments.time appointment_time, customers.name customer_name from customers inner join appointments using (customer_id) inner join services using (service_id) where service_id=$SERVICE_ID and customer_id=$CUSTOMER_ID;")
  echo "$SERVICE_SUMMARY" | while read SERVICE_NAME BAR APPOINTMENT_TIME BAR CUSTOMER_NAME
  do
    echo -e "\nI have put you down for a $SERVICE_NAME at $APPOINTMENT_TIME, $CUSTOMER_NAME."
  done
}


MAIN_MENU