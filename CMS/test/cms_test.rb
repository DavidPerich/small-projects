require 'simplecov'
SimpleCov.start

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "rack/test"
require 'fileutils'
require 'bcrypt'

require_relative '../cms.rb'

class CMSTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
    users = {"admin" => {
      :salt => "$2a$10$5phwSNPkyI3cVciVK7s84u",
      :passwordhash => "$2a$10$5phwSNPkyI3cVciVK7s84uUsgVG5ku9VC32sxhjAiBNp1BVNQ3hha"}}

      File.write(users_path, users.to_yaml)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    {"rack.session" =>{ username: "admin"}}
  end

  def test_home
    create_document "about.txt"
    create_document "changes.txt"
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "changes.txt"
  end

  def test_viewing_text_doc
    create_document("about.txt", "2015 - Ruby 2.3 released.")
    get "/about.txt"
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "2015 - Ruby 2.3 released."
  end

  def test_document_not_found
    get "/fakefile.txt"
    assert_equal 302, last_response.status

    assert_equal "fakefile.txt does not exist", session[:message]
  end

  def test_markdown_display_as_html
    create_document "history.md", "# Introducing Javascript"
    get "/history.md"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Introducing Javascript</h1>"
  end


  def test_display_edit_document_page
    create_document "about.txt"
    get "about.txt/edit", {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %Q(<button type="submit")
  end
  def test_display_edit_document_page_without_signing
    create_document "about.txt"
    get "about.txt/edit"
    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_edit_document
    post "/changes.txt", {content: "new content"}, admin_session

    assert_equal 302, last_response.status
    assert_equal  "changes.txt has been updated", session[:message]

    get last_response["Location"]

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_edit_doc_without_signin
    create_document "changes.txt"

    post "/changes.txt", {content: "new content"}
    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_view_new_doc_form
    get "/new", {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %Q(<button type="submit")
  end

  def test_view_new_doc_form_without_signin
    get "/new"
    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_creating_new_document
    post "/create", {file_name: "david.txt"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "david.txt has successfully been added", session[:message]

    get "/"
    assert_includes last_response.body, "david.txt"
  end

  def test_create_new_doc_with_empty_name
    post "/create", {file_name: ""}, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "You must enter a file name"
  end

  def test_create_doc_with_bad_file_type
    post "/create", {file_name: "david.bum"}, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "You must enter a valid file type"
  end

  def test_create_doc_without_signin
    post "/create", {file_name: "test.txt"}, {}
    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_delete_doc
    create_document("test.txt")

    post "/test.txt/delete", {}, admin_session

    assert_equal 302, last_response.status

    assert_equal "test.txt has been deleted", session[:message]

    get "/"
    refute_includes last_response.body, %q(href="/test.txt")
  end

  def test_delete_doc_without_signin
    create_document("test.txt")

    post "/test.txt/delete"
    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_logged_out_user_accessing_index
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, %Q(<button type="submit")
    assert_includes last_response.body, "Sign In"
  end

  def test_sign_in_page
    get "/users/signin"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %Q(<button type="submit")
    assert_includes last_response.body, "Sign in"
  end

  def test_sign_in_with_wrong_credentials
    post "/users/signin",  username: "david", password: "password"
    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials"
    assert_nil session[:username]
  end

  def test_sign_in_with_right_credentials
    post "/users/signin",  username: "admin", password: "password"

    assert_equal 302, last_response.status

    assert_equal "Welcome admin!", session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]

    assert_includes last_response.body, "Signed in as admin"
    assert_includes last_response.body, "Sign Out"

  end

  def test_signout
    get "/",  {}, admin_session
    assert_includes last_response.body, "Signed in as admin"

    post "/users/signout"
    assert_equal "You have been signed out", session[:message]
    get last_response["Location"]

    assert_nil session[:username]
    assert_includes last_response.body, "Sign In"
  end

  def test_duplicate
    create_document("test.txt")
    post "/duplicate", {original_file: "test.txt", file_name: "test2.txt"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "test.txt copied to file: test2.txt", session[:message]
    get last_response["Location"]

    assert_includes last_response.body, "test2.txt"
  end

  def test_duplicate_without_signin
    create_document("test.txt")

    post "/duplicate", original_file: "test.txt", file_name: "test2.txt"

    assert_equal 302, last_response.status
    assert_equal "You must be signed in to do that", session[:message]
  end

  def test_rename_file
    create_document("test.txt")
    post "/rename", {original_file: "test.txt", new_file_name: "test2.txt"}, admin_session
    assert_equal 302, last_response.status
    assert_equal "test.txt has been renamed to: test2.txt", session[:message]

    get last_response["Location"]

    assert_includes last_response.body, "test2.txt"
  end

  def test_rename_file_to_existing_file_name
    create_document "david.txt"
    create_document "test2.txt"

    post "/rename", {original_file: "david.txt", new_file_name: "test2.txt"}, admin_session
    assert_equal 422, last_response.status
    # binding.pry
    assert_includes last_response.body, "You must enter a unique file name"
  end

  def test_signup_page
    get "/users/signup"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %Q(<button type="submit")
    assert_includes last_response.body, "Sign up"
  end

  def test_new_user_signup
    post "/users/new", username: "David", password: "testpassword"
    assert_equal 302, last_response.status
    assert_equal "Welcome David!", session[:message]

    get last_response["Location"]

    assert_includes last_response.body, "Welcome David!"
  end

  def test_bad_user_signup
    post "/users/new", username: "", password: "testpassword"
    assert_equal 422, last_response.status
    assert_includes last_response.body, "You must enter a valid username"
  end

  def test_image_uploaded_successfully
    path = File.join(image_path, 'test.jpeg')
    post "/upload_image", {"file" => Rack::Test::UploadedFile.new(path, "image/png")}, admin_session
    assert_includes Dir.children(image_path), "test.jpeg"
  end

  def test_upload_with_no_file_selected
    post "/upload_image", {}, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "You must upload a file"
  end
end