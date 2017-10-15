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
  describe "GET /" do
    let(:content) { "page_content" }

    it "renders the page template" do
      page = Minitest::Mock.new.expect(:content, content)

      RenderableFile.stub(:build, ->(path) { page }) do
        get "/"
        assert_includes last_response.body, content
        page.verify
      end
    end
  end

  describe "POST /" do
    let(:body_with_whitespace) { " hello " }

    it "saves the page" do
      page = Minitest::Mock.new.expect(:save, true, [ body_with_whitespace.strip ])

      RenderableFile.stub(:build, page) do
        post "/", body_with_whitespace
        page.verify
      end
    end

    it "returns a 401 if not authenticated"
  end

  describe "GET a page that isn't /" do
    let(:path) { "hello" }
    let(:content) { "page_content" }

    it "renders the page template when the path is a file" do
      page = Minitest::Mock.new
        .expect(:file?, true)
        .expect(:content, content)

      RenderableFile.stub(:build, ->(path) { page }) do
        get "/#{path}"
        assert_includes last_response.body, content
        page.verify
      end
    end

    it "renders the directory_index template when the path is a directory" do
      directory = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, true)
        .expect(:directories, %w( dir1 dir2 ))
        .expect(:files, %w( file1 file2 ))

      RenderableFile.stub(:build, ->(path) { directory }) do
        get "/#{path}"
        assert_includes last_response.body, "dir1"
        directory.verify
      end
    end

    it "returns a 501 when the path doesn't exist and authenticated" do
      no_file = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, false)

      RenderableFile.stub(:build, ->(path) { no_file}) do
        get "/#{path}"
        assert_equal 501, last_response.status
        no_file.verify
      end
    end

    it "return a 404 when path doesn't exist and is not authenticated" do
      no_file = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, false)

      RenderableFile.stub(:build, ->(path) { no_file}) do
        get "/#{path}"
        assert_equal 501, last_response.status
        no_file.verify
      end
    end

    it "returns a 400 when the path is invalid" do
      RenderableFile.stub(:build, ->(path) { raise IllegalPagePath.new }) do
        get "/#{path}"
        assert_equal 400, last_response.status
      end
    end
  end
end
