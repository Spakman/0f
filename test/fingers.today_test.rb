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

  describe "GET a private page" do
    it "returns a 200 if authenticated" do
      get "/private"
      assert_equal 200, last_response.status
      get "/private/page"
      assert_equal 200, last_response.status
    end

    it "returns a 401 if not authenticated" do
      not_authenticated do
        get "/private"
        assert_equal 401, last_response.status
        get "/private/page"
        assert_equal 401, last_response.status
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

      RenderableFile.stub(:build, ->(path, named) { page }) do
        get "/#{path}"
        assert_includes last_response.body, content
        page.verify
      end
    end

    it "returns a 200 when the path doesn't exist and authenticated" do
      build_result = Minitest::Mock.new
        .expect(:file?, false)
      new_page_template = Minitest::Mock.new
        .expect(:directory?, false)
        .expect(:private?, false)
        .expect(:deletable?, false)
        .expect(:movable?, false)
        .expect(:content, "content")
        .expect(:uri_path, "/#{path}")
        .expect(:parent, nil)
        .expect(:basename, path)

      RenderableFile.stub(:build, ->(path, named={ with_index_page: false }) do
        named[:with_index_page] ? build_result : new_page_template
      end) do
        get "/#{path}"
        assert_equal 200, last_response.status
        build_result.verify
        new_page_template.verify
      end
    end

    it "return a 404 when path doesn't exist and is not authenticated" do
      no_file = Minitest::Mock.new
        .expect(:file?, false)

      not_authenticated do
        RenderableFile.stub(:build,  ->(path, named) { no_file }) do
          get "/#{path}"
          assert_equal 404, last_response.status
          no_file.verify
        end
      end
    end

    it "returns a 400 when the path is invalid" do
      RenderableFile.stub(:build, ->(path, named) { raise IllegalPagePath.new }) do
        get "/#{path}"
        assert_equal 400, last_response.status
      end
    end
  end

  describe "PUT a page that isn't /" do
    let(:path) { "hello" }

    let(:body_with_whitespace) { " hello " }

    it "saves the page" do
      page = Minitest::Mock.new.expect(:save, true, [ body_with_whitespace.strip ])

      RenderableFile.stub(:build, page) do
        put "/#{path}", body_with_whitespace
        page.verify
        assert_equal 200, last_response.status
      end
    end

    it "returns a 401 if not authenticated" do
      not_authenticated do
        put "/#{path}", body_with_whitespace
        assert_equal 401, last_response.status
      end
    end
  end

  describe "DELETE deletable page" do
    it "returns a 401 if not authenticated" do
      not_authenticated do
        delete "/test/hello"
        assert_equal 401, last_response.status
      end
    end

    it "removes the page when authenticated" do
      build_result = Minitest::Mock.new
        .expect(:delete!, true)
        .expect(:parent, OpenStruct.new(uri_path: "/hello/"))

      RenderableFile.stub(:build, ->(path) { build_result }) do
        delete "/test/hello"
        build_result.verify
      end
    end

    it "returns a redirect to the parent page when authenticated" do
      build_result = Minitest::Mock.new
        .expect(:deletable?, true)
        .expect(:delete!, true)
        .expect(:parent, OpenStruct.new(uri_path: "/hello/"))

      RenderableFile.stub(:build, ->(path) { build_result }) do
        delete "/test/hello"
        assert_equal 302, last_response.status
      end
    end

    it "returns a 400 when trying to delete a directory" do
      RenderableFile.stub(:build, ->(path) { directory }) do
        delete "/test/hello"
        assert 400, last_response.status
      end
    end
  end

  describe "POST a page" do
    let(:new_path) { "new_path" }
    let(:old_path) { "old_path" }

    it "returns a 200 when moving a page" do
      old_page = Minitest::Mock.new
        .expect(:move_to, true, [ new_path ])

      RenderableFile.stub(:build, old_page) do
        post "/#{new_path}", old_path
        old_page.verify
        assert_equal 200, last_response.status
      end
    end

    it "returns a 401 if not authenticated" do
      not_authenticated do
        post new_path, old_path
        assert_equal 401, last_response.status
      end
    end

    it "returns a 400 if trying to move /private" do
      post new_path, "/private"
      assert_equal 400, last_response.status
    end

    it "returns a 400 if trying to move /" do
      post new_path, "/"
      assert_equal 400, last_response.status
    end

    it "returns a 400 if trying to move a page that doesn't exist" do
      post new_path, "/nothing_here"
      assert_equal 400, last_response.status
    end
  end
end
