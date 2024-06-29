## Unreleased
[no unreleased changes yet]

## v0.9.0 (2024-06-28)
- Enforce only major and minor parts of required Ruby version (loosening the required Ruby version from 3.3.3 to 3.3.0)

## v0.8.0 (2024-06-15)
- Rename primary branch from `master` to `main`

## v0.7.0 (2024-06-15)
- Look for and use any of several common primary branch names (`main`, `master`, or `trunk`)

## v0.6.0 (2024-02-02)
- Source Ruby version from `.ruby-version` file

## v0.5.0 (2023-06-20)
### Changed
- Switch from `colorize` to `rainbow` for colored terminal printing

## v0.4.2 (2023-05-30)
### Changed
- Fix `spec.summary` in gemspec

## v0.4.1 (2023-05-30)
### Changed
- Move from Memoist to MemoWise

## v0.4.0 (2023-05-22)
### Added
- Release via RubyGems

### Changed
- Rename with "Runger" prefix
  - For backwards compatibility, the (optional) config file will still be called
    `.release_assistant.yml` (not `.runger_release_assistant.yml`)

## v0.3.2 (2021-02-05)
### Changed
- Bump Ruby version from 2.7.2 to 3.0.0

## v0.3.1 (2021-02-01)
### Fixed
- Release the correct (non-alpha) gem verision to RubyGems

### Changed
- Validate when initializing `RungerReleaseAssistant` that options are valid (which currently entails only
  checking for `git: true`)
- Always show system output for the release phase when pushing to RubyGems (if pushing to RubyGems)
  in order to allow for engaging with the RubyGems 2FA prompt (which should be enabled)

## v0.3.0 (2021-02-01)
### Added
- Allow for managing releases via RubyGems (in addition to GitHub)
- Add `--show-system-output` option to show outpup of executed system commands. (By default, the
  output of executed system commands will be suppressed.)

## v0.2.0 (2021-01-28)
### Changed
- Leave version numbers unchanged if bumping from version w/ modifier (e.g. `2.0.0.alpha` to `2.0.0`
  or `0.4.0.alpha` to `0.4.0`)

## v0.1.0 (2021-01-26)
### Added
- Bump to next alpha version after creating release

## v0.0.3 (2021-01-26)
- Ensure in PR CI runs that the current version contains "alpha" & that there's no git diff (e.g.
  due to failing to run `bundle` after updating the version)

## v0.0.2 (2021-01-26)
### Fixed
- Push git tags when releasing

## v0.0.1 (2021-01-26)
### Added
- Create `runger_release_assistant` tool to aid with releasing/publishing gems (particularly via GitHub)
- Require confirmation before releasing
- Restore original state (current git branch, file contents) when aborting

### Fixed
- Read confirmation from `STDIN`

### Removed
- Remove lingering code/documentation related to `.release_assistant.yml` config file
