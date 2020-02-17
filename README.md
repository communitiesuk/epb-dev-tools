# EPB Dev Tools

The Energy Performance of Buildings Register service consists of several 
distinct applications.

* authentication server
* epb api
* epb frontend

These dev tools give us a stable environment where all the applications are
preconfigured to just work.

## Up and Running

**Requirements**

* docker
* docker-compose
* bash 4
* git

**Getting up and running**

```shell script
$ make install
```

## Shutting down

```shell script
$ docker-compose down
```

## Resetting the environment

To reset the environment (reset db, re-seed db) run the following command

```shell script
$ make reset
```

## Updating all repositories

To update the codebases just run the command below, this will run git pull in
all the codebases.

```shell script
$ make pull
```

## Direct SQL access

You can connect to the local postgres dbs for each service by running

```shell script
$ make sql-register-api
OR
$ make sql-auth-server
```

## Tailing the logs

To tail the logs for ALL SERVICES run the following (CTRL + C to quit)

```shell script
$ make logs
```
