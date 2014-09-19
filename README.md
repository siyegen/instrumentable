# Instrumentable [![Gem Version](https://badge.fury.io/rb/instrumentable.png)](http://badge.fury.io/rb/instrumentable)
-note, this version is not backwards compatiable

Decorate all your favorite methods with ActiveSupport::Notifications.instrument

This gem allows you to wrap methods on your classes for use with AS::N without having
to put AS::N.instrument do blocks around everything. You can customize the
payload sent with the event, and in addition all of the method args(if any) are sent
as well

## Installation

Add this line to your application's Gemfile:

    gem "instrumentable", "~> 1.1.0"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install instrumentable

## Usage
include the gem in your class
```ruby
include Instrumentable
```
to instrument an instance method
```ruby
instrument_method :method_name, 'event.to.fire', :payload_key => :payload_value
```

``` :method_name ```

Is the name of the method you want to instrument

``` 'event.to.fire' ```

Is the name of the event you'll setup your subscriber for
This can be any string

``` :payload_key => :payload_value ```

The last part is the payload, which consists of a key and a value.
What is sent to the subscriber depends on what is passed in as the value
+ String
  + ex: ```'static_string'```
  + string is passed in as-is to the payload
+ Symbol
  + ex: ```:method_name```
  + calls symbol as a method on the class in the current context (class, intance)
+ Proc
  + ex: ```Proc.new { Time.now }```
  + calls the proc, returning the value

All payloads will recieve a list of the arguments called with the method under
```:_method_args```, this will be an empty array if the method was called with no args

If you want to instrument a class method, you must use a separate method
```ruby
class_instrument_method  self, :method_name, 'event.to.fire', :payload_key => :payload_value
```
You must use ```class_instrument_method``` instead and pass the first argument in as ```self```

## Examples
```ruby
require "instrumentable"

class WidgetRenderer
  include Instrumentable

  attr_reader :id, :name

  def render
    # do crazy render here
  end 

  def load(options)
    # make call here
  end

  def self.add(location)
    # ...
  end

  private
  def valid?
    # returns if call is valid
  end
  instrument_method :render, 'render.widget', :widget_id => :id, :widget_name => :name
  instrument_method :load, 'load.widget', :status => 'loading', :valid => :valid?
  class_instrument_method :add, 'add.widget'
end
```

## Requirements
* ActiveSupport

## Running Tests

    rake test

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
