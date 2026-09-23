# Claude Code Instructions for rubocop-buildout-rails

## Project Overview

This is a RuboCop extension gem that provides custom cops (linting rules) for Rails projects at Buildout. The gem follows standard RuboCop plugin conventions.

**Key Information:**
- **Language:** Ruby
- **Framework:** RuboCop plugin
- **Purpose:** Custom linting rules for Rails applications
- **Dependencies:** rubocop ~> 1.0, rubocop-rails ~> 2.0
- **Ruby Version:** >= 3.0.0 (currently using 3.0)

## Project Structure

```
lib/
  rubocop-buildout-rails.rb                   # Main entry point
  rubocop/
    buildout/
      rails.rb                                # Module definition
      rails/version.rb                        # Version constant
    cop/buildout/rails/                       # Custom cop implementations
      with_options_condition_overwrite.rb     # WithOptionsConditionOverwrite cop
config/
  default.yml                                 # Default cop configuration
spec/
  spec_helper.rb                              # RSpec configuration
  rubocop/
    buildout/rails_spec.rb                    # Module specs
    cop/buildout/rails/                       # Cop tests
      with_options_condition_overwrite_spec.rb
bin/
  console                                     # Interactive console for testing
  setup                                       # Setup script
```

## Development Workflow

### Setup
```bash
bin/setup  # Install dependencies
```

### Running Tests
```bash
bundle exec rake spec           # Run RSpec tests
bundle exec rake rubocop        # Run RuboCop linter
bundle exec rake                # Run both tests and linter (default task)
```

### Testing Cops Locally
```bash
bin/console  # Interactive console for experimentation
```

### Installing Locally
```bash
bundle exec rake install  # Install gem locally for testing
```

### Code Style
- Follow RuboCop's own style guide
- Use `frozen_string_literal: true` at the top of all Ruby files
- Run `bundle exec rubocop` before committing
- Default rake task runs both specs and rubocop

## Creating New Cops

When adding a new cop, follow these steps:

1. **Create the cop file** in `lib/rubocop/cop/buildout/rails/`
   - Inherit from `RuboCop::Cop::Base`
   - Include helpful message and example in comments
   - Use `extend AutoCorrector` if auto-correction is possible

2. **Add configuration** to `config/default.yml`
   - Set default `Enabled: true` or `false`
   - Add `Description` and `VersionAdded`
   - Include example bad/good code

3. **Write comprehensive specs** in `spec/rubocop/cop/buildout/rails/`
   - Test both offense detection and auto-correction (if applicable)
   - Include edge cases
   - Use `expect_offense` and `expect_correction` helpers

4. **Update README.md** with the new cop documentation
   - Add cop name and description
   - Provide clear examples of bad and good code

### Cop Naming Convention
- Namespace: `Buildout/Rails/`
- Class name: `CamelCase` describing the rule
- Example: `WithOptionsConditionOverwrite`

### Testing Pattern
```ruby
RSpec.describe RuboCop::Cop::Buildout::Rails::YourCop do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when...' do
    expect_offense(<<~RUBY)
      # bad code with markers
      ^^^^ Message text
    RUBY
  end

  it 'does not register an offense when...' do
    expect_no_offenses(<<~RUBY)
      # good code
    RUBY
  end
end
```

## Git Workflow

- Main branch: `main`
- Feature branches: Use descriptive names like `add-cop-name` or `fix-cop-name`
- Commit messages: Follow conventional commits format
  - `feat: add new cop for ...`
  - `fix: correct behavior in ...`
  - `docs: update README for ...`

## Release Process

**Note:** This gem has `allowed_push_host` set to empty string, which disables pushing to rubygems.org. It's intended for internal use only.

1. Update version in `lib/rubocop/buildout/rails/version.rb`
2. Update `CHANGELOG.md` with changes under `## [Unreleased]`
3. Create a new version section in CHANGELOG with date
4. Commit: `git commit -am "Release v0.x.x"`
5. Tag: `git tag v0.x.x`
6. Push: `git push && git push --tags`
7. Build gem: `bundle exec rake build` (creates pkg/ directory)
8. For internal distribution, share the built gem file from `pkg/`

## Current Cops

### Buildout/Rails/WithOptionsConditionOverwrite
Checks for conditional keys (`if`/`unless`) inside `with_options` blocks that overwrite the same keys from the outer block.

**Location:** [lib/rubocop/cop/buildout/rails/with_options_condition_overwrite.rb](lib/rubocop/cop/buildout/rails/with_options_condition_overwrite.rb)

### Buildout/Rails/TravelToNestedStub
Checks for an `allow`/`expect` stub on `Date.today`, `Time.now`, or `DateTime.now` nested inside a `travel_to`, `travel`, or `freeze_time` block. Those helpers already stub the same three methods; RSpec's teardown restores the method to the travel helper's own stub instead of the true original, corrupting it for every later spec in the same process.

**Location:** [lib/rubocop/cop/buildout/rails/travel_to_nested_stub.rb](lib/rubocop/cop/buildout/rails/travel_to_nested_stub.rb)

## Important Notes

- Always run tests before committing (`bundle exec rake` runs both specs and rubocop)
- Ensure all cops have comprehensive test coverage
- Keep cop logic focused and single-purpose
- Auto-correction should be safe and preserve intent
- Document all cops in README.md with clear examples
- This gem disables pushing to rubygems.org - it's for internal Buildout use only

## Files to Update When Adding a Cop

1. Create cop implementation: `lib/rubocop/cop/buildout/rails/your_cop.rb`
2. Add configuration: `config/default.yml`
3. Write tests: `spec/rubocop/cop/buildout/rails/your_cop_spec.rb`
4. Document in: `README.md`
5. Optionally add to: This CLAUDE.md file under "Current Cops"
