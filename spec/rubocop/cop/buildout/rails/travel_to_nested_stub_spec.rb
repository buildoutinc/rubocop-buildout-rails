# frozen_string_literal: true

require "spec_helper"
require "rubocop"
require "rubocop/rspec/support"
require "rubocop/cop/buildout/rails/travel_to_nested_stub"

RSpec.describe RuboCop::Cop::Buildout::Rails::TravelToNestedStub, :config do
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }

  describe "when detecting a stub travel_to itself also stubs" do
    it "registers an offense for allow(Date).to receive(:today) inside travel_to" do
      expect_offense(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
                         ^^^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Date.today` inside `travel_to` corrupts it for the rest of the run: RSpec restores it to the `travel_to` stub instead of the original method. Pass the target time to `travel_to` directly, or stub `Date.today` without `travel_to`.
        end
      RUBY
    end

    it "registers an offense for expect(Time).to receive(:now) inside freeze_time" do
      expect_offense(<<~RUBY)
        freeze_time do
          expect(Time).to receive(:now).and_return(Time.utc(2026, 1, 1))
                          ^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Time.now` inside `freeze_time` corrupts it for the rest of the run: RSpec restores it to the `freeze_time` stub instead of the original method. Pass the target time to `freeze_time` directly, or stub `Time.now` without `freeze_time`.
        end
      RUBY
    end

    it "registers an offense for allow(DateTime).to receive(:now) inside travel" do
      expect_offense(<<~RUBY)
        travel(1.day) do
          allow(DateTime).to receive(:now).and_return(DateTime.new(2026, 1, 2))
                             ^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `DateTime.now` inside `travel` corrupts it for the rest of the run: RSpec restores it to the `travel` stub instead of the original method. Pass the target time to `travel` directly, or stub `DateTime.now` without `travel`.
        end
      RUBY
    end

    it "registers an offense without a chained and_return" do
      expect_offense(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          allow(Date).to receive(:today)
                         ^^^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Date.today` inside `travel_to` corrupts it for the rest of the run: RSpec restores it to the `travel_to` stub instead of the original method. Pass the target time to `travel_to` directly, or stub `Date.today` without `travel_to`.
        end
      RUBY
    end

    it "registers an offense for expect(...).not_to receive" do
      expect_offense(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          expect(Date).not_to receive(:today)
                              ^^^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Date.today` inside `travel_to` corrupts it for the rest of the run: RSpec restores it to the `travel_to` stub instead of the original method. Pass the target time to `travel_to` directly, or stub `Date.today` without `travel_to`.
        end
      RUBY
    end

    it "registers an offense for a top-level constant reference (::Date)" do
      expect_offense(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          allow(::Date).to receive(:today)
                           ^^^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Date.today` inside `travel_to` corrupts it for the rest of the run: RSpec restores it to the `travel_to` stub instead of the original method. Pass the target time to `travel_to` directly, or stub `Date.today` without `travel_to`.
        end
      RUBY
    end

    it "registers an offense inside a brace block with a numbered parameter" do
      expect_offense(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) { allow(Time).to receive(:now); do_something(_1) }
                                                                ^^^^^^^^^^^^^ Buildout/Rails/TravelToNestedStub: Stubbing `Time.now` inside `travel_to` corrupts it for the rest of the run: RSpec restores it to the `travel_to` stub instead of the original method. Pass the target time to `travel_to` directly, or stub `Time.now` without `travel_to`.
      RUBY
    end
  end

  describe "when NOT detecting false positives" do
    it "does not register an offense for a method travel_to does not stub" do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          allow(Date).to receive(:current).and_return(Date.new(2026, 1, 2))
        end
      RUBY
    end

    it "does not register an offense outside any travel helper block" do
      expect_no_offenses(<<~RUBY)
        allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
      RUBY
    end

    it "does not register an offense for an unrelated double inside travel_to" do
      expect_no_offenses(<<~RUBY)
        travel_to(Time.zone.local(2026, 1, 1)) do
          allow(company).to receive(:commissions).and_return([])
        end
      RUBY
    end
  end
end
