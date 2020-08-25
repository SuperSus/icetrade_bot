# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
docker-machine create --driver=digitalocean --digitalocean-access-token=DO_ACCESS_TOKEN --digitalocean-size=1gb ice-trade

eval $(docker-machine env ice-trade)

dc -f docker-compose.prod.yml build
dc -f docker-compose.prod.yml up
dc -f docker-compose.prod.yml exec web rails db:migrate
* ...
