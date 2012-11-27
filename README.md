# Instrumentable

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'instrumentable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instrumentable

## Usage
```ruby
require "instrumentable"

class WidgetRenderer
  include Instrumentable

  attr_reader   :id
  attr_accessor :name

  def render
    # do crazy render here
  end 

  instrument_for :render, 'load.widget', :widget_id => :id, :widget_name => :name
end
```

## Requirements
* ActiveSupport

## Running Tests

    ruby -Itest test/instrumentable_test.rb

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
