# jekyll-activitypub-static.gemspec

require_relative "lib/jekyll/activitypub_static/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-activitypub-static"
  spec.version       = Jekyll::ActivityPubStatic::VERSION
  spec.authors       = ["Evan Prodromou"]
  spec.email         = ["evanp@socialwebfoundation.org"]

  spec.summary       = "A Jekyll plugin that generates a static ActivityPoll feed, the read-only polling subset of ActivityPub defined by FEP-b06c."
  spec.description   = "A Jekyll plugin that generates a static ActivityPoll feed, the read-only polling subset of ActivityPub defined by FEP-b06c."
  spec.homepage      = "https://github.com/social-web-foundation/jekyll-activitypub-static"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 4.0"

  spec.add_development_dependency "rubocop", "~> 1.65"
end
