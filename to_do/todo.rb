require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require 'pry'

configure do 
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

before do 
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

get "/lists" do 
  @lists = session[:lists]

  erb :lists, layout: :layout
end

#create a new list

get "/lists/new" do 

  erb :new_list, layout: :layout
end 

# edit an individual todo list 

get "/lists/:id/edit" do 
  list_id = params['id'].to_i 
  @list = load_list(list_id)  
  erb :edit_list, layout: :layout
end


# add new todo list
post "/lists" do 
  @lists = session[:lists]
  list_name = params[:list_name].strip 
  
  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    list_id = next_list_id(@lists)
    @lists << {name: list_name, todos:[], list_id: list_id}
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

#display individual list

get "/lists/:id" do 
  list_id = params['id'].to_i
  @list = load_list(list_id)  
  @list_name = @list[:name]
  @list_id = @list[:list_id]

  erb :list,  layout: :layout
end

# update an existing to do list

post "/lists/:id" do 
  list_name = params[:list_name].strip 
  list_id = params['id'].to_i 
  # binding.pry
  @list = load_list(list_id)   
  
  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    @list[:name] = list_name 
    session[:success] = "The list has been updated."
    redirect "/lists/#{list_id}"
  end
end 

# delete a todo list

post "/lists/:id/delete" do 
  list_id = params['id'].to_i 
  @lists = session[:lists]
  @lists.reject! {|list| list[:id] == list_id}
  binding.pry
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/lists"
  else 
    session[:success] = "The list has been deleted."
    redirect "/lists"
  end
end

# add todo's to a Todo list
post "/lists/:list_id/todos" do 
  list_id = params['list_id'].to_i 
  @list = load_list(list_id)  
  todo_name = params[:todo].strip
   
  error = error_for_todo(todo_name)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    id = next_todo_id(@list) 
    todo = {name: todo_name, complete: false, id: id}
    @list[:todos] << todo
    session[:success] = "The todo was added."
    redirect "/lists/#{list_id}"
  end
end 

#delete individual todo
post "/lists/:list_id/todos/:todo_id/delete" do 
  list_id = params['list_id'].to_i 
  @list = load_list(list_id) 
  todo_id =  params[:todo_id].to_i
  @list[:todos].reject! {|todo| todo[:id] == todo_id}
  binding.pry
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    status 204
  else 
    session[:success] = "The todo has been deleted."
    redirect "/lists/#{list_id}"
  end
end

#update the status of the todo. 

post "/lists/:list_id/todos/:todo_id/toggle" do 
  list_id = params['list_id'].to_i 
  @list = load_list(list_id)  

  is_completed = params[:completed] == "true"
  todo_id = params[:id].to_i
  todo = @list[:todos].find {|todo| todo[:id] == todo_id}
  todo[:complete] = is_completed
  session[:success] = "The todo has been update."
  redirect "/lists/#{list_id}"
end 

# mark all todos in a list complete 

post "/lists/:list_id/complete_all" do 
  list_id = params['list_id'].to_i 
  @list = session[:lists].find{|lists| list[:list_id] == [list_id]}
  @list[:todos].each{|todo| todo[:complete] = true}
  session[:success] = "All todos have been update."
  redirect "/lists/#{list_id}"
end 


# validation methods 
#going to return an error message if the list name is invalid. Return nil if name is valid
def error_for_list_name(name)
  if  !(name.size >= 1 && name.size <= 100)
    "List name must be between 1 and 100 characters"
  elsif session[:lists].any? {|list| list[:name] == name}
    "List name must be unique"
  end
end

#checking todo name
def error_for_todo(name)
  if  !(name.size >= 1 && name.size <= 100)
    "Todo name must be between 1 and 100 characters"
  end
end

# method to help with checking list validity 
def load_list(list_id)
  list = session[:lists].find {|list| list[:list_id] == list_id}
  return list if list

  session[:error] = "The specified list was not found."
  redirect "/lists"
end

# view helpers

helpers do 
  def next_todo_id(list) 
    return 0 if list[:todos].empty?
    list[:todos].map {|todo| todo[:id]}.max + 1 
  end

  def next_list_id(lists)
    return 0 if lists.empty? 
    # binding.pry
    lists.map {|list| list[:list_id]}.max + 1 
  end

  def remaining_todos(list)
     complete = list[:todos].count {|todo| todo[:complete]}
     "#{complete}/#{list[:todos].size}"
  end

  def all_complete?(list)
    return false if list[:todos].empty?
    list[:todos].all? {|todo| todo[:complete] == true} 
  end

  def todo_complete?(todo)
    todo[:complete] == true
  end

  def list_class(list)
    all_complete?(list) ? "complete" : ""
  end

  def sort_lists(lists, &block)
    complete, incomplete = lists.partition {|list| all_complete?(list) }
    
    incomplete.each{|list| yield list}
    complete.each{|list| yield list}
  end

  def sort_todos(todos, &block)
    complete, incomplete = todos.partition {|todo| todo_complete?(todo) }
    
    incomplete.each{|todo| yield todo}
    complete.each{|todo| yield todo}
  end
end 