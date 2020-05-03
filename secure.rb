def user_exist?(user_name)
	User.first(:username => user_name)
end

def add_user(user_name, password)

  u = User.new
  u.username = user_name
  u.userpass = password
	if u.save
		 true
	else
		false
	end
end

def check_password?(user_name, pass_word)
	user = User.first(:username => user_name)
	if user
		return user.userpass == pass_word
	end
	return false	
end

