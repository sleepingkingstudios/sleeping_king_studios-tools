#!/bin/bash --login

GEMSET="sleepingkingstudios-tools"

for version in "2.2.7" "2.3.4" "2.4.1"
do
  echo 'Running specs for '$version':'
  rvm $version@$GEMSET --create
  rvm $version@$GEMSET exec gem install bundler
  rvm $version@$GEMSET exec bundle install --quiet
  rvm $version@$GEMSET exec rspec --format=progress
done
