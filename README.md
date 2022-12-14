# Ficsit

This is an attempt to automate production calculation for Satisfactory.

## Todo:

- [x] Unify same resources required on different steps of production to single table to avoid resource diplication
- [ ] Reverse calculation for electricity: provide amount of resource (coal, crude oil, etc.) to calculate amount of factories to produce energy
- [x] Unify same materials required on different steps of production to single table to avoid resource diplication
- [x] Move total amount of materials into own hash, separate from basic :inputs

## Known issues

## Recipes

- Modular Frame is currently using Stitched Iron Plate instead of Reinfoirced, which is original.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ficsit'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ficsit

## Usage

```ruby
screws = Ficsit::Calc.new(1200)
screws.call # => {:name=>"Screws", :machines=>30.0, :inputs=>[{:name=>"Iron rod", :pieces_total=>300.0, :machines=>20.0}, {:name=>"Iron ingot", :pieces_total=>300.0, :machines=>10.0}, {:name=>"Iron", :pieces_total=>300.0, :machines=>10.0}]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ficsit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ficsit/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ficsit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ficsit/blob/master/CODE_OF_CONDUCT.md).
