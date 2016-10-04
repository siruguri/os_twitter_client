# Open source Twitter client

## Installation
* Do the Rails stuff: bundle, schema:load or migrate
* Set some environment variables in `.env` in Rails root: see `.env.sample`
* Run tests: `rake test`
* Get redis, run redis-server
* Get foreman?
* Run everything: `foreman start -f Procfile.dev`
* Start here: `http://localhost:5000/twitter/feed`
* Sign up, login
* Got a Twitter account? Authorize your app with it.

## Using this thing

* Click on "Input handle" at the top - we'll call this the _dashboard_
* Click Get Bio
* In the drop down menu, click on Profile, and check it all looks a-ok.
* Go back to the dashboard, and click on Get Your Older Tweets
* Go to `http://localhost:5000/document_analyses/task_page`
* Click that first button - "Compute Document Universe"
* Go back to the profile now, it should have a bunch of awesome stats!

## Deploying

Deploying is tricky because I don't want to document all the ways you can do it. Whatever you do though, you have to
know that your app requires two external services:

* A Postgres database, which is configured in production using the environment for the database name, username and password. See `.env.sample`
* A Redis server, which is expected to be listening at port 6379 (the Redis default) at the host specified by the environment variable `REDIS_HOST`

The sample Docker Compose file in `docker/scripts` shows a setup that builds a container for the app, one for the
Postgres database, one for the Sidekiq process, and expects one already to be there for the Redis server. It expects two variables to be set in the environment that runs Docker:

* the environment variable `BASE_DOCKER_COMPOSE_NETWORK` to find the Redis server on.
* the variable `TWITTERCLIENT_APP_PORT` to use as the one exposed into the container (mapping to the app's own internal port 5000)

## Contributing

Ya know, pull requests, etc.
