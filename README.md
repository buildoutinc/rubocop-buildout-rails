# rubocop-buildout-rails

A collection of RuboCop rules for Rails projects at Buildout.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-buildout-rails', require: false
```

And then execute:

    $ bundle install

## Usage

Add the following to the top of your `.rubocop.yml`:

```yaml
require:
  - rubocop-buildout-rails
```

The gem will automatically load all custom cops and their default configuration.

## Cops

### Buildout/Rails/WithOptionsConditionOverwrite

This cop checks for conditional keys (`if` or `unless`) inside a `with_options` block that overwrite the same keys from the outer block.

```ruby
# bad - inner :if overwrites outer :if
with_options if: :active? do
  validates :email, presence: true, if: :changed?
end

# good - use different conditions or refactor
with_options if: :active? do
  validates :email, presence: true
end
```

### Buildout/Rails/TravelToNestedStub

This cop checks for an `allow`/`expect` stub on `Date.today`, `Time.now`, or `DateTime.now` set up
inside a `travel_to`, `travel`, or `freeze_time` block. Those helpers already stub the same three
methods; nesting an RSpec stub on top of them means RSpec's teardown restores the method to the
travel helper's own stub instead of the true original, silently corrupting it for every later spec
in the same process.

```ruby
# bad - RSpec's teardown leaves Date.today corrupted after this example
travel_to(Time.zone.local(2026, 1, 1)) do
  allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
  ...
end

# good - assign the value directly, no travel_to needed
allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag.
