![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/davidrunger/release_assistant?include_prereleases)

# `release_assistant`

This is a CLI tool that I use to help automate the process of releasing a new version of a gem.

## Installation

### Global installation

The easiest way to install `release_assistant` "globally" on your machine is via the
[`specific_install`](https://github.com/rdp/specific_install) gem, which will pull and build the
`release_assistant` gem directly from the `master` branch of this repo:

```
gem install specific_install
gem specific_install davidrunger/release_assistant
```

Then you can execute `release` anywhere on your machine.

### Installation in a specific project

Add `release_assistant` to your `Gemfile`:

```rb
group :development do
  gem 'release_assistant', require: false, git: 'https://github.com/davidrunger/release_assistant'
end
```

Then, you can execute `bundle exec release`.

#### Create a binstub

When using bundler, you can create a binstub via:

```
bundle binstubs release_assistant
```

Then, you can execute `bin/release`.

## Dependencies

This gem assumes that you have `git` installed.

## Basic usage

```
$ release [options]
```

#### Available options and examples

After installing, execute `release --help` to see usage examples and available options.

```
$ release --help

Usage: release [options]

Example:
  release
  release --type minor
  release -t patch

    -t, --type     Release type (major, minor, or patch)
    --debug        print debugging info
    -v, --version  print the version
    -h, --help     print this help information
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/davidrunger/release_assistant.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
