# mgpronote
=======
# MGSuivi based on Ruby on Rails Tutorial sample application

This application is based on
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](https://www.railstutorial.org/)
(6th Edition)
by [Michael Hartl](http://www.michaelhartl.com/).

## License

All rights are reserved for MG Suivi by the team MGTool.

## Clone sample version

If you plan to clone a sample empty version take the version 1.0

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ yarn add jquery@3.5.1
$ bundle install --without production
```

Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

## Basic git commands
Basic git usage [*Get the private github project*](https://github.com/sartorius/mgscore_appror)
```
$ git add .
$ git commit -m "comment"
$ git push -u origingithub master
$ git push heroku master
```

Please tag version directly in github.


## Current version
The current version
> Handle users
> Handle all rails security


## Deployment

Deployment on Heroky (we assume you have an Heroku account)
```
$ heroku login
$ heroku create
$ heroku run rails db:migrate
$ heroku run rails db:seed

$ heroku run rake db:migrate
$ heroku run rake db:seed
```

In case of issue
```
$ heroku logs --tails
```
