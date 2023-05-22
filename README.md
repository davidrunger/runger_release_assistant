![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/davidrunger/runger_release_assistant?include_prereleases)

# `runger_release_assistant`

This is a CLI tool that helps to automate the process of releasing new versions of a gem via
git/GitHub and (optionally) via RubyGems.

<!--ts-->
   * [runger_release_assistant](#runger_release_assistant)
      * [Dependencies](#dependencies)
      * [Installation](#installation)
         * [Global installation](#global-installation)
         * [Installation in a specific project](#installation-in-a-specific-project)
            * [Create a binstub](#create-a-binstub)
      * [Basic usage](#basic-usage)
         * [Available options and examples](#available-options-and-examples)
      * [Using with RubyGems](#using-with-rubygems)
      * [Development](#development)
      * [Contributing](#contributing)
      * [License](#license)

<!-- Added by: david, at: Mon Feb  1 20:16:03 PST 2021 -->

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

Create a configuration file with `release --init`.

Here is an example:

```yml
---
git: true
rubygems: false
primary_branch: main
```

## Using with RubyGems

By default, `runger_release_assistant` assumes that you only want to "release" your gem via GitHub. If
you'd also like to release the gem via RubyGems, then create a `.release_assistant.yml` file by
executing `release --init`. Within that file, modify the default `rubygems: false` option to
`rubygems: true`.

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
