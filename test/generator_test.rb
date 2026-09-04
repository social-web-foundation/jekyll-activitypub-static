require "minitest/autorun"
require "jekyll"
require "fileutils"
require "json"

require_relative "../lib/jekyll-activitypub-static"

class TestActivityPubStaticGenerator < Minitest::Test

  DEST_DIR = File.expand_path("../tmp/_site", __FILE__)

  def setup
    process_site
  end

  def test_actor_file_generated
    path = File.join(DEST_DIR, "actor.jsonld")
    assert File.exist?(path), "Expected actor.jsonld to be generated"

    data = JSON.parse(File.read(path))
    assert_equal "Person", data["type"]
    assert_equal "evanp", data["preferredUsername"]
    assert_equal "Evan Prodromou", data["name"]
    assert_equal({
                   "type" => "Link",
                   "mediaType" => "text/html",
                   "href" => "https://example.com/"
                 }, data["url"])
    assert_equal "https://example.com/activitypub/outbox.jsonld", data["outbox"]
    assert_equal "https://example.com/activitypub/inbox.jsonld", data["inbox"]
  end

  def test_webfinger_file_generated
    path = File.join(DEST_DIR, ".well-known", "webfinger")
    assert File.exist?(path), "Expected .well-known/webfinger to be generated"

    data = JSON.parse(File.read(path))

    assert_equal "acct:evanp@example.com", data["subject"]
    assert_kind_of Array, data["links"]

    self_link = data["links"].find { |link| link["rel"] == "self" }
    assert self_link, "Expected a 'self' link in webfinger document"
    assert_equal "application/activity+json", self_link["type"]
    assert_equal "https://example.com/actor.jsonld", self_link["href"]
  end

  def test_inbox_file_generated
    path = File.join(DEST_DIR, "activitypub", "inbox.jsonld")
    assert File.exist?(path), "Expected inbox.jsonld to be generated"
    data = JSON.parse(File.read(path))
    assert_equal "OrderedCollection", data["type"]
    assert_equal 0, data["totalItems"]
    assert_equal [], data["orderedItems"]
    assert_equal "https://example.com/actor.jsonld", data["inboxOf"]
    assert_equal "https://example.com/actor.jsonld", data["attributedTo"]
    assert_equal "as:Public", data["cc"]
  end

  def test_post_and_activity_files_generated
    posts_dir = File.join(DEST_DIR, "activitypub", "posts")
    activities_dir = File.join(DEST_DIR, "activitypub", "activities")
    fixtures_posts_dir = File.expand_path("fixtures/_posts", __dir__)

    assert Dir.exist?(posts_dir), "Expected activitypub/posts directory to exist"
    assert Dir.exist?(activities_dir), "Expected activitypub/activities directory to exist"

    post_filenames = Dir[File.join(fixtures_posts_dir, "*.md")]

    assert post_filenames.any?, "Expected at least one fixture post"

    post_filenames.each do |path|
      # Jekyll expects filenames like: 2025-08-01-hello-world.md
      filename = File.basename(path, ".md")
      slug = filename.sub(/^\d{4}-\d{2}-\d{2}-/, "") # strip date

      post_path = File.join(posts_dir, "#{slug}.jsonld")
      activity_path = File.join(activities_dir, "create-#{slug}.jsonld")

      assert File.exist?(post_path), "Expected post file for #{slug} at #{post_path}"
      assert File.exist?(activity_path), "Expected activity file for #{slug} at #{activity_path}"

      post = JSON.parse(File.read(post_path))
      activity = JSON.parse(File.read(activity_path))

      assert_includes %w[Article Note], post["type"], "Expected ActivityStreams object type for #{slug}"
      assert_kind_of String, post["content"], "Expected rendered content for #{slug}"
      refute_empty post["content"], "Expected rendered content for #{slug}"
      assert_includes post["content"], "<p>", "Expected rendered HTML content for #{slug}"
      assert_equal({
                     "type" => "Link",
                     "mediaType" => "text/html",
                     "href" => "https://example.com#{activity_post_url(path)}"
                   }, post["url"],
                   "Expected Article URL to link to HTML post for #{slug}")
      refute_includes post["content"], "Fixture layout header",
                      "Expected Article content to exclude layout header for #{slug}"
      refute_includes post["content"], "Fixture layout footer",
                      "Expected Article content to exclude layout footer for #{slug}"
      refute_includes post["content"], "<html>", "Expected Article content to exclude full document output for #{slug}"
      assert_equal "Create", activity["type"], "Expected type: Create for #{slug}"
      assert_equal post["id"], activity["object"]["id"], "Create.object should match object ID for #{slug}"
      assert_equal post["type"], activity["object"]["type"], "Create.object should match object type for #{slug}"
    end
  end

  def test_outbox_files_generated
    outbox_file = File.join(DEST_DIR, "activitypub", "outbox.jsonld")

    assert File.exist?(outbox_file), "Expected top-level outbox.jsonld"

    outbox = JSON.parse(File.read(outbox_file))
    assert_equal "OrderedCollection", outbox["type"], "Expected outbox to be OrderedCollection"

    first_page_url = outbox["first"]
    assert first_page_url, "Expected 'first' page in outbox"

    first_page_path = first_page_url.sub("https://example.com/", DEST_DIR + "/")

    assert File.exist?(first_page_path), "Expected first outbox page file at #{first_page_path}"

    first_page = JSON.parse(File.read(first_page_path))
    assert_equal "OrderedCollectionPage", first_page["type"], "Expected page type to be OrderedCollectionPage"
    assert first_page["orderedItems"].is_a?(Array), "Expected orderedItems in page"

    first_item = first_page["orderedItems"].first
    assert first_item["id"].include?("/activitypub/activities/"), "Expected item to reference an activity"
  end

  def test_post_html_links_to_activitypub_article
    fixtures_posts_dir = File.expand_path("fixtures/_posts", __dir__)
    post_filenames = Dir[File.join(fixtures_posts_dir, "*.md")]

    assert post_filenames.any?, "Expected at least one fixture post"

    post_filenames.each do |path|
      filename = File.basename(path, ".md")
      slug = filename.sub(/^\d{4}-\d{2}-\d{2}-/, "")
      html_path = File.join(DEST_DIR, activity_post_url(path))
      expected_href = "https://example.com/activitypub/posts/#{slug}.jsonld"

      assert File.exist?(html_path), "Expected HTML post file for #{slug} at #{html_path}"

      html = File.read(html_path)
      link = html.scan(/<link\b[^>]*>/).find do |tag|
        html_attribute(tag, "rel") == "alternate" &&
          html_attribute(tag, "type") == "application/activity+json" &&
          html_attribute(tag, "href") == expected_href
      end

      assert link, "Expected HTML post for #{slug} to link to #{expected_href}"
    end
  end

  def test_site_index_links_to_activitypub_actor
    path = File.join(DEST_DIR, "index.html")
    expected_href = "https://example.com/actor.jsonld"

    assert File.exist?(path), "Expected site index file at #{path}"

    html = File.read(path)
    link = html.scan(/<link\b[^>]*>/).find do |tag|
      html_attribute(tag, "rel") == "alternate" &&
        html_attribute(tag, "type") == "application/activity+json" &&
        html_attribute(tag, "href") == expected_href
    end

    assert link, "Expected site index to link to #{expected_href}"
  end

  def test_article_summary_uses_description_by_default
    post = activitypub_post("hello-fediverse")

    assert_equal "A fixture post with an explicit description.", post["summary"]
  end

  def test_article_summary_falls_back_to_rendered_excerpt
    post = activitypub_post("happy-birthday")

    assert_equal "<p>Happy birthday to me.</p>\n", post["summary"]
  end

  def test_article_summary_property_is_configurable
    destination = File.expand_path("../tmp/_site_summary_property", __FILE__)
    process_site(
      destination: destination,
      config: {
        "activitypub" => {
          "output_path" => "activitypub",
          "preferred_username" => "evanp",
          "summary_property" => "summary"
        }
      }
    )

    post = activitypub_post("happy-birthday", destination: destination)

    assert_equal "A fixture post with an explicit summary.", post["summary"]
  end

  def test_short_untitled_post_without_summary_is_note
    post = activitypub_post("short-note")

    assert_equal "Note", post["type"]
    refute post.key?("name"), "Expected Note to omit name"
  end

  def test_titled_short_post_is_article
    post = activitypub_post("hello-fediverse")

    assert_equal "Article", post["type"]
  end

  def test_untitled_post_with_summary_is_article
    post = activitypub_post("untitled-with-description")

    assert_equal "Article", post["type"]
  end

  def test_untitled_post_with_multiple_paragraphs_is_article
    post = activitypub_post("untitled-two-paragraphs")

    assert_equal "Article", post["type"]
  end

  def test_untitled_post_over_default_note_limit_is_article
    post = activitypub_post("untitled-long-post")

    assert_equal "Article", post["type"]
  end

  def test_note_character_limit_is_configurable
    destination = File.expand_path("../tmp/_site_note_character_limit", __FILE__)
    process_site(
      destination: destination,
      config: {
        "activitypub" => {
          "output_path" => "activitypub",
          "preferred_username" => "evanp",
          "note_max_characters" => 650
        }
      }
    )

    post = activitypub_post("untitled-long-post", destination: destination)

    assert_equal "Note", post["type"]
  end

  private

  def process_site(destination: DEST_DIR, config: {})
    site_config = {
      "source" => File.expand_path("fixtures", __dir__),
      "destination" => destination
    }.merge(config)

    Jekyll::Site.new(Jekyll.configuration(site_config)).process
  end

  def activitypub_post(slug, destination: DEST_DIR)
    path = File.join(destination, "activitypub", "posts", "#{slug}.jsonld")

    JSON.parse(File.read(path))
  end

  def activity_post_url(path)
    filename = File.basename(path, ".md")
    year, month, day, slug = filename.match(/^(\d{4})-(\d{2})-(\d{2})-(.+)$/).captures

    "/#{year}/#{month}/#{day}/#{slug}.html"
  end

  def html_attribute(tag, name)
    tag[/\b#{Regexp.escape(name)}=(["'])(.*?)\1/, 2]
  end
end
