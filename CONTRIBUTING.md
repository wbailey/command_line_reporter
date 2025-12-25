# Contributing

Thanks for contributing to Command Line Reporter! This project is a Ruby gem
and uses RSpec and RuboCop for quality checks.

## Setup

```bash
bundle install
```

## Development Workflow

1. Create a feature branch.
2. Keep changes focused and add/update tests.
3. Run the test suite and linters before opening a PR.

## Tests and Linting

```bash
bundle exec rspec
bundle exec rubocop
bundle exec reek
```

## Code Style

- Ruby with 2-space indentation.
- Follow `.rubocop.yml` and keep methods readable.
- Prefer small, single-purpose changes with clear commit messages.

## Pull Requests

Include a short summary, test output, and any behavior changes. Link issues when
applicable.
