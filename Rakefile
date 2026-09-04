require "rake/testtask"
require "rubocop/rake_task"
require "bundler/gem_tasks"

# === Lint ===
RuboCop::RakeTask.new(:lint) do |t|
  t.options = ["--cache", "false"]
end

# === Test ===
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = true
end

task default: :test

# === Install locally ===
desc "Build and install the gem locally"
task :install do
  sh "gem build jekyll-activitypub-static.gemspec"
  sh "gem install ./jekyll-activitypub-static-#{version_from_gemspec}.gem"
end

# === Helpers ===
def version_from_gemspec
  File.read("lib/jekyll/activitypub_static/version.rb")[/VERSION\s*=\s*["'](.+)["']/, 1]
end
