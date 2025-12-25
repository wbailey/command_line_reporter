# Repository Guidelines

## Project Structure & Module Organization
This is a Ruby gem. The main entry point is `lib/command_line_reporter.rb`, with
core classes under `lib/command_line_reporter/` (tables, rows, columns, options
validation) and formatter implementations in `lib/command_line_reporter/formatter/`.
RSpec specs live in `spec/`, with shared helpers and matchers under
`spec/support/`. Packaging and tooling files include `command_line_reporter.gemspec`,
`Gemfile`, `Rakefile`, and `Guardfile`.

## Build, Test, and Development Commands
- Use Ruby 3.4.8 (see `.ruby-version`) and `bundle install` before running commands.
- `bundle install` installs development and runtime dependencies.
- `bundle exec rspec` runs the full test suite.
- `bundle exec guard` runs specs on file changes (per `Guardfile`).
- `bundle exec rubocop` checks style against `.rubocop.yml`.
- `bundle exec rake build` builds the gem package (Bundler gem tasks).

## Coding Style & Naming Conventions
- Ruby with 2-space indentation.
- Use standard Ruby naming: `snake_case` for methods/variables and `CamelCase`
  for classes/modules.
- Follow `.rubocop.yml` (line length limits are disabled; documentation is not
  required by default).
- Keep formatter-specific code in `lib/command_line_reporter/formatter/` and
  public API methods within the `CommandLineReporter` module.

## Testing Guidelines
- RSpec is the test framework; files use the `*_spec.rb` naming pattern.
- Load shared helpers via `spec/spec_helper.rb`.
- Add or update specs close to the feature they cover (for example,
  `lib/command_line_reporter/table.rb` → `spec/table_spec.rb`).
- No explicit coverage threshold is enforced.

## Commit & Pull Request Guidelines
- Commit messages in history are short and descriptive (often lowercase, e.g.,
  "version bump", "updated documentation"). Keep summaries concise and focused.
- Prefer small, single-purpose commits that describe intent or affected area.
- PRs should include: a brief problem statement, summary of changes, tests run,
  and any behavior changes. Link related issues when applicable.
