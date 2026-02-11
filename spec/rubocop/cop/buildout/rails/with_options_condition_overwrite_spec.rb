# frozen_string_literal: true

require "spec_helper"
require "rubocop"
require "rubocop/rspec/support"
require "rubocop/cop/buildout/rails/with_options_condition_overwrite"

RSpec.describe RuboCop::Cop::Buildout::Rails::WithOptionsConditionOverwrite, :config do
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }

  describe "when detecting condition overwrites" do
    context "with outer :if being overwritten" do
      it "registers an offense when inner validates has :if that overwrites outer :if" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, if: :changed?
                                              ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers an offense when :if is nested inside a presence hash" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: { if: :changed? }
                                          ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers an offense when using lambda for outer :if" do
        expect_offense(<<~RUBY)
          with_options if: -> { active? } do
            validates :email, presence: true, if: :changed?
                                              ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers an offense when using proc for inner :if" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, if: proc { |record| record.changed? }
                                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end
    end

    context "with outer :unless being overwritten" do
      it "registers an offense when inner validates has :unless that overwrites outer :unless" do
        expect_offense(<<~RUBY)
          with_options unless: :active? do
            validates :email, presence: true, unless: :changed?
                                              ^^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "unless" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers an offense when :unless is nested inside a presence hash" do
        expect_offense(<<~RUBY)
          with_options unless: :inactive? do
            validates :email, presence: { unless: :changed? }
                                          ^^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "unless" condition from the outer `with_options` block.
          end
        RUBY
      end
    end

    context "with block variable" do
      it "registers an offense when with_options has a block variable" do
        expect_offense(<<~RUBY)
          with_options if: :active? do |o|
            o.validates :email, presence: true, if: :changed?
                                                ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers an offense with block variable and nested conditionals" do
        expect_offense(<<~RUBY)
          with_options unless: :active? do |opts|
            opts.validates :name, presence: { unless: :persisted? }
                                              ^^^^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "unless" condition from the outer `with_options` block.
          end
        RUBY
      end
    end

    context "with multiple validations in the same block" do
      it "registers multiple offenses when multiple validations overwrite" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, if: :changed?
                                              ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
            validates :name, uniqueness: true, if: :new_record?
                                               ^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end

      it "registers offense for only the validation that overwrites" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true
            validates :name, uniqueness: true, if: :new_record?
                                               ^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end
    end

    context "with both :if and :unless in outer block" do
      it "registers offenses for both :if and :unless overwrites" do
        expect_offense(<<~RUBY)
          with_options if: :active?, unless: :archived? do
            validates :email, presence: true, if: :changed?
                                              ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
            validates :name, uniqueness: true, unless: :persisted?
                                               ^^^^^^^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "unless" condition from the outer `with_options` block.
          end
        RUBY
      end
    end
  end

  describe "when NOT detecting false positives" do
    context "with non-conditional keys" do
      it "does not register an offense when 'on' is used inside (not a conditional key)" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, on: :create
          end
        RUBY
      end

      it "does not register an offense for other non-conditional keys" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, allow_nil: true, strict: true
          end
        RUBY
      end
    end

    context "when conditional exists inside but not in outer block" do
      it "does not register an offense when outer has no :if but inner does" do
        expect_no_offenses(<<~RUBY)
          with_options allow_nil: true do
            validates :email, presence: true, if: :active?
          end
        RUBY
      end

      it "does not register an offense when outer has no :unless but inner does" do
        expect_no_offenses(<<~RUBY)
          with_options allow_nil: true do
            validates :email, presence: true, unless: :inactive?
          end
        RUBY
      end

      it "does not register an offense when outer has :if but inner has only :unless" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, unless: :inactive?
          end
        RUBY
      end

      it "does not register an offense when outer has :unless but inner has only :if" do
        expect_no_offenses(<<~RUBY)
          with_options unless: :inactive? do
            validates :email, presence: true, if: :active?
          end
        RUBY
      end
    end

    context "with block variable" do
      it "does not register an offense when block variable is used without conditional overwrites" do
        expect_no_offenses(<<~RUBY)
          with_options allow_nil: true do |o|
            o.validates :email, presence: true, if: :active?
          end
        RUBY
      end

      it "does not register an offense when block variable has different conditional than outer" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do |opts|
            opts.validates :email, presence: true, unless: :archived?
          end
        RUBY
      end

      it "does not register an offense when block variable validation has no conditionals" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do |o|
            o.validates :email, presence: true
            o.validates :name, uniqueness: true
          end
        RUBY
      end
    end

    context "with no conditional keys in outer block" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          with_options allow_nil: true, allow_blank: false do
            validates :email, presence: true, if: :active?
            validates :name, uniqueness: true, unless: :persisted?
          end
        RUBY
      end
    end

    context "with empty with_options block" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
          end
        RUBY
      end
    end

    context "with validations that have no conditional keys" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true
            validates :name, uniqueness: true
          end
        RUBY
      end
    end

    context "with nested hashes that don't contain conditionals" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: { message: "can't be blank" }
            validates :name, format: { with: /regex/, message: "invalid" }
          end
        RUBY
      end
    end
  end

  describe "edge cases" do
    context "with deeply nested hashes" do
      it "registers an offense even when conditional is deeply nested" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: { message: "error", options: { if: :changed? } }
                                                                       ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
          end
        RUBY
      end
    end

    context "with string keys instead of symbols" do
      it "does not register an offense for string keys (only symbols are checked)" do
        expect_no_offenses(<<~RUBY)
          with_options if: :active? do
            validates :email, presence: true, "if" => :changed?
          end
        RUBY
      end
    end

    context "with mixed validations and other method calls" do
      it "registers offense for validates but not other methods" do
        expect_offense(<<~RUBY)
          with_options if: :active? do
            before_save :do_something
            validates :email, presence: true, if: :changed?
                                              ^^^^^^^^^^^^^ Buildout/Rails/WithOptionsConditionOverwrite: This conditional overwrites the "if" condition from the outer `with_options` block.
            after_save :do_something_else
          end
        RUBY
      end
    end

    context "with no hash options in with_options" do
      it "does not raise an error with empty with_options" do
        expect_no_offenses(<<~RUBY)
          with_options do
            validates :email, presence: true, if: :active?
          end
        RUBY
      end
    end
  end
end
