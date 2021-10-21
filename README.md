# Instruction

* Install electrum and run daemon
* Clone this repo
* Run `bundle install`
* Create DB with `bin/rails db:create db:migrate`
* Rename `.env.example` to `.env` and change variables
* Run cron job with `whenever --update-crontab --set environment='development'`
* Run server `bin/rails s`
