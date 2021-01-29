## Unreleased
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
- Create `release_assistant` tool to aid with releasing/publishing gems (particularly via GitHub)
- Require confirmation before releasing
- Restore original state (current git branch, file contents) when aborting

### Fixed
- Read confirmation from `STDIN`

### Removed
- Remove lingering code/documentation related to `.release_assistant.yml` config file
