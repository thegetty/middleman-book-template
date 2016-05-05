# Middleman Book Template

- [About](#about)
- [Included Libraries](#included-libraries)
- [Getting Started](#getting-started)
- [Useful Commands](#useful-commands)
- [Project Structure](#project-structure)
- [Content Authoring](#content-authoring)

## About

This is a project template for the
[Middleman Static Site Generator](https://middlemanapp.com/) optimized for
creating digital books. It is based on the
[Proteus Middleman Template](https://github.com/thoughtbot/proteus-middleman),
and has been extended by the team at Getty Publications.

## Included Libraries

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

This project is designed for use as a
[Middleman template](https://middlemanapp.com/advanced/project_templates/). To
get started, first make sure you have recent versions of Ruby and Middleman
installed.

### Setup on OSX

For best results, we recommend that you have a ruby development environment set
up on your machine. Assuming you are using a mac,
[Thoughtbot's Laptop Script](https://github.com/thoughtbot/laptop) is an
excellent place to start. Using this script removes the need to do any of the
steps below. If you plan to set up manually, install the following tools (in
this order):

- Xcode Command-line tools (`xcode-select --install`), or all of Xcode if
  running on Mac OSX 10.8 or lower
- [Homebrew package manager](http://brew.sh)
  `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
- [Rbenv](https://github.com/rbenv/rbenv) and ruby-build to manage different versions of Ruby  
  After install, run `rbenv init` to setup  
  `brew install rbenv ruby-build`  
- Ruby 2.3.1: `rbenv install 2.3.1` (may take some time)
- Use this version of ruby everywhere with `rbenv global 2.3.1`
- Finally, run `gem install bundler` to install Ruby's Bundler tool. This tool
  will install the remaining dependencies automatically.
  
### Other Dependencies

To make use of the PDF generation features, install
[Prince XML](http://www.princexml.com). A
[free version](http://www.princexml.com/download/) of Prince is available for
non-commercial use. If you plan to use this feature commercially, please
[purchase an appropriate license](http://www.princexml.com/purchase/).

### Create a new Project

Create a new project by running this command:
```
middleman init my_book --template=gettypubs/middleman-book-template
```
This will create a `my_book` directory inside the current folder that contains
everything you need to get started.

#### Recommended

Consider adding this project to version control by running `git init` inside
this folder after initializing.

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

## Project Structure

### Data and Configuration

Add data that describes your book to the `/data/book.yml` file. This file
includes fields for `title`, `author`, `description`, etc.; you are free to add
additional fields.

### Directories

Stylesheets, fonts, images, and JavaScript files go in the `/source/assets/`
directory. Vendor stylesheets and JavaScripts should go in each of their
`/vendor/` directories. If you are planning on modifying the theme, take a look
at the `_variables.scss` file in `/source/assets/stylesheets/base/`.

## Content Authoring

Inside the `/source/` directory, simply create whatever files you need, using
the following format to name them: `filename.html.md`: The first extension
(`.html`) represents the final format the file will convert to when built; the
second extension (`.md`) represents the templating language being used.
Middleman supports a variety of
[templating languages](https://middlemanapp.com/basics/templating_language/).

### Frontmatter

At the beginning of your files, you can define page-specific metadata
(frontmatter). More information on how to use this feature is available
[here](https://middlemanapp.com/basics/frontmatter/).

#### sort_order

There is one special frontmatter value to be aware of: this template pays
special attention to any files which contain a `sort_order` value, represented
as an integer. Any item that has a `sort_order` defined becomes a "chapter",
meaning it gets picked up by navigational elements and will automatically get
included in any PDF generated from the site. Here's an example:

```
---
title: Chapter 1
layout: page
author: Getty Publications
sort_order: 1
---
```

