# Claude Code Instructions for rubocop-buildout-rails

A RuboCop extension gem providing custom cops (linting rules) for Rails projects at Buildout.

See [CONTRIBUTING.md](CONTRIBUTING.md) for project structure, development workflow, cop conventions,
and the release process.

See [README.md](README.md) for the list of current cops and their usage.

Before declaring a minimum `rubocop`/`rubocop-ast` version in the gemspec, bisect against real gem
versions rather than assuming - see "Verifying Minimum Dependency Versions" in
[CONTRIBUTING.md](CONTRIBUTING.md).

## Privacy: no references to private repos/projects

This gem is (or may become) publicly viewable. Do not reference any private repo or project by name
in code, comments, commit messages, PRs, issues, or any other content in this repo.

It is fine to describe a specific scenario that motivated a cop (e.g. "N+1 query introduced when a
association is loaded inside a loop") as long as the private repo or project where it was found is
not named. The scenario should be described in terms of what this repo's cop targets, not where the
problem was discovered.
