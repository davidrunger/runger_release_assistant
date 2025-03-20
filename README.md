![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/davidrunger/runger_release_assistant?include_prereleases)

# `runger_release_assistant`

This is a CLI tool that I (David Runger) use to automate the release of new gem
versions via git/GitHub and (optionally) via RubyGems.

<!--ts-->
* [runger_release_assistant](#runger_release_assistant)
   * [Dependencies](#dependencies)
   * [Installation](#installation)
      * [Global installation](#global-installation)
      * [Installation in a specific project](#installation-in-a-specific-project)
         * [Create a binstub](#create-a-binstub)
   * [Basic usage](#basic-usage)
      * [Available options and examples](#available-options-and-examples)
   * [Config](#config)
   * [Post-release command](#post-release-command)
   * [Using with RubyGems](#using-with-rubygems)
   * [Development](#development)
   * [Contributing](#contributing)
   * [License](#license)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: david, at: Wed Feb  5 04:11:40 AM CST 2025 -->

<!--te-->

## Dependencies

This gem assumes that you have `git` installed.

## Installation

### Global installation

```
gem install runger_release_assistant
```

Then you can execute `release` anywhere on your machine.

### Installation in a specific project

Add `runger_release_assistant` to your `Gemfile`:

```rb
group :development do
  gem 'runger_release_assistant', require: false
end
```

Then, you can execute `bundle exec release`.

#### Create a binstub

When using bundler, you can create a binstub via:

```
bundle binstubs runger_release_assistant
```

Then, you can execute `bin/release`.

## Basic usage

If installed globally:

```
$ release [options]
```

If installed via bundler without a binstub:

```
$ bundle exec release [options]
```

If installed via bundler with a binstub:

```
$ bin/release [options]
```

### Available options and examples

After installing, execute `release --help` to see usage examples and available options.

```
$ release --help

Usage: release [options]

Example:
  release
  release --type minor
  release -t patch

    -t, --type                Release type (major, minor, or patch)
    -d, --debug               print debugging info
    -s, --show-system-output  show system output
    -i, --init                create a `.release_assistant.yml` config file
    -v, --version             print the version
    -h, --help                print this help information
```

## Config

You can create a configuration file with `release --init`.

Here is an example:

```yml
---
rubygems: false
primary_branch: main
```

The above example (more or less) illustrates the default values, so you don't
need to create a config file, if those are the values that you want.

Regarding the `primary_branch` option, `runger_release_assistant` will automatically detect as the "primary branch" any one of the following: `main`, `master`, or `trunk`. So, if one of those is the name of your primary branch, and if you also want `rubygems: false`, then you don't need to create a config file.

## Post-release command

If you specify a `post-release-command` in your `~/code/dotfiles` [`runger-config`](https://github.com/davidrunger/dotfiles/blob/cd02495fb2ad742cc1e85cc65aea5ff711485981/crystal-programs/runger-config.cr), then `runger_release_assistant` will execute that command after a successful release.

## Using with RubyGems

By default, `runger_release_assistant` assumes that you only want to "release" your gem via GitHub. If
you'd also like to release the gem via RubyGems, then create a `.release_assistant.yml` file by
executing `release --init`. Within that file, modify the default `rubygems: false` option to
`rubygems: true`.

## Tag prefix

By default, Git tags are created like `v1.0.0`. If you would like to prefix the git tag with any additional content, you may specify a `tag_prefix` in `.release_assistant.yml`, such as:

```yml
tag_prefix: gem/
```

You must also provide this to bundler by putting something like the following in your `Rakefile`:

```rb
require 'bundler/gem_tasks'
require 'runger_release_assistant'
Bundler::GemHelper.tag_prefix = RungerReleaseAssistant.new.tag_prefix
```

This example would generate tags in the form `gem/v1.0.0`.

Note that all version numbers in git tags will be prefixed with at least a `v`. The `tag_prefix` option is to specify an additional prefix, in addition to the `v`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/davidrunger/runger_release_assistant.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
