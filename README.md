# jekyll-activitypub-static

A Jekyll plugin that generates a static ActivityPoll feed, the read-only polling subset of ActivityPub defined by FEP-b06c.

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Configuration](#configuration)
- [Articles and Notes](#articles-and-notes)
- [Layouts](#layouts)
- [Generated Files](#generated-files)
- [GitHub Pages](#github-pages)
- [Example Site](#example-site)
- [Contributing](#contributing)
- [License](#license)

## Install

Add this to the `Gemfile` of your Jekyll site:

```Gemfile
gem "jekyll-activitypub-static"
```

To build from source:

```bash
gem build jekyll-activitypub-static.gemspec
gem install ./jekyll-activitypub-static-*.gem
```

Add the plugin to the `_config.yml` for your site:

```yaml
plugins:
  - jekyll-activitypub-static
```

## Usage

Build your site to generate the ActivityPub files:

```sh
bundle exec jekyll build
```

To build the site and serve it locally:

```sh
bundle exec jekyll serve
```

## Configuration

The plugin uses your site's standard `url`, `author`, and `description`
settings, plus the `activitypub` configuration block.

```yaml
url: "https://example.com"
author: "Example Author"
description: "A short description of the site"

activitypub:
  output_path: "activitypub"
  preferred_username: "example"
  summary_property: "description"
  note_max_characters: 500
  update_interval: "P1D"
  webfinger_output_file: ".well-known/webfinger"
```

Available `activitypub` options:

- `output_path`: directory for generated ActivityPub files. Defaults to
  `activitypub`.
- `preferred_username`: username for the generated actor and WebFinger
  document. Defaults to the host name from `url`. The WebFinger account ID is
  `preferred_username` at the domain from `url`, like `example@example.com`.
- `summary_property`: post front matter property to use for generated Article
  summaries. Defaults to `description`; when the property is missing or empty,
  the plugin uses the rendered post excerpt.
- `note_max_characters`: maximum plain-text character count for generated
  Note objects. Defaults to `500`.
- `update_interval`: ActivityPoll polling interval for the generated Actor
  object, as an ISO 8601 duration. Defaults to `P1D`.
- `webfinger_output_file`: path for the generated WebFinger document. Defaults
  to `.well-known/webfinger`. GitHub Pages sites can set this to
  `.well-known/webfinger/index.json` as a workaround for its content type.

## Articles and Notes

Posts are generated as Activity Streams `Article` objects by default.

Short, untitled posts without an explicit summary are generated as
Activity Streams `Note` objects. `Note` is the native Activity Streams object
type used by Mastodon for statuses. To make a post eligible for `Note`
generation, set an explicit blank title:

```yaml
---
title: ""
---
```

Jekyll generates titles from post filenames when `title` is omitted, so an
omitted title is treated as a normal title. A blank-titled post is generated as
a `Note` when it has no configured summary property, has one rendered paragraph,
and its plain-text content is no longer than `activitypub.note_max_characters`.

Blank-titled posts may need layout support on home pages, archive pages, or
post lists. Use the excerpt, date, or another fallback when displaying links to
untitled posts.

## Layouts

To link from HTML pages to their ActivityPub representation, add this to the
`<head>` element of your layouts:

```html
{% if page.activitypub_url %}
  <link rel="alternate" type="application/activity+json" href="{{ page.activitypub_url }}">
{% endif %}
```

The plugin sets `page.activitypub_url` before rendering posts and the site
index. For posts, the URL points to the generated JSON-LD Article or Note
object. For the site index, the URL points to the generated Actor object.

## Generated Files

The plugin generates these static files:

- `actor.jsonld`
- `.well-known/webfinger`
- `activitypub/inbox.jsonld`
- `activitypub/outbox.jsonld`
- `activitypub/outbox/page-*.jsonld`
- `activitypub/posts/*.jsonld`
- `activitypub/activities/create-*.jsonld`

The `activitypub` path changes when `activitypub.output_path` is configured.

### WebFinger

The WebFinger document is generated at `.well-known/webfinger` by default and
uses an account ID in the form `preferred_username` at the site domain. For
example, with `url: "https://example.com"` and `preferred_username: "evan"`,
the account ID is `evan@example.com`.

The output path can be configured with `activitypub.webfinger_output_file`.
For example, GitHub Pages sites can use the following workaround to serve the
document through an `index.json` file:

```yaml
activitypub:
  webfinger_output_file: ".well-known/webfinger/index.json"
```

GitHub Pages redirects requests for `.well-known/webfinger` to
`.well-known/webfinger/`, where it serves `index.json`.

WebFinger discovery only works when the generated site is served from the root
of its domain, because clients request `https://example.com/.well-known/webfinger`.
Sites served from a subdirectory cannot provide a domain-level WebFinger
endpoint with this plugin alone.

## GitHub Pages

GitHub Pages' built-in Jekyll build does not support this plugin because it is
not on GitHub's allowlist. Configure a GitHub Actions workflow to build the
site instead.

The `.well-known` directory can be dropped when uploading the resulting site to GitHub Pages. To work around this, set `include-hidden-files: true` on the `actions/upload-pages-artifact` step in the GitHub Actions workflow:

```yaml
- uses: actions/upload-pages-artifact@v5
  with:
    path: _site
    include-hidden-files: true
```

Configure WebFinger to use an `index.json` file:

```yaml
activitypub:
  webfinger_output_file: ".well-known/webfinger/index.json"
```

The `index.json` path works around GitHub Pages serving the extensionless
`.well-known/webfinger` file with an `application/octet-stream` content type.

## Example Site

The `example-site` directory has a minimal example site (thus the name). You can build and run it with these commands:

```sh
cd example-site
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

This will build a site that runs on `http://localhost:4000/`

## Viewing from the Fediverse

Support for interacting with static accounts on the Fediverse is still experimental; most software will not allow full interactions.

With Mastodon 4.x (the current version) you can search for the account by Webfinger ID (username@domain), and then load the account. It should show the profile information.

With [Webfinger Browser](https://acct.swf.pub/), you can search for the account by Webfinger ID, and view the account. It should show the profile information and all the generated content.

It's still definitely worthwhile to keep this plugin enabled; it gives an incentive for Fediverse software developers to add support for static accounts.

## Contributing

PRs accepted.

## License

LGPL-3.0-or-later (c) 2025 Social Web Foundation
