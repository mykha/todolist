require 'rubygems'
require 'sinatra'
require 'data_mapper'
require './secure.rb'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/todolist.db")

class User
	include DataMapper::Resource
	property :id, Serial
	property :username, String, :required => true, key: true, unique_index: true
	property :userpass, String, :required => true
#	property :password, String, length: 10..255
	has n, :tasks
end


class Task
	include DataMapper::Resource
	property :id, Serial
	property :name, Text, :required => true
	property :status, Boolean, :required => true, :default => false
	belongs_to :user
	belongs_to :project
end

class Project
	include DataMapper::Resource
	property :id, Serial
	property :name, Text, :required => true
	has n, :tasks
end

DataMapper.finalize.auto_upgrade!

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
	erb ""
end

get '/secure/todolist' do
#  erb :todo_list
	erb 'This is <%=session[:identity]%>\'s ToDo List'
end

get '/sign_on' do
  erb :sign_on
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  if user_exist?(params['username'])
	if check_password?(params['username'], params['userpass'])
	    session[:identity] = params['username']
	else
		@error = "Wrong password" #<< "*" << params['userpass'] << "*"
		halt erb :login_form	
	end
  else
	@error = "Unknown user"
	halt erb :login_form	
  end
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

post '/sign_on' do
  if user_exist?(params['username'])
    session[:previous_url] = request.path
    @error = "Sorry,  username #{params['username']} already exist" 
    halt erb :sign_on
  elsif params['userpass']!=params['confirmpass']
    session[:previous_url] = request.path
    @error = "Sorry, password and confirmation is not match" 
    halt erb :sign_on
  else
    add_user(params['username'], params['userpass'].chomp)
    erb :login_form
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
