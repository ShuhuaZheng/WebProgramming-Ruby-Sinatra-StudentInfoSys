require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require './record.rb'

#----------------------------------Configuration Setting------------------------------------
configure do 
	enable :sessions
	set :server, %w[webrick mongrel thin]
end 

configure :development do 
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/record.db")
	DataMapper.auto_upgrade!
end 

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
	DataMapper.auto_upgrade! 
end  


#-------------------------------------Scss Style------------------------------------------
get '/styles.css' do 
	scss :styles
end 

#-------------------------------------Major Routes------------------------------------------
#root route same as home route 
get '/' do 
	redirect('/home')
end 

#home route 
get '/home' do 
	@title = "Home"
	erb :home
end 

#about route 
get '/about' do 
	@title = "About"
	erb :about
end 

#contact route 
get '/contact' do 
	@title = "Contact"
	erb :contact
end 

#video route 
get '/video' do 
	@title = "Video"
	erb :video
end 

#-------------------------------------Students related------------------------------------------
#student route 
get '/students' do 
	if session[:admin] 		#if the user has login, show the student page 
		@title = "Students"
		@students = Students.all
		erb :students
	else					#if the user hasn't login, show the login page
		@title = "Login"
		@not_admin = true
		erb :login 
	end 
end 

get '/addStudent' do 
	@title = "Add Student"
	erb :addStudent
end 

post '/addStudent' do 
	if params[:firstname].length == 0 || params[:lastname].length == 0 || params[:id].length == 0 || params[:birthday].length == 0 || params[:address].length == 0
		@lack_info = true
		erb :addStudent
	else 
		s = Students.new	# create a new student record 
		s.firstname = params[:firstname]
		s.lastname = params[:lastname]
		s.id = params[:id]
		s.birthday = params[:birthday]
		s.address = params[:address]
		
		s.save			
		redirect('/students')
	end 
end 

get '/studentDetail/:id' do 
	@title = "Student Detail"
	@student = Students.get(params[:id])
	erb :studentDetail
end 

get '/editStudent/:id' do 
	@title = "Edit Student"
	@id = params[:id]
	@student = Students.get(params[:id])
	erb :editStudent
end 

post '/editStudent' do 
	s = Students.get(params[:id])
	s.update(:firstname => params[:firstname], :lastname => params[:lastname], :birthday => params[:birthday], :address => params[:address])
	redirect('/students')
end 

get '/deleteStudent/:id' do 
	student_to_delete = Students.get(params[:id])
	student_to_delete.destroy
	redirect('/students')
end 

#-------------------------------------Comment related------------------------------------------
#comment route 
get '/comment' do 
	@title = "Comment"
	@comments = Comments.all
	erb :comment
end 

get '/commentDetail/:id' do 
	@title = "Comment Detail"
	@comment = Comments.get(params[:id])
	erb :commentDetail
end 

get '/createComment' do 
	@title = "Create Comment"
	erb :createComment
end 

post '/createComment' do 
	c = Comments.new #create a new Comments object 

	# check whether user has entered content
	if params[:content].length == 0 
		c.content = "No Comments"
	else 
		c.content = params[:content]
	end 

	# check whether user has entered name
	if params[:name].length == 0
		c.name = "Anonymous"
	else 
		c.name = params[:name]
	end 

	c.save
	redirect('/comment')
end 

=begin
get '/deleteComment/:id' do 
	student_to_delete = Comments.get(params[:id])
	student_to_delete.destroy
	redirect('/comment')
end 
=end 
#-------------------------------------Login/Logout related------------------------------------------ 
get '/login' do 
	@title = "Login"
	erb :login
end 

post '/login' do #get username and password from user input 
	@user = Users.first(:username => params[:username]) 

	if @user and (@user.password == params[:password])
		session[:admin] = true 		#mark as logged in 
		redirect to('/students')
	else 
		@title = "Login"
		@incorrect_info = true #user name doesn't exist or password is incorrect 	
		erb :login         #let user re-enter username and password 
	end
end 

get '/logout' do 
	session.clear #clear the current session
	redirect to ('/login') #redirect to login page 
end 

#-------------------------------------Registration related------------------------------------------
get '/register' do 
	@title = "Register"
	erb :register
end 

post '/register' do 
	if params[:lastname].length == 0 || params[:firstname].length == 0 || params[:username].length == 0 || params[:password].length == 0
		@lack_info = true
		erb :register
	elsif Users.first(:username => params[:username])	# if the username has been created already, ask the user to input another name
		@exist = true
		erb :register 
	else 
		user = Users.new
		user.lastname = params[:lastname]
		user.firstname = params[:firstname]
		user.username = params[:username]
		user.password = params[:password]
		user.save
		redirect('/login')
	end 
end 

#-------------------------------------When Route Does Not Exist------------------------------------
not_found do 
	@title = "Not Found Page"
	erb :notfound, :layout => false
end 