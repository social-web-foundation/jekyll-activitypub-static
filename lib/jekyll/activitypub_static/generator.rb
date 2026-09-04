# lib/jekyll/activitypub_static/generator.rb
require "json"
require "uri"

module Jekyll
  module ActivityPubStatic
    class JsonStaticFile < Jekyll::StaticFile
      def initialize(site, dir, name, content)
        super(site, site.source, dir, name)
        @content = content
      end

      def modified?
        true
      end

      def write(dest)
        dest_path = destination(dest)
        FileUtils.mkdir_p(File.dirname(dest_path))
        File.write(dest_path, JSON.pretty_generate(@content))
        true
      end
    end

    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        generate_webfinger(site)
        generate_actor(site)
        generate_inbox(site)
      end

      def generate_webfinger(site)
        Jekyll.logger.info LOG_TAG, "Generating .well-known/webfinger"

        url = site.config["url"]
        actor_url = "#{url}/actor.jsonld"

        webfinger = {
          "subject" => "acct:#{webfinger_address(site)}",
          "links" => [
            {
              "rel" => "self",
              "type" => "application/activity+json",
              "href" => actor_url
            }
          ]
        }

        sf = JsonStaticFile.new(site, ".well-known", "webfinger", webfinger)
        site.static_files << sf

        Jekyll.logger.info LOG_TAG, "Added webfinger as #{sf.path}"
      end

      def generate_actor(site)
        Jekyll.logger.info LOG_TAG, "Generating actor.jsonld"
        actor = build_actor(site)
        site.static_files << JsonStaticFile.new(site, "", "actor.jsonld", actor)
      end

      def generate_inbox(site)
        Jekyll.logger.info LOG_TAG, "Generating inbox.jsonld"
        url  = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        inbox = {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://purl.archive.org/miscellany/1.0",
            "https://w3id.org/fep/5711"
          ],
          "id": "#{url}/#{output_path}/inbox.jsonld",
          "type": "OrderedCollection",
          "attributedTo": "#{url}/actor.jsonld",
          "cc": "as:Public",
          "inboxOf": "#{url}/actor.jsonld",
          "summary": "Inbox of #{name(site)}",
          "totalItems": 0,
          "orderedItems": []
        }

        site.static_files << JsonStaticFile.new(site, output_path, "inbox.jsonld", inbox)
      end

      def generate_articles(site)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        output_dir = File.join(output_path, "posts")

        site.posts.docs.each do |post|
          slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
          filename = "#{slug}.jsonld"

          article_id = "#{url}/#{output_path}/posts/#{slug}.jsonld"

          article = {
            "@context" => "https://www.w3.org/ns/activitystreams",
            "id" => article_id,
            "type" => post_type(site, post),
            "content" => post.content,
            "summary" => article_summary(site, post),
            "published" => post.date.iso8601,
            "attributedTo" => "#{url}/actor.jsonld",
            "url" => {
              "type" => "Link",
              "mediaType" => "text/html",
              "href" => "#{url}#{post.url}"
            },
            "to" => "as:Public"
          }

          article["name"] = post.data["title"] unless post.data["title"].to_s.strip.empty?

          site.static_files << JsonStaticFile.new(site, output_dir, filename, article)
        end
      end

      def generate_activities(site)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        output_dir = File.join(output_path, "activities")

        site.posts.docs.each do |post|
          slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
          filename = "create-#{slug}.jsonld"
          path = File.join(output_dir, filename)

          article_id = "#{url}/#{output_path}/posts/#{slug}.jsonld"
          activity_id = "#{url}/#{output_path}/activities/create-#{slug}.jsonld"

          activity = {
            "@context" => "https://www.w3.org/ns/activitystreams",
            "id" => activity_id,
            "actor" => "#{url}/actor.jsonld",
            "type" => "Create",
            "summary" => "#{name(site)} created #{post.data["title"]}",
            "published" => post.date.iso8601,
            "object" => {
              "id" => article_id,
              "type" => post_type(site, post)
            },
            "to" => "as:Public"
          }

          activity["object"]["name"] = post.data["title"] unless post.data["title"].to_s.strip.empty?

          site.static_files << JsonStaticFile.new(site, output_dir, filename, activity)
          Jekyll.logger.info LOG_TAG, "Wrote activity to #{path}"
        end
      end

      def generate_outbox_pages(site)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        output_dir = File.join(output_path, "outbox")

        page_number = 1
        page = build_page(site, page_number)

        site.posts.docs.each_with_index do |post, index|
          slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
          Jekyll.logger.info LOG_TAG, "Adding #{slug} to page #{page_number}"
          article_id = "#{url}/#{output_path}/posts/#{slug}.jsonld"
          activity_id = "#{url}/#{output_path}/activities/create-#{slug}.jsonld"

          if page["orderedItems"].length >= PAGE_SIZE
            site.static_files << JsonStaticFile.new(site, output_dir, "page-#{page_number}.jsonld", page)
            page_number += 1
            page = build_page(site, page_number)
          end

          activity = {
            "id" => activity_id,
            "type" => "Create",
            "object" => {
              "id" => article_id,
              "type" => "Article",
              "name" => post.data["title"]
            },
            "to" => "as:Public"
          }

          page["orderedItems"].unshift(activity)
        end

        if page["orderedItems"].any?
          path = File.join(output_dir, "page-#{page_number}.jsonld")

          site.static_files << JsonStaticFile.new(site, output_dir, "page-#{page_number}.jsonld", page)
          Jekyll.logger.info LOG_TAG, "Wrote outbox page #{page_number} to #{path}"
        end
      end

      def generate_outbox(site)
        Jekyll.logger.info LOG_TAG, "Generating outbox.jsonld"
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        total_items = site.posts.docs.length
        page_count = (total_items.to_f / PAGE_SIZE).ceil

        outbox = {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://purl.archive.org/miscellany/1.0",
            "https://w3id.org/fep/5711"
          ],
          "id": "#{url}/#{output_path}/outbox.jsonld",
          "type": "OrderedCollection",
          "attributedTo": "#{url}/actor.jsonld",
          "cc": "as:Public",
          "outboxOf": "#{url}/actor.jsonld",
          "summary": "Outbox of #{name(site)}",
          "totalItems": total_items,
          "first": ("#{url}/#{output_path}/outbox/page-#{page_count}.jsonld" if total_items > 0)
        }

        site.static_files << JsonStaticFile.new(site, output_path, "outbox.jsonld", outbox)
        Jekyll.logger.info LOG_TAG, "Wrote outbox to #{File.join(site.dest, output_path, "outbox.jsonld")}"
      end

      def build_actor(site)
        url  = site.config["url"]
        summary = site.config["description"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"

        {
          "@context": [
            "https://www.w3.org/ns/activitystreams",
            "https://purl.archive.org/miscellany/1.0",
            "https://purl.archive.org/socialweb/webfinger",
            "https://w3id.org/fep/b06c"
          ],
          "type": "Person",
          "id": "#{url}/actor.jsonld",
          "pollOnly": true,
          "name": name(site),
          "preferredUsername": preferred_username(site),
          "summary": (summary unless summary.to_s.strip.empty?),
          "inbox": "#{url}/#{output_path}/inbox.jsonld",
          "outbox": "#{url}/#{output_path}/outbox.jsonld",
          "attributedTo": "#{url}/actor.jsonld",
          "url" => {
            "type" => "Link",
            "mediaType" => "text/html",
            "href" => homepage_url(site)
          },
          "webfinger" => webfinger_address(site),
          "cc": "as:Public"
        }
      end

      def name(site)
        explicit = site.config["author"]
        return explicit unless explicit.to_s.strip.empty?
        "Anonymous"
      end

      def preferred_username(site)
        explicit = site.config.dig("activitypub", "preferred_username")
        return explicit unless explicit.to_s.strip.empty?

        host = URI(site.config["url"]).host
        return host if host

        "anonymous"
      end

      def build_page(site, page_number)
        url = site.config["url"]
        output_path = site.config.dig("activitypub", "output_path") || "activitypub"
        id = "#{url}/#{output_path}/outbox/page-#{page_number}.jsonld"

        page = {
          "@context" => "https://www.w3.org/ns/activitystreams",
          "id" => id,
          "attributedTo" => "#{url}/actor.jsonld",
          "type" => "OrderedCollectionPage",
          "partOf" => "#{url}/#{output_path}/outbox.jsonld",
          "summary" => "page #{page_number} of outbox of #{name(site)}",
          "orderedItems" => [],
          "to" => "as:Public"
        }

        page["prev"] = "#{url}/#{output_path}/outbox/page-#{page_number - 1}.jsonld" if page_number > 1
        page
      end

      def article_summary(site, post)
        property = site.config.dig("activitypub", "summary_property") || "description"
        explicit = post.data[property]
        return explicit unless explicit.to_s.strip.empty?

        excerpt = post.data["excerpt"]
        excerpt.output
      end

      def note?(site, post)
        title = post.data["title"]
        return false unless title.to_s.strip.empty?

        summary = explicit_summary(site, post)
        return false unless summary.to_s.strip.empty?

        return false unless paragraph_count(post.content) == 1

        plain_text(post.content).length <= note_max_characters(site)
      end

      def post_type(site, post)
        note?(site, post) ? "Note" : "Article"
      end

      def explicit_summary(site, post)
        property = site.config.dig("activitypub", "summary_property") || "description"
        post.data[property]
      end

      def note_max_characters(site)
        site.config.dig("activitypub", "note_max_characters") || 500
      end

      def paragraph_count(content)
        content.scan(/<p\b[^>]*>/).length
      end

      def plain_text(content)
        content.gsub(/<[^>]*>/, "")
      end

      def homepage_url(site)
        url = site.config["url"]
        url.end_with?("/") ? url : "#{url}/"
      end

      def webfinger_address(site)
        url = site.config["url"]
        host = URI(url).host
        "#{preferred_username(site)}@#{host}"
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_render do |site|
  generator = Jekyll::ActivityPubStatic::Generator.new(site.config)

  generator.generate_articles(site)
  generator.generate_activities(site)
  generator.generate_outbox_pages(site)
  generator.generate_outbox(site)
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  site = post.site
  url = site.config["url"]
  output_path = site.config.dig("activitypub", "output_path") || "activitypub"
  slug = post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")
  post.data["activitypub_url"] = "#{url}/#{output_path}/posts/#{slug}.jsonld"
end

Jekyll::Hooks.register :pages, :post_init do |page|
  next unless page.url == "/"

  site = page.site
  page.data["activitypub_url"] = "#{site.config["url"]}/actor.jsonld"
end
