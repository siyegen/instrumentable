require "securerandom"
require "active_support/concern"
require "active_support/notifications"
require "instrumentable/version"

module Instrumentable
  extend ActiveSupport::Concern

  module ClassMethods
    def instrument_method(method_to_instrument, event_name, payload={})
      Instrumentality.begin(self, method_to_instrument, event_name, payload)
    end

    def class_instrument_method(klass, method_to_instrument, event_name, payload={})
      class << klass; self; end.class_eval do
        Instrumentality.begin(self, method_to_instrument, event_name, payload)
      end
    end
  end

  private
  class Instrumentality

    def self.begin(klass, method, event, payload)
      instrumentality = self
      instrumented_method = :"instrument_for#{method}"
      klass.send :alias_method, instrumented_method, method

      klass.send(:define_method, method) do |*args, &block|
        event_payload = payload.inject({}) do |result, (payload_key, payload_value)|
          value = instrumentality.invoke_value(self, payload_value)
          result.tap { |r| r[payload_key] = value }
        end
        event_payload.merge!({:_method_args => args})
        ActiveSupport::Notifications.instrument event, event_payload do
          __send__(instrumented_method, *args, &block)
        end
      end
    end

    def self.invoke_value(klass, obj)
      case obj
      when Symbol
        klass.__send__ obj
      when Proc
        obj.call
      when String
        obj
      end
    end
  end
end
