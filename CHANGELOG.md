## [Unreleased]

## [0.2.1] - 2026-09-24

- Require `rubocop-ast >= 1.38` explicitly. `Buildout/Rails/TravelToNestedStub` uses the `:any_block`
  node type, which rubocop-ast only recognizes starting in 1.38 ([rubocop-ast#356](https://github.com/rubocop/rubocop-ast/pull/356));
  a project whose Gemfile.lock pinned an older rubocop-ast (transitively allowed by our loose
  `rubocop` constraint) would silently never match block/numblock ancestors, so the cop found no
  offenses. Verified against rubocop-ast 1.38.0 through 1.40.0 (pass) and 1.37.0 (fails as expected).

## [0.2.0] - 2026-09-23

- Add `Buildout/Rails/TravelToNestedStub`, which flags an `allow`/`expect` stub on `Date.today`,
  `Time.now`, or `DateTime.now` nested inside a `travel_to`, `travel`, or `freeze_time` block. The
  two stubbing mechanisms don't compose: RSpec's teardown restores the method to the travel helper's
  own stub instead of the original, corrupting it for the rest of the test process.

## [0.1.0] - 2026-02-10

- Initial release
