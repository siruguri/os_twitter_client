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

First things first: let's get your Twitter account setup

* Click on "Input handle" at the top - we'll call this the _dashboard_
* Focus on the first row of green buttons for now.
* Click Get Bio
* In the drop down menu, click on Profile, and check it all looks a-ok.
* Go back to the dashboard, and click on Get Your Older Tweets
* Go to `http://localhost:5000/document_analyses/task_page`
* Click that first button - "Compute Document Universe"
* Go back to the profile now, it should have a bunch of awesome stats!

Now, let's see whom you are following, and what they are up to:

* In the dashboard, click on "Refresh whom you follow." Pro tip: this is correct grammar, and your open source Twitter client is therefore doing more than freeing you from Twitter's client shackles, it is helping you sound more edumacated!
* You might have to wait a few seconds - then, refresh the dashboard.
* Beneath the green buttons, it'll now list your number of friends, and say they don't have Tweets. Click on "Process them!"
* You should now see lots of jobs show up in your Sidekiq dashboard (path: `/sidekiq_ui/busy`)
* In the drop down menu, click on "Feed". Read to your heart's content!

## Deploying

Deploying is tricky because I don't want to document all the ways you can do it. Whatever you do though, you have to
know that your app requires two external services:

* A Postgres database, which is configured in production using the environment for the database name, username and password. See `.env.sample`
* A Redis server, which is expected to be listening at port 6379 (the Redis default) at the host specified by the environment variable `REDIS_HOST`

The sample Docker Compose file in `docker/scripts` shows a setup that builds a container for the app, one for the
Postgres database, one for the Sidekiq process, and expects one already to be there for the Redis server. It expects two variables to be set in the environment that runs Docker:

* the environment variable `BASE_DOCKER_COMPOSE_NETWORK` to find the Redis server on.
* the variable `TWITTERCLIENT_APP_PORT` to use as the one exposed into the container (mapping to the app's own internal port 5000)

Of course, when you use Docker, you have to remember that it's your responsibility to:

* Re build your containers if your bundle needs updating.
* Run migrations if your current deploy is behind on them.

Otherwise, restarting a container with a new version will cause your container to exit prematurely.

## Contributing

Ya know, pull requests, etc.

## License

I give this unto the world under the [MIT License](http://www.opensource.org/licenses/MIT).
