#!/bin/bash --login

GEMSET="sleepingkingstudios-tools"

for version in "2.0.0" "2.1.8" "2.2.4" "2.3.0"
do
  echo 'Running specs for '$version':'
  rvm $version@$GEMSET --create
  rvm $version@$GEMSET exec gem install bundler
  rvm $version@$GEMSET exec bundle install --quiet
  rvm $version@$GEMSET exec rspec --format=progress
done
