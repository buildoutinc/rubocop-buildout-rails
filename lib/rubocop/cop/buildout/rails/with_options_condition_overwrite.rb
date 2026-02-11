# frozen_string_literal: true

# # FLAG: Overwrites outer :if
# with_options if: :active?
#   validates :email, presence: true, if: :changed?
# end
#
# # FLAG: Overwrites outer :if (nested conditionals)
# with_options if: :active?
#   validates :email, presence: { if: :changed? }
# end
#
# # FLAG: Overwrites outer :unless
# with_options unless: :active?
#   validates :email, presence: true, unless: :changed?
# end
#
# # IGNORE: 'on' is not a conditional key
# with_options if: :active?
#   validates :email, presence: true, on: :create
# end
#
# # IGNORE: 'if' exists inside, but not in the outer block
# with_options allow_nil: true do
#   validates :email, presence: true, if: :active?
# end
#
# NOTES:
# Also works when `with_options` has a block variable.

module RuboCop
  module Cop
    module Buildout
      module Rails
        # This cop checks for 'if' or 'unless' keys inside a 'with_options' block
        # that already defines those same keys, as the inner will overwrite the outer.
        class WithOptionsConditionOverwrite < ::RuboCop::Cop::Base
          MSG = 'This conditional overwrites the "%<key>s" condition from the outer `with_options` block.'

          # We only care about these two keys
          CONDITIONAL_KEYS = %i[if unless].freeze

          # Matcher to find the with_options block and capture the options hash
          def_node_matcher :with_options_block?, <<~PATTERN
            (block
              (send nil? :with_options (hash $...))
              ...)
          PATTERN

          def on_block(node) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
            with_options_block?(node) do |options|
              # Identify which conditional keys are present in the outer with_options
              outer_conditionals = options.filter_map { |pair| pair.key.value if pair.key.sym_type? }
                                          .select { |k| CONDITIONAL_KEYS.include?(k) }

              return if outer_conditionals.empty?

              # Scan the body of the block for any hash nodes (including nested ones)
              node.each_descendant(:hash) do |hash_node|
                # Skip the with_options hash itself
                next if hash_node.parent&.send_type? && hash_node.parent.method_name == :with_options

                hash_node.pairs.each do |pair|
                  next unless pair.key.sym_type?

                  # Only flag if the inner key is in our specific list AND exists in the outer block
                  if outer_conditionals.include?(pair.key.value)
                    add_offense(pair, message: format(MSG, key: pair.key.value))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
