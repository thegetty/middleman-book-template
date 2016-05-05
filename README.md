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

Set up your project in your code directory
```
git clone https://github.com/thoughtbot/proteus-middleman.git your-project-folder
cd your-project-folder
git remote rm origin
git remote add origin your-git-url
```

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

Or install the [Proteus gem](https://github.com/thoughtbot/proteus) and enjoy some shortcuts.

## Directories

Stylesheets, fonts, images, and JavaScript files go in the `/source/assets/` directory.
Vendor stylesheets and JavaScripts should go in each of their `/vendor/` directories.

## Credits

[![thoughtbot](http://images.thoughtbot.com/bourbon/thoughtbot-logo.svg)](http://thoughtbot.com)

thoughtbot Middleman Starter is maintained and funded by [thoughtbot, inc](http://thoughtbot.com). Thank you to all of [the contributors](https://github.com/thoughtbot/proteus-middleman/contributors)!

## License

Copyright © 2014–2015 [thoughtbot, inc](http://thoughtbot.com). thoughtbot Middleman Starter is free software, and may be redistributed under the terms specified in the [license](https://github.com/thoughtbot/bourbon/blob/master/LICENSE.md).
