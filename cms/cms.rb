# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'
require 'redcarpet'
require 'yaml'
require 'bcrypt'
require 'fileutils'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, escape_html: true
end

# set up @files object
before do
  @files = find_files(data_path, 'text')
  @images = find_files(image_path, 'image')
  @all_files = @files + @images
end

FILE_TYPES = ['.txt', '.md', '.jpeg', '.jpg', '.png'].freeze

# PATH HELPERS ----------------------------
def data_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('test/data', __dir__)
  else
    File.expand_path('data', __dir__)
  end
end

def image_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('test/images', __dir__)
  else
    File.expand_path('public/images', __dir__)
  end
end

def load_user_credentials
  credentials_path = if ENV['RACK_ENV'] == 'test'
                       File.expand_path('test/users.yml', __dir__)
                     else
                       File.expand_path('public/users.yml', __dir__)
                     end
  YAML.load_file(credentials_path)
end

# update the text in the file
def users_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path('test/users.yml', __dir__)
  else
    File.expand_path('public/users.yml', __dir__)
  end
end

# USER ROUTES AND METHODS ---------------------------------

get '/users/signup' do
  erb :signup, layout: :layout
end

# new user sign up page
post '/users/new' do
  username = params[:username]
  password = params[:password]
  if valid_username?(username) && valid_password?(password)
    create_user(username, password)
    session[:message] = "Welcome #{username}!"
    session[:username] = params[:username]
    redirect '/'
  else
    status 422
    session[:message] = new_user_error_message(username)
    erb :signup, layout: :layout
  end
end

# display signin page
get '/users/signin' do
  erb :sign_in, layout: :layout
end

# sign in user if credentials are correct
post '/users/signin' do
  user = params[:username]
  if valid_user_and_password?(user)
    session[:username] = user
    session[:message] = "Welcome #{user}!"
    redirect '/'
  else
    status 422
    session[:message] = 'Invalid Credentials'
    erb :sign_in, layout: :layout
  end
end

# sign out currently logged in users
post '/users/signout' do
  session[:username] = nil
  session[:message] = 'You have been signed out'
  redirect '/'
end

def create_user(username, password)
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(password, password_salt)

  users = load_user_credentials
  users[username] = {
    salt: password_salt,
    passwordhash: password_hash
  }

  File.write(users_path, users.to_yaml)
end

# Routes for documents and images  -----------------------------------

# display the index
get '/' do
  erb :index, layout: :layout
end

# create a new document
get '/new' do
  redirect_unless_signed_in
  erb :new, layout: :layout
end

# add a new file to the index
post '/create' do
  redirect_unless_signed_in

  file_name = params[:file_name]

  if valid_file_name?(file_name)
    file_path = File.join(data_path, file_name)
    File.new(file_path, 'w')
    session[:message] = "#{file_name} has successfully been added"
    redirect '/'
  else
    session[:message] = filename_error_message(file_name)
    status 422
    erb :new, layout: :layout
  end
end

# upload an image to the index
post '/upload_image' do
  redirect_unless_signed_in
  if params.empty?
    session[:message] = 'You must upload a file'
    status 422
    erb :new, layout: :layout
  else
    filename = params[:file][:filename]
    file = params[:file][:tempfile]
    file_path = File.join(image_path, filename)
    File.open(file_path, 'w+') { |f| f.write(file.read) }
    session[:message] = "#{filename} successfully uploaded"
    redirect '/'
  end
end

# rename a duplicate file
get '/:filename/rename_duplicate' do
  redirect_unless_signed_in
  @file_name = params[:filename]
  erb :duplicate, layout: :layout
end

def a_method
  david = 'chicken'
end

# duplicate a file and rename
post '/duplicate' do
  redirect_unless_signed_in
  original_file = params[:original_file]
  new_file_name = params[:file_name]
  if valid_file_name?(new_file_name)
    duplicate(new_file_name, original_file)
    session[:message] = "#{original_file} copied to file: #{new_file_name}"
    redirect '/'
  else
    session[:message] = filename_error_message(new_file_name)
    @file_name = original_file
    status 422
    erb :duplicate, layout: :layout
  end
end

# view for user to rename file
get '/:filename/rename' do
  @file_name = params[:filename]
  redirect_unless_signed_in
  erb :rename, layout: :layout
end

# rename a file
post '/rename' do
  original_file = params[:original_file]
  new_file_name = params[:new_file_name]

  if valid_file_name?(new_file_name)
    rename_file(new_file_name, original_file)
    session[:message] = "#{original_file} has been renamed to: #{new_file_name}"
    redirect '/'
  else
    @file_name = original_file
    status 422
    session[:message] = filename_error_message(new_file_name)
    erb :rename, layout: :layout
  end
end

# Methods for documents and images ------------------------

# rename a file
def rename_file(new_file_name, original_file)
  og_file_path = File.join(data_path, original_file)
  new_file_path = File.join(data_path, new_file_name)
  File.rename(og_file_path, new_file_path)
end

# display the text in the file in the right format
get '/:filename' do
  file_name = params[:filename]
  if file_exist?(file_name)
    load_file_content(file_path(file_name))
  else
    session[:message] = "#{file_name} does not exist"
    redirect '/'
  end
end

# delete a file
post '/:filename/delete' do
  redirect_unless_signed_in
  file_name = params[:filename]

  File.delete(file_path(file_name))

  session[:message] = "#{file_name} has been deleted"
  redirect '/'
end

# edit the text in the file
get '/:filename/edit' do
  redirect_unless_signed_in
  @file_name = params[:filename]
  file_path = File.join(data_path, @file_name)
  if file_exist?(@file_name)

    @content = File.read(file_path)
    erb :edit, layout: :layout
  else
    session[:message] = "#{file_name} does not exist"
    redirect '/'
  end
end

# upload a new document file
post '/:filename' do
  redirect_unless_signed_in
  new_text = params[:content]
  file_name = params[:filename]
  file_path = File.join(data_path, file_name)

  File.write(file_path, new_text)
  session[:message] = "#{file_name} has been updated"
  redirect '/'
end

# methods for document and images behaviour

def filename_error_message(file_name)
  if file_name.empty?
    'You must enter a file name'
  elsif file_exist?(file_name)
    'You must enter a unique file name'
  else
    'You must enter a valid file type'
  end
end

def supported_type?(file_name)
  extension = file_name[/[.]\w+$/].downcase
  FILE_TYPES.include?(extension)
end

def valid_file_name?(file_name)
  !file_name.empty? && supported_type?(file_name) && !file_exist?(file_name)
end

def file_exist?(file_name)
  @all_files.find { |file| file[:name] == file_name }
end

def file_path(file_name)
  case file_or_image?(file_name)
  when 'doc'
    File.join(data_path, file_name)
  when 'image'
    File.join(image_path, file_name)
  end
end

def duplicate(new_file_name, file_to_copy)
  original_file_path = File.join(data_path, file_to_copy)
  new_file_path = File.join(data_path, new_file_name)
  FileUtils.cp_r original_file_path, new_file_path
end

def render_markdown(content)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(content)
end

def load_markdown(content)
  headers['Content-Type'] = 'text/html;charset=utf-8'
  erb render_markdown(content)
end

def load_text(content)
  headers['Content-Type'] = 'text/plain'
  content
end

def load_file_content(path)
  @filename = File.basename(path)
  content = File.read(path)
  case File.extname(path)
  when '.txt' then load_text(content)
  when '.md' then load_markdown(content)
  else
    erb :image
  end
end

def file_types_to_sentence
  connector = ', '
  two_words = ' and '
  last_connector = ', and '

  case FILE_TYPES.size
  when 2
    "#{FILE_TYPES[0]}#{two_words}#{FILE_TYPES[1]}"
  else
    "#{FILE_TYPES[0...-1].join(connector)}#{last_connector}#{FILE_TYPES[-1]}"
  end
end

def find_files(path, type)
  pattern = File.join(path, '*')
  results = []
  Dir.glob(pattern).map { |file| File.basename(file) }.each do |file|
    results << { name: file, type: type }
  end
  results
end

def file_or_image?(file_name)
  return 'doc' if @files.any? { |image| image[:name] == file_name }
  return 'image' if @images.any? { |image| image[:name] == file_name }
end

# Methods for users behaviour --------------------
def user_signed_in?
  session.key?(:username)
end

# rubocop:disable Metrics/LineLength
def valid_user_and_password?(user)
  credentials = load_user_credentials
  if credentials.key?(user)
    user = credentials[user]
    user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
  else
    false
  end
end
# rubocop:enable Metrics/LineLength

def redirect_unless_signed_in
  return if user_signed_in?

  session[:message] = 'You must be signed in to do that'
  redirect '/'
end

def valid_username?(username)
  !username.empty? && !taken_username?(username)
end

def taken_username?(username)
  credentials = load_user_credentials
  credentials.key?(username)
end

def valid_password?(password)
  !password.empty?
end

def new_user_error_message(username)
  if username.empty?
    'You must enter a valid username'
  elsif taken_username?(username)
    'You must enter a unique username'
  else
    'You must enter a valid password'
  end
end
