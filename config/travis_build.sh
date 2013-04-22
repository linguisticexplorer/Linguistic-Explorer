#!/bin/sh

# Set the configuration file for the DB
cp config/database.yml.travisCI config/database.yml

# Setup MySQL DB
mysql -e 'create database le_test;'