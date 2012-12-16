require "minitest_helper"
require_relative "../lib/instrumentable"

class FakeModel
  include Instrumentable
  def simple_event;end
  def false_event;end
  def payload_event;end
  def self.event;end

  instrument_method :simple_event,   'event.name',   :my_payload => :id
  instrument_method :false_event,    'event.name',   :my_payload => :valid
  instrument_method :payload_event,  'payload.name', :my_payload => 'megaman'

  class_instrument_method FakeModel, :event, 'payload.name', :my_payload => :object_id
end

describe Instrumentable do

  it "must instrument simple_event" do
    fm = FakeModel.new
    def fm.id; 1; end
    expected = ["event.name-#{fm.id}"]
    events = []

    callback = lambda { |*_| events << "#{_.first}-#{_.last[:my_payload]}" }
    ActiveSupport::Notifications.subscribed(callback, 'event.name') do
      fm.simple_event
      ActiveSupport::Notifications.instrument('other.event')
    end
    events.must_equal expected
  end

  it "must work with callable payload that returns false" do
    fm = FakeModel.new
    def fm.valid; false; end
    expected = ["event.name-#{fm.valid}"]
    events = []

    callback = lambda { |*_| events << "#{_.first}-#{_.last[:my_payload]}" }
    ActiveSupport::Notifications.subscribed(callback, 'event.name') do
      fm.false_event
      ActiveSupport::Notifications.instrument('other.event')
    end
    events.must_equal expected
  end

  it "must handle non-callable payloads" do
    fm = FakeModel.new
    expected = ['payload.name-megaman']
    events = []

    callback = lambda { |*_| events << "#{_.first}-#{_.last[:my_payload]}" }
    ActiveSupport::Notifications.subscribed(callback, 'payload.name') do
      fm.payload_event
      ActiveSupport::Notifications.instrument('other.event')
    end
    events.must_equal expected
  end

  it "must handle class methods" do
    object_id = FakeModel.object_id
    expected = ["payload.name-#{object_id}"]
    events = []

    callback = lambda { |*_| events << "#{_.first}-#{_.last[:my_payload]}" }
    ActiveSupport::Notifications.subscribed(callback, 'payload.name') do
      FakeModel.event
      ActiveSupport::Notifications.instrument('other.event')
    end
    events.must_equal expected
  end
end
