# Docker
To use this, we'll need to install various parts of Docker.

Get Started on:
* [Mac](https://docs.docker.com/mac/)
* [Linux](https://docs.docker.com/linux/)
* [Windows](https://docs.docker.com/windows/)

# Terraling-Docker

## Provision
Before we begin, we must set up our database. Since we're using docker, we have to provide MYSQL username and passwords to the Docker instance, using the `.env.db` file.

```yml
MYSQL_USER=someuser
MYSQL_ROOT_PASSWORD=somepassword
MYSQL_DATABASE=somedatabase
```

Furthermore, you'll have to modify the `config/database.yml`:

```yml
default:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: somedatabase
  pool: 5
  host: db
  username: someuser
  password: somepassword
  port: 3306
```
Where default is your environment.

## Run

To start, start the default docker machine you should have created earlier
```sh
$ docker-machine start default
```
And make sure your machines are properly connected to your terminal
```sh
$ eval $(docker-machine env default)
```
Then build the docker images (this may take a while)
```sh
$ docker-compose build
```
Once that's built, you can start them up and detach from them to have them running in the background.
```sh
$ docker-compose up -d
```
Now that your containers are up, you can go into your `web` machine and run a command, lets migrate our database, which is on another container.
```sh
$ docker-compose run web bundle exec rake db:create db:migrate db:schema:load
```
Now we can run the tests on the container
```sh
$ docker-compose run web bundle exec rake
```

## Stop it

To end the docker madness once and for all
```sh
$ docker-compose down
```
