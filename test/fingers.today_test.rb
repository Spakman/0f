require "minitest/autorun"
require "rack/test"

require_relative "../fingers.today"

ENV["RACK_ENV"] = "test"
include Rack::Test::Methods

def app
  FingersToday
end

FingersToday.prepend(Module.new do
  def authenticated?
    true
  end
end)

describe FingersToday do
  describe "writing to /" do
    let(:body_with_whitespace) { " hello " }

    it "saves the page named index" do
      index_called = Minitest::Mock.new
      index_called.expect(:call, Object.new, [ "index" ])

      Page.stub(:new, index_called) do
        post "/", body_with_whitespace
      end
      index_called.verify
    end

    it "strips any leading or trailing whitespace before saving the page" do
      page_mock = Minitest::Mock.new
      page_mock.expect(:save, true, [ "hello" ])

      Page.stub(:new, page_mock) do
        post "/", body_with_whitespace
      end
      page_mock.verify
    end
  end
end
