# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

# Override rubygem_push. The server is already blank in gemspec, but this prevents the prompt altogether.
Rake::Task["release:rubygem_push"].clear
task "release:rubygem_push" do # rubocop:disable Rake/Desc
  puts "Skipping gem push - use github as a source instead"
end
