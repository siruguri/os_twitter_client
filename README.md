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

## Contributing

Ya know, pull requests, etc.
