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

    def self.begin(*args)
      alias_define(args) do |ensemble|
        define(ensemble)
      end
    end

    def self.define(ensemble)
      ensemble.klass.send(:define_method, ensemble.original_method) do |*args, &block|
        event_payload = ensemble.payload.inject({}) do |result, (payload_key, payload_value)|
          value = ensemble.invoke_value(self, payload_value)
          result.tap { |r| r[payload_key] = value }
        end
        ActiveSupport::Notifications.instrument ensemble.event, event_payload do
          __send__(ensemble.instrumented_method, *args, &block)
        end
      end
    end

    def self.alias_define(args)
      ensemble = Ensemble.new(*args)
      ensemble.klass.send :alias_method, ensemble.instrumented_method, ensemble.original_method
      yield ensemble
    end
  end

  class Ensemble
    attr_reader :klass, :original_method, :event, :payload, :instrumented_method

    def initialize(klass, method, event, payload)
      @klass, @original_method, @event, @payload = klass, method, event, payload
      @instrumented_method = :"instrument_for#{@original_method}"
    end

    def invoke_value(klass, obj)
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
