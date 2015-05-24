require "minitest/autorun"
require "pry"
require "rake"

require_relative "../lib/chromecast"
require_relative "../lib/chromecast/tasks"

MessageReceived = Class.new(StandardError)

class ChromecastTest < Minitest::Unit::TestCase
  def test_ping
    preapre_connection_channel

    wait_for_message do |msg|
      assert_equal "PING", msg["type"]
    end
  end

  private

  def chromecast_ip
    @chromecast_ip ||= ENV.fetch("CHROMECAST_IP")
  end

  def preapre_connection_channel
    @connection_channel = Chromecast::Connection.new(chromecast_ip).open
    @connection_channel.connection.connect
  end

  def wait_for_message
    10.times do
      if msg = @connection_channel.read
        yield msg
        raise MessageReceived
      end
      sleep 1
    end
    rescue MessageReceived
  end
end
