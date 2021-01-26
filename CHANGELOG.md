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
