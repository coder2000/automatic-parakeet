# Prosopite

Prosopite is a gem to detect N+1 queries and other inefficient database queries in Rails applications.

## Installation

Add to your Gemfile:

```ruby
gem 'prosopite', group: [:development, :test]
```

Then run:

```sh
bundle install
```

## Configuration

Add the following to an initializer (e.g., `config/initializers/prosopite.rb`):

```ruby
if defined?(Prosopite)
  Prosopite.rails_logger = true
  Prosopite.enable_instrumentation
  Prosopite.ignore_queries_if = ->(env) { Rails.env.production? }
end
```

## Usage

- Prosopite will log N+1 queries to your Rails log in development and test environments.
- You can raise exceptions on N+1 by setting `Prosopite.raise = true` in the initializer.

## References

- <https://github.com/charkost/prosopite>
