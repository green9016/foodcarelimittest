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

* ...


###
### Installation on Mac OS.
###
# Initial Development Enviroment Installation

I recommend using direnv to configure project-specific environment variables.  This is a good way of following the 
[12-factor](https://12factor.net/) configuration pattern, which greatly simplifies deployment.

Installation instructions: 

[Homebrew](https://docs.brew.sh/Installation)

[RVM](https://rvm.io/rvm/install)

[NVM](https://github.com/creationix/nvm#installation)

```bash
brew install postgresql redis git direnv
rvm install 2.5.1
nvm install 8.11.1
```

After installing postgres and redis, you may want to set up launchd to start them automatically when your machine starts

Read what brew prints out after you install or type ```brew info postgres``` or whatever.

```bash
brew services start postgresql
brew services restart redis

```

This will create launchd homebrew.mxcl.whatever.plist files for these services in ~/Library/LaunchAgents.
You can start and stop these services with launchctl.

# Set Environment varialbles.
```bash
direnv allow
```

## Install Ruby libraries (gems)

When you create a new gemset, it may not contain Bundler.  Bundler is the dependency manager for ruby projects.

Install it like this

```bash
gem install bundler
```

Then install the gems this project uses. (Listed in the Gemfile, versions locked down in Gemfile.lock)

```bash
bundle install
```

## Install JavaScript libraries (packages)

Next install the project's JavaScript libraries.  (We prefer using node's package manager for this to using gems that
"add JavaScript X library to your rails project!".  Such gems often lag behind the upstream library and introduce more
complexity.  Rails seems to be moving towards using JS asset pipeline tools.  Let's move in that direction.) 

I've been using yarn for node package installation.  

```bash
brew install yarn --without-node

yarn install
```

## Set up the database

If this is your first time running Postgres, you will need to initialize a new database.

It's been a while since I've had to do this but I think the commands are: 

```bash
initdb /usr/local/var/postgres
createuser --superuser $USER
createdb $USER

```

Confirm that you can connect to Postgres by typing ```psql```.  You should see that version is 10.3. 

Now you can create the databases that back this application:

```bash
rake db:create:all db:migrate db:seed db:test:prepare
```

## Run the server

Start the app with ```rails server```.  Point your browser at dev.foodcare.com:3000.  You should see the landing page.

Log in as john.doe@example.com, using the initial password from the BOOTSTRAP_PASSWORD environment variable in your .envrc.

(In a live environment, you'll set BOOTSTRAP_PASSWORD using the heroku config command or perhaps a settings page like
https://dashboard.heroku.com/apps/foodcare-staging/settings )  Then change the password, promote John to admin, create
real users, and delete John Doe.  Currently the only way to become an admin is to run 

```ruby
User.where(email: 'john.doe@example.com').first.update_attributes!(admin: true)
```
at the Rails console.  In a live environment, you get there with

```bash
heroku run rails console --app foodcare-staging # or whatever the app name is.
```

## Run the tests

We use [rspec](http://rspec.info/) for unit testing and [cucumber](https://cucumber.io/) for integration testing.

From the command line, you can run the unit tests with ```rake spec``` and the integration tests with ```rake cucumber```
or both of them with just ```rake```.

I normally run the tests using [Rubymine](https://www.jetbrains.com/ruby/download), which I find excellent (but taste 
in editor can sometimes vary).

I **strongly** recommend keeping the tests passing and testing all new and modified code. In fact, I recommend 
writing tests before writing the code.  This practice, called 
[Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development) is described here.

If you abandon your tests, you will eventually create a swamp and become lost in it and you will be sad. So don't do that.

If the tests pass, congratulations!  You have probably set up your development environment correctly!

If tests fail, there is probably a problem.  The failing tests will give you a hint as to what that problem is.

## Hack

Write useful software.  How to do this is kind of beyond the scope of this document.

## Deploy

Once you have programmed something good (and your tests are passing), you probably want to put it somewhere that actual
customers can use it.  

The live, public-facing instances of this application are hosted on Heroku.

The command line tools for interacting with Heroku are quite good and well documented there are also web control panels
for a lot of stuff at heroku.com. 

This project is set up so that any code pushed to Github on the develop branch will be automatically tested by 
[CircleCI](https://circleci.com/gh/FoodCare/workflows/nutrition), then (if the tests pass), be deployed to our staging 
environment at https://foodcare-staging.herokuapp.com/ .

Staging is a place for your coworkers (ideally the ones who asked you to write the feature you just finished) to look at 
what you did and either approve it or ask for changes.

When everything on develop branch has been approved and you want to deploy to production, merge the develop branch into 
master and push it to Github.  CircleCI will test again, and if the tests pass, will deploy to production at 
https://app.foodcare.com

In order to keep develop clear of obstructions, I recommend following the "git flow" process or something similar.
New features or bugfixes are developed on a separate branch, then merged back to develop once they are complete and passing.  
This prevents a half-implemented feature from making develop un-deployable, which is a problem when priorities change 
suddenly (as they will).

[Here's an OK git flow explanation](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow).

There's a good tool to facilitate this process at https://github.com/petervanderdoes/gitflow-avh .
(The AVH fork is better than the original project.)
It's installable via homebrew:  ```brew install git-flow-avh```

In production, we run a "web dyno" which hosts our app and a "worker dyno" that runs a Sidekiq worker process.
The app communicates with the worker via a job queue stored in redis.  The Worker does work that takes too long to 
complete in the time limit for a request on Heroku (30 seconds or something).  Currently these tasks are: recalculating
recipes whose ingredients have changed, and sending email.  (Sending email doesn't normally take very long, but things
are not always normal.  If Sendgrid is having a bad day, we don't want (for instance) password reset requests to block 
on sending the email, get killed by the Heroku request timeout, show the user an error page, and never send the email.)
If a sidekiq job fails it will be retried many times with a gradually increasing delay between retries.  
Sidekiq is pretty tenacious.

## Importing Legacy Data

The legacy data is imported from a subset of the legacy app's tables copied from the old database.
These live in a schema called legacy that lives next to the main schema (called public).

The tables are copied from the old foodcare's production database using the script/load_legacy_data.sh script.

Once the legacy data is loaded, the importers can be run.  These invoked as rake tasks.
They live in lib/tasks/import.rake.

The rake task must be run by a heroku dyno for the target application.
The importers must be run in the order organizations, users, nutrients, foods, recipes.
the task import:all does this.
```heroku run rake  import:all --app foodcare-staging```
for example.

After the import is run, it is important to recalculate the recipe nutrition facts.
This is done with the import:recalculate task.  You might want to run this task with ```heroku run:detach``` because it could easily take more than an hour and you don't want a disconnection to kill your task.




## Described by sdragon
Sdragon did following steps to Install.

# setup environment variables to run following.
```bash
direnv allow
```
# install rails libraries
```bash
gem install bundler
bundle install
```
# install node libraries

```bash
brew install yarn --without-node
yarn install
```

# init database
```bash

```

# run server
```bash
rails s
```