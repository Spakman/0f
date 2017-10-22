require "minitest/autorun"
require "rack/test"

require_relative "../fingers.today"

ENV["RACK_ENV"] = "test"
include Rack::Test::Methods

def app
  FingersToday
end

def ensure_authenticated
  FingersToday.prepend(Module.new do
    def authenticated?; true; end
  end)
end

def ensure_not_authenticated
  FingersToday.prepend(Module.new do
    def authenticated?; false; end
  end)
end

def not_authenticated(&block)
  ensure_not_authenticated
  yield
  ensure_authenticated
end


describe FingersToday do
  before do
    ensure_authenticated
  end

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
        .expect(:uri_path, "uri_path")
        .expect(:basename, "basename")
      page = Minitest::Mock.new
        .expect(:uri_path, "uri_path")
        .expect(:basename, "basename")
      index = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, true)
        .expect(:directories, [ directory ])
        .expect(:pages, [ page ])

      RenderableFile.stub(:build, ->(path) { index }) do
        get "/#{path}"
        index.verify
        page.verify
        directory.verify
      end
    end

    it "returns a 200 when the path doesn't exist and authenticated" do
      build_result = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, false)
        .expect(:content, "content")
        .expect(:uri_path, "/#{path}")
        .expect(:parent, nil)
        .expect(:basename, path)

      RenderableFile.stub(:build, ->(path) { build_result }) do
        get "/#{path}"
        assert_equal 200, last_response.status
        build_result.verify
      end
    end

    it "return a 404 when path doesn't exist and is not authenticated" do
      no_file = Minitest::Mock.new
        .expect(:file?, false)
        .expect(:directory?, false)

      not_authenticated do
        RenderableFile.stub(:build, ->(path) { no_file }) do
          get "/#{path}"
          assert_equal 404, last_response.status
          no_file.verify
        end
      end
    end

    it "returns a 400 when the path is invalid" do
      RenderableFile.stub(:build, ->(path) { raise IllegalPagePath.new }) do
        get "/#{path}"
        assert_equal 400, last_response.status
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
        assert_equal 200, last_response.status
      end
    end

    it "returns a 401 if not authenticated" do
      not_authenticated do
        post "/", body_with_whitespace
        assert_equal 401, last_response.status
      end
    end
  end

  describe "POST a page that isn't /" do
    let(:path) { "hello" }

    let(:body_with_whitespace) { " hello " }

    it "saves the page" do
      page = Minitest::Mock.new.expect(:save, true, [ body_with_whitespace.strip ])

      RenderableFile.stub(:build, page) do
        post "/#{path}", body_with_whitespace
        page.verify
        assert_equal 200, last_response.status
      end
    end

    it "returns a 401 if not authenticated" do
      not_authenticated do
        post "/#{path}", body_with_whitespace
        assert_equal 401, last_response.status
      end
    end
  end
end
