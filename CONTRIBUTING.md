# Contributing to RailsClocks

First off, thank you for considering contributing to RailsClocks! It's people like you that make RailsClocks such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include details about your configuration and environment

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Create an issue and provide the following information:

* Use a clear and descriptive title
* Provide a step-by-step description of the suggested enhancement
* Provide specific examples to demonstrate the steps
* Describe the current behavior and explain which behavior you expected to see instead

### Pull Requests

* Fork the repo and create your branch from `main`
* If you've added code that should be tested, add tests
* Ensure the test suite passes
* Make sure your code lints
* Update the documentation

## Development Setup

1. Fork and clone the repository
2. Run `bundle install` to install dependencies
3. Run `bundle exec rake spec` to run the tests

## Testing

We use RSpec for testing. To run the test suite:

```bash
bundle exec rspec
```

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### Ruby Styleguide

* Follow the [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide)
* Run RuboCop before submitting: `bundle exec rubocop`

## License

By contributing, you agree that your contributions will be licensed under the MIT License. 