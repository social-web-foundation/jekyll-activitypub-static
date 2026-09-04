# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added three posts to the example site: "Hello, World!", "Lorem Ipsum", and "Fable of the Wind and the Sun".
- Added GitHub Actions automation to run linting and tests on pushes to `main`.

### Changed

- Renamed the gem from `jekyll-activitypub` to `jekyll-activitypub-static`.
- Renamed the Ruby namespace from `Jekyll::ActivityPub` to `Jekyll::ActivityPubStatic`.
- Updated the example site to use the local `jekyll-activitypub-static` path dependency.

### Fixed

- Updated the example site configuration to preserve generated ActivityPoll files across Jekyll cleanup.

## [0.6.0] - 2025-08-03

### Added

- Generated an ActivityPub outbox collection.
- Generated paginated outbox pages.

## [0.5.0] - 2025-08-03

### Added

- Generated JSON-LD Article objects for Jekyll posts.
- Generated Create activities for Jekyll posts.
- Added another fixture post for generator testing.

## [0.4.0] - 2025-08-03

### Added

- Generated an empty ActivityPoll inbox collection.

### Changed

- Refactored generator tests to run the generator once per test setup.

## [0.3.0] - 2025-08-03

### Added

- Generated a WebFinger document for actor discovery.
- Added WebFinger test coverage.

### Fixed

- Fixed actor test expectations.
- Fixed a bare URL in the README.

## [0.2.0] - 2025-08-03

### Added

- Generated an ActivityPub actor document.
- Added generator test coverage.

## [0.1.0] - 2025-08-03

### Added

- Added initial gem scaffolding.
- Added a minimal example site.

[Unreleased]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/releases/tag/v0.1.0
