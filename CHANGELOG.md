# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.6] - 2026-09-04

### Fixed

- Lint error in tests.

## [0.7.5] - 2026-09-04

### Fixed

- Keep generated Article content scoped to rendered post content, excluding layout output.

## [0.7.4] - 2026-09-04

### Added

- Configure Dependabot to check Bundler dependencies and GitHub Actions weekly with a seven-day cooldown.

### Fixed

- Generate Article objects after Jekyll renders post content.

## [0.7.3] - 2026-09-04

### Fixed

- Pin `.ruby-version` to Ruby 3.4.10 so rbenv can select the project Ruby version.

## [0.7.2] - 2026-09-04

### Changed

- Clarified the README and gem metadata description of ActivityPoll.

### Fixed

- Register generated ActivityPub files as Jekyll static files so they survive cleanup. Thanks to [Paul Roub](https://github.com/paulroub) in [#1](https://github.com/social-web-foundation/jekyll-activitypub-static/pull/1).

## [0.7.1] - 2026-09-03

### Fixed

- Run the release example-site build through Bundler.

## [0.7.0] - 2026-09-03

### Added

- Added three posts to the example site: "Hello, World!", "Lorem Ipsum", and "Fable of the Wind and the Sun".
- Added a CI/CD GitHub Actions workflow to run linting and tests on pushes to `main`, and to build, verify, and publish gems on release tag pushes.

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

[Unreleased]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.6...HEAD
[0.7.6]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.5...v0.7.6
[0.7.5]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.4...v0.7.5
[0.7.4]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/social-web-foundation/jekyll-activitypub-static/releases/tag/v0.1.0
