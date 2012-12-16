require "securerandom"
require "active_support/concern"
require "active_support/notifications"
require "instrumentable/version"

# Includes +instrument_for+ into the class. The class uses it by adding
# the instrument_for method to the end of the class specifying
# what method to apply it to.
module Instrumentable
  extend ActiveSupport::Concern

  module ClassMethods
    # Internal: Decorates :method_to_instrument with  AS::N.instrument
    # firing with :event_name to the matching AS::N.subscribe
    #
    # Example:
    #
    #   # Decorates render method with AS:N:instrument 'model.render' and passes
    #   # a payload of :model_name and :id to the subscribe method
    #   instrument_for :render, 'model.render', {:model_name => :model_name, :id => :id
    def instrument_for(method_to_instrument, event_name, payload={})
      @@__instrumentation.(self, method_to_instrument, event_name, payload)
    end


    def class_instrument_for(klass, method_to_instrument, event_name, payload={})
      class << klass; self; end.class_eval do
        @@__instrumentation.(self, method_to_instrument, event_name, payload)
      end
    end

    private
    @@__instrumentation = Proc.new do |klass, method_to_instrument, event_name, payload|
      instrument_method = :"instrument_for_#{method_to_instrument}"

      klass.send :alias_method, instrument_method, method_to_instrument

      klass.send(:define_method, method_to_instrument) do |*args, &block|
        callable_payload = payload.inject({}) do |result, (payload_key, payload_value)|
          value = if respond_to?(payload_value)
                    __send__ payload_value
                  else
                    payload_value
                  end
          result.tap { |r| r[payload_key] = value }
        end
        ActiveSupport::Notifications.instrument event_name, callable_payload do
          __send__(instrument_method, *args, &block)
        end
      end
    end
  end
end
