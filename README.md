# BackgroundMigrations

Manage the manual running of migrations

Sometimes migrations have to be run on certain environments at certain times to avoid busy periods. This gem adds functionality to allow migrations to be added to the codebase and then actually executed on each environment manually. The migration will appear as normal in the schema_migrations table and will be reflected in development.

It's recommended that the time between merging the migration and running it on every environment is kept as short as possible, to avoid accidentally releasing new code that relies on the migration having run in every environment.

## Installation

In your Gemfile:

```
gem "background_migrations", git: "https://github.com/dentally/background_migrations"
```

## Usage

Within a migration:

```
class MyMigration < ActiveRecord::Migration[7.0]
  include BackgroundMigrations

  background_migration { Rails.env.production? }
```

This will run the migration as normal in every Rails environment except production. On production, it will treat the migration as run, add it to schema_migrations and also add it to the pending background migrations list. You can view the list of pending migrations using:

```
bundle exec rake background_migrations:list_pending_migrations
```

You can run a pending migration using:

```
bundle exec rake background_migrations:run_pending_migration[VERSION_NUMBER]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/background_migrations.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
