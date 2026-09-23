# frozen_string_literal: true

# # FLAG: allow(...) restubs a method that travel_to itself stubs
# travel_to(Time.zone.local(2026, 1, 1)) do
#   allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
#   ...
# end
#
# # FLAG: same collision via travel / freeze_time, or via expect(...)
# freeze_time do
#   expect(Time).to receive(:now).and_return(Time.utc(2026, 1, 1))
# end
#
# # IGNORE: stubbing a method travel_to does not touch
# travel_to(Time.zone.local(2026, 1, 1)) do
#   allow(Date).to receive(:current).and_return(Date.new(2026, 1, 2))
# end
#
# # IGNORE: the same stub outside any travel_to/travel/freeze_time block
# allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
#
# NOTES:
# travel_to (and travel/freeze_time, which both delegate to it) stub Time.now, Date.today, and
# DateTime.now by renaming the original method and defining a replacement. If an `allow`/`expect`
# stub for one of those same three methods is set up *inside* the block, RSpec's own teardown
# restores the method to the travel_to-installed stub instead of the true original when the
# example ends - permanently corrupting it for every later spec in the same process.

module RuboCop
  module Cop
    module Buildout
      module Rails
        # This cop checks for an `allow`/`expect` stub on `Date.today`, `Time.now`, or
        # `DateTime.now` set up inside a `travel_to`, `travel`, or `freeze_time` block, since those
        # helpers already stub the same methods and the two stubbing mechanisms do not compose.
        class TravelToNestedStub < ::RuboCop::Cop::Base
          MSG = "Stubbing `%<klass>s.%<method>s` inside `%<helper>s` corrupts it for the rest of " \
                "the run: RSpec restores it to the `%<helper>s` stub instead of the original " \
                "method. Pass the target time to `%<helper>s` directly, or stub " \
                "`%<klass>s.%<method>s` without `%<helper>s`."

          RESTRICT_ON_SEND = %i[receive].freeze

          TRAVEL_HELPERS = %i[travel_to travel freeze_time].freeze

          # `expect(...).not_to`/`to_not` install a stub just like `.to`, so they collide too.
          TO_METHODS = %i[to not_to to_not].freeze

          # Methods travel_to itself stubs (Time.now, Date.today, DateTime.now) - the only ones
          # that collide when also stubbed with allow/expect inside the block.
          COLLIDING_METHODS = {
            Date: :today,
            Time: :now,
            DateTime: :now
          }.freeze

          def_node_matcher :receive_call?, <<~PATTERN
            (send nil? :receive (sym $_))
          PATTERN

          def_node_matcher :allow_or_expect_const, <<~PATTERN
            (send nil? {:allow :expect} (const {nil? cbase} $_))
          PATTERN

          def on_send(node)
            receive_call?(node) do |method_name|
              # `receive(...)` may be chained further, e.g. `.and_return(...)`, so the enclosing
              # `.to`/`.not_to`/`.to_not` call has to be found by walking up rather than assumed
              # to be the direct parent.
              to_node = node.each_ancestor(:send).find { |ancestor| TO_METHODS.include?(ancestor.method_name) }
              next unless to_node

              klass = allow_or_expect_const(to_node.receiver)
              next unless klass && COLLIDING_METHODS[klass] == method_name

              helper_name = enclosing_travel_helper(node)
              next unless helper_name

              add_offense(node, message: format(MSG, klass: klass, method: method_name, helper: helper_name))
            end
          end

          private

          # The method name of the nearest enclosing travel_to/travel/freeze_time block, or nil.
          # `:any_block` also matches `numblock`/`itblock` (numbered-parameter and `it` blocks),
          # not just the classic `do...end`/`{...}` block with an explicit parameter.
          def enclosing_travel_helper(node)
            block = node.each_ancestor(:any_block).find do |ancestor|
              TRAVEL_HELPERS.include?(ancestor.send_node.method_name)
            end
            block&.send_node&.method_name
          end
        end
      end
    end
  end
end
