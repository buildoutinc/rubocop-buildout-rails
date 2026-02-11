# frozen_string_literal: true

require "rubocop"
require "pathname"
require_relative "rails/version"

module RuboCop
  module Buildout
    module Rails # rubocop:disable Style/Documentation
      class Error < StandardError; end

      PROJECT_ROOT = Pathname.new(__dir__).parent.parent.parent.expand_path
      CONFIG_DEFAULT = PROJECT_ROOT.join("config", "default.yml").freeze

      private_constant(:CONFIG_DEFAULT)

      # Load the default configuration
      def self.config
        @config ||= ::RuboCop::ConfigLoader.load_file(CONFIG_DEFAULT.to_s)
      end

      # Inject our configuration into RuboCop
      def self.inject!
        path = CONFIG_DEFAULT.to_s
        hash = ::RuboCop::ConfigLoader.send(:load_yaml_configuration, path)
        puts "configuration from #{path}" if ::RuboCop::ConfigLoader.debug?

        # Merge each key from our config into the default configuration
        hash.each do |key, value|
          ::RuboCop::ConfigLoader.default_configuration[key] = value
        end
      end
    end
  end
end

# Require all cops BEFORE injecting config
# This ensures cops are registered before config validation
RuboCop::Buildout::Rails::PROJECT_ROOT.join("lib/rubocop/cop/buildout/rails").glob("*.rb").each do |path|
  require path
end

RuboCop::Buildout::Rails.private_constant :PROJECT_ROOT

# Auto-inject when this module is loaded
RuboCop::Buildout::Rails.inject!
