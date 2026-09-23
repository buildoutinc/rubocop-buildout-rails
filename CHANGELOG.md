## [Unreleased]

## [0.2.0] - 2026-09-23

- Add `Buildout/Rails/TravelToNestedStub`, which flags an `allow`/`expect` stub on `Date.today`,
  `Time.now`, or `DateTime.now` nested inside a `travel_to`, `travel`, or `freeze_time` block. The
  two stubbing mechanisms don't compose: RSpec's teardown restores the method to the travel helper's
  own stub instead of the original, corrupting it for the rest of the test process.

## [0.1.0] - 2026-02-10

- Initial release
