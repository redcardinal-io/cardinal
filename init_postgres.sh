#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<- EOSQL
  -- Create Cardinal admin user
  create user redcardinal_admin login createrole createdb replication bypassrls;
  
  -- Cardinal auth administrator
  create user redcardinal_auth_admin noinherit createrole login noreplication password 'redcardinal_auth_admin';
  
  -- Create schema and set permissions
  create schema if not exists $DB_NAMESPACE authorization redcardinal_auth_admin;

  -- Grant necessary permissions
  grant create on database postgres to redcardinal_auth_admin;

  -- set search_path to auth admin
  alter user redcardinal_auth_admin set search_path = '$DB_NAMESPACE';
EOSQL
