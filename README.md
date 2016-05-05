# Middleman Book Template

## About

This is a project template for the
[Middleman Static Site Generator](https://middlemanapp.com/) optimized for
creating digital books. It is based on the
[Proteus Middleman Template](https://github.com/thoughtbot/proteus-middleman),
and has been extended by the team at Getty Publications.

## About Middleman

Middleman is a static site generator built in Ruby. This makes it a great fit
for projects that may end up as a Ruby on Rails app. Its minimalistic structure
makes it very easy to work with, and includes support for deploying to Github
Pages.

## Includes

* [HAML](http://haml.info):
  Simple template markup
* [Coffeescript](http://coffeescript.org):
  Write javascript with simpler syntax
* [Sass (LibSass)](http://sass-lang.com):
  CSS with superpowers
* [Bourbon](http://bourbon.io):
  Sass mixin library
* [Neat](http://neat.bourbon.io):
  Semantic grid for Sass and Bourbon
* [Bitters](http://bitters.bourbon.io):
  Scaffold styles, variables and structure for Bourbon projects.
* [Middleman Live Reload](https://github.com/middleman/middleman-livereload):
  Reloads the page when files change
* [Middleman Deploy](https://github.com/karlfreeman/middleman-deploy):
  Deploy your Middleman build via rsync, ftp, sftp, or git (deploys to Github Pages by default)

## Getting Started

This project is designed for use as a [Middleman template](https://middlemanapp.com/advanced/project_templates/).
To get started, first make sure you have recent versions of Ruby and Middleman installed.

Then create a new project by running this command:
```
middleman init my_book --template=gettypubs/middleman-book-template
```
This will create a `my_book` directory inside the current folder that contains everything you need to get started.

### Recommended

Consider adding this project to version control by running `git init` inside this folder after initializing.

## Useful Commands

Install dependencies:
```
bundle install
```

Run the server
```
bundle exec middleman
```

Deploy to Github Pages
```
bundle exec middleman deploy
```

Build a PDF
```
bundle exec middleman build -e pdf
```

## Directories

Stylesheets, fonts, images, and JavaScript files go in the `/source/assets/` directory.
Vendor stylesheets and JavaScripts should go in each of their `/vendor/` directories.
