# jekyll-activitypub-static

A Jekyll plugin that generates a static ActivityPoll feed, the read-only polling subset of ActivityPub defined by FEP-b06c.

## Installation

Add this to the `Gemfile` of your Jekyll site:

```Gemfile
gem "jekyll-activitypub-static"
```

To build from source:

```bash
gem build jekyll-activitypub-static.gemspec
gem install ./jekyll-activitypub-static-*.gem
```

## Usage

Add this to the `_config.yml` for your site:

```yaml
plugins:
  - jekyll-activitypub-static
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

## Post Layouts

To link from each HTML post to its ActivityPub representation, add this to
the `<head>` element of your post layout:

```html
{% if page.activitypub_url %}
  <link rel="alternate" type="application/activity+json" href="{{ page.activitypub_url }}">
{% endif %}
```

The plugin sets `page.activitypub_url` for posts before they render. The URL
points to the generated JSON-LD Article object for the post.

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

The WebFinger document is generated at `.well-known/webfinger` and uses an
account ID in the form `preferred_username` at the site domain. For example,
with `url: "https://example.com"` and `preferred_username: "evan"`, the
account ID is `evan@example.com`.

WebFinger discovery only works when the generated site is served from the root
of its domain, because clients request `https://example.com/.well-known/webfinger`.
Sites served from a subdirectory cannot provide a domain-level WebFinger
endpoint with this plugin alone.

## Example Site

The `example-site` directory has a minimal example site (thus the name). You can build and run it with these commands:

```sh
cd example-site
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

This will build a site that runs on `http://localhost:4000/`

## Contributing

PRs accepted.

## License

Apache 2.0 (c) 2025 Social Web Foundation
