require 'rubygems'
require 'sinatra'
require './secure.rb'

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

=begin
  readfile = File.open "./users.txt", "r"

  while (line=readfile.gets)
	cred = line.split("=>")
#	cred[0]==user_name && cred[1]==pass_word
	if cred[0] == params['username']
		@error = "/" << cred[0] << "/=/" << params['username'] << "/  /" << cred[1].chomp << "/=" << "/" << params['userpass'] << "/"
		halt erb :login_form	
	end
  end

=begin
  while (line=readfile.gets)
	cred = line.split("=>")
	if cred[0]==user_name && cred[1]==pass_word
		readfile.close
		return true
	else 
		
	end
  end
	readfile.close
  return false
=end	


	if check_password?(params['username'], params['userpass'].strip)
	    session[:identity] = params['username']
	else
		@error = "Wrong password" << "*" << params['userpass'] << "*"
		halt erb :login_form	
	end
  else
#    erb 'Unknown username'
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
#+ request.path
    halt erb :sign_on
#	erb :sign_on	
  elsif params['userpass']!=params['confirmpass']
    session[:previous_url] = request.path
    @error = "Sorry, password and confirmation is not match" 
#+ request.path
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
