#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
$PSQL "alter table properties rename column weight to atomic_mass;"
$PSQL "alter table properties rename column melting_point to melting_point_celsius;"
$PSQL "alter table properties rename column boiling_point to boiling_point_celsius;"

$PSQL "alter table properties alter column melting_point_celsius set not null;"
$PSQL "alter table properties alter column boiling_point_celsius set not null;"

$PSQL "alter table elements add constraint elements_symbol_unique unique (symbol);"
$PSQL "alter table elements add constraint elements_name_unique unique (name);"

$PSQL "alter table elements alter column symbol set not null;"
$PSQL "alter table elements alter column name set not null;"

$PSQL "alter table properties add foreign key (atomic_number) references elements(atomic_number);"
$PSQL "create table types (type_id int primary key, type varchar not null);"

$PSQL "insert into types (type_id, type) values (1, 'nonmetal'), (2, 'metal'), (3, 'metalloid');"

$PSQL "alter table properties add column type_id int references types(type_id) default 1 not null;"

$PSQL "update elements set symbol=initcap(symbol);"
$PSQL "alter table properties alter column atomic_mass type real;"

FLOURINE=$($PSQL "select name from elements where atomic_number=9;")
if [[ -z $FLOURINE ]]
then
  $PSQL "insert into elements (atomic_number, symbol, name) values (9, 'F', 'Fluorine');"
  $PSQL "insert into properties (atomic_mass, atomic_number, melting_point_celsius, boiling_point_celsius, type_id) values \
  (18.998, 9, -220, -188.1, 1);"
fi

NEON=$($PSQL "select * from elements where atomic_number=10;")
if [[ -z $NEON ]]
then
  $PSQL "insert into elements (atomic_number, symbol, name) values (10, 'Ne', 'Neon');"
  $PSQL "insert into properties (atomic_mass, atomic_number, melting_point_celsius, boiling_point_celsius, type_id) values \
  (20.18, 10, -248.6, -246.1, 1);"
fi

# $PSQL "alter table properties rename column weight to atomic_mass;"
# $PSQL "alter table properties rename column weight to atomic_mass;"
# $PSQL "alter table properties rename column weight to atomic_mass;"
