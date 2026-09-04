# lib/jekyll-activitypub-static.rb
require "jekyll"
require "jekyll/activitypub_static/generator"

module Jekyll
  module ActivityPubStatic
    LOG_TAG = "ActivityPub"
    PAGE_SIZE = 100
  end
end
