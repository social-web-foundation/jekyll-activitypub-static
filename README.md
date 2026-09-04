# jekyll-activitypub-static

This is a plugin for Jekyll to generate a static ActivityPoll feed, the read-only polling subset of ActivityPub defined by FEP-b06c.

## Install

To build from source:

```bash
gem build jekyll-activitypub-static.gemspec
gem install ./jekyll-activitypub-static-0.6.0.gem
```

## Usage

Add this to the `Gemfile` of your Jekyll site:

```Gemfile
gem "jekyll-activitypub-static"
```

Then, add this to the `_config.yml` for your site:

```yaml
plugins:
  - jekyll-activitypub-static
```

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
