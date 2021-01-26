[![Build Status](https://travis-ci.org/davidrunger/release_assistant.svg?branch=master)](https://travis-ci.org/davidrunger/release_assistant)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=davidrunger/release_assistant)](https://dependabot.com)
![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/davidrunger/release_assistant?include_prereleases)

# `release_assistant` ("find commit(s)")

This is a CLI tool that I use to parse the git history of a repo.

For example, if I use `release_assistant` to search this repo with `release_assistant "line.(green|red)" --regex --repo
davidrunger/release_assistant`, I get this output:

![](https://s3.amazonaws.com/screens.davidrunger.com/2019-12-28-20-50-09-oect2(1).png)

## Installation

The easiest way to install `release_assistant` is via the
[`specific_install`](https://github.com/rdp/specific_install) gem, which will pull and build the
`release_assistant` gem directly from the `master` branch of this repo:

```
gem install specific_install
gem specific_install davidrunger/release_assistant
```

## Dependencies

This gem assumes that you have `git` and `rg` (ripgrep) installed.

## Basic usage

```
$ release_assistant <search string> [options]
```

#### Available options and examples

After installing, execute `release_assistant --help` to see usage examples and available options.

```
$ release_assistant --help

Usage: release_assistant <search string> [options]

Examples:
  release_assistant update
  release_assistant 'def update'
  release_assistant "def update" --days 60
  release_assistant "[Uu]ser.*slug" -d 365 --regex
  release_assistant options --path spec/
  release_assistant "line.(green|red)" -d 365 --regex --repo davidrunger/release_assistant

    --repo             GitHub repo (in form `username/repo`)
    -d, --days         number of days to search back
    -r, --regex        interpret search string as a regular expression
    -i, --ignore-case  search case-insensitively
    -p, --path         path (directory or file) used to filter results
    --debug            print debugging info
    --init             create an `.release_assistant.yml` config file
    -v, --version      print the version
    -h, --help         print this help information
```

## `.release_assistant.yml` config file
We highly recommend that you create an `.release_assistant.yml` file in any repository that you plan to search
with `release_assistant`.

**This file can be created automatically by executing `release_assistant --init`** in the relevant
repo/directory.

(You might (or might not) want to add `.release_assistant.yml` to your `~/.gitignore_global` file, so that this
file is not tracked by `git`.)

#### Example `.release_assistant.yml` config file
```yaml
repo: githubusername/reponame
```

The advantage of creating an `.release_assistant.yml` config file is that it will make the `release_assistant` command execute
more quickly, because time will not be wasted parsing the output of `git remote [...]` in order to
determine the URL of the repo's remote repository (which is used to construct links to matching
commits).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bin/release`, which will create a
git tag for the version and push git commits and tags.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidrunger/release_assistant.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
