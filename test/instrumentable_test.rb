require "minitest_helper"
require_relative "../lib/instrumentable"

class FatherCat
  include Instrumentable
  attr_reader :cat_name
  def initialize; @cat_name="phill"; end
  def hello_everynyan; end
  def fake_cat; @cat_name = "mori";end
  def osaka; end
  def teachers(home, pe, geo); end
  def look_alike; return @cat_name; end
  def self.omg; end
  def self.sorry; "I'mma so sorry"; end
  def self.who?(person); end

  # String
  instrument_method :hello_everynyan, 'fathercat.greet', :payload => 'FatherCat'
  # Symbol
  instrument_method :fake_cat, 'fathercat.rant', :payload => :look_alike
  # Proc
  instrument_method :osaka, 'fathercat.ask', :payload => Proc.new { 'also cat tounged' }
  # Args
  instrument_method :teachers, 'fathercat.teachers', :payload => 'teachers'

  # Class
  class_instrument_method self, :omg, 'fathercat.anger', :payload => :sorry
  # Args
  class_instrument_method self, :who?, 'fathercat.who', :payload => 'who?'
end

describe Instrumentable do

  describe ".instrument_method" do
    it "must instrument fathercat.greet" do
      cat = FatherCat.new
      expected = ["fathercat.greet-FatherCat"]
      events = []

      callback = lambda { |*_| events << "#{_.first}-#{_.last[:payload]}" }
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.greet') do
        cat.hello_everynyan
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end

    it "must instrument fathercat.rant" do
      cat = FatherCat.new
      expected = ["fathercat.rant-mori"]
      events = []

      callback = lambda { |*_| events << "#{_.first}-#{_.last[:payload]}"; }
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.rant') do
        cat.fake_cat
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end

    it "must instrument fathercat.ask" do
      cat = FatherCat.new
      expected = ["fathercat.ask-also cat tounged"]
      events = []

      callback = lambda { |*_| events << "#{_.first}-#{_.last[:payload]}" }
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.ask') do
        cat.osaka
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end

    it "must pass method args to payload" do
      cat = FatherCat.new
      teachers = { :home => 'Yukari', :pe => 'Nyamo', :geo => 'Kimura' }
      expected = ["fathercat.teachers-#{teachers[:home]}_#{teachers[:pe]}_#{teachers[:geo]}"]
      events = []

      callback = lambda do |*_|
        event_name = _.first
        payload = _.last[:_method_args].join('_')
        events << "#{event_name}-#{payload}"
      end
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.teachers') do
        cat.teachers(teachers[:home], teachers[:pe], teachers[:geo])
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end
   end

  describe ".class_instrument_method" do
    it "must instrument fathercat.anger" do
      expected = ["fathercat.anger-I'mma so sorry"]
      events = []

      callback = lambda { |*_| events << "#{_.first}-#{_.last[:payload]}" }
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.anger') do
        FatherCat.omg
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end

    #class_instrument_method self, :who?, 'fathercat.who', :payload => 'who?'
    it "must pass method args to payload" do
      person = 'chiyo'
      expected = ["fathercat.who-#{person}"]
      events = []

      callback = lambda { |*_| events << "#{_.first}-#{_.last[:_method_args].first}" }
      ActiveSupport::Notifications.subscribed(callback, 'fathercat.who') do
        FatherCat.who?(person)
        ActiveSupport::Notifications.instrument('some.other.event')
      end
      events.must_equal expected
    end
  end
end
