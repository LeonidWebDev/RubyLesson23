require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' #gem install sinatra-reloader

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
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
  erb :about
end

get '/visit_form' do
  erb :visit_form
end

get '/login/form' do
  erb :login_form
end

get '/contacts' do
  erb :contacts
end

post '/visit_form' do
  @master = params[:master]
  @clientname = params[:clientname]
  @userphone = params[:userphone]
  @userdate = params[:userdate]
  @color = params[:colorpicker]

  hh = {:clientname => "Введите имя",
        :userphone => "Введите номер телефона",
        :userdate => "Введите время посещения"}
  
  hh.each do |key, value|
    if params[key] == ""
      @error = hh[key]
      return erb :visit_form
    end
  end

  f = File.open "./public/users.txt", "a"
  f.write "Master: #{@master}, User: #{@clientname}, Phone: #{@userphone}, Time: #{@userdate}, Color: #{@color}\n" 
  f.close

  erb :visit_form
end  

post '/contacts' do
  @usermail = params[:userMail]
  @usertext = params[:userText]
  f = File.open "./public/contacts.txt", "a"
  f.write "Mail: #{@usermail}, Message: #{@usertext}\n" 
  f.close

  erb :contacts
end

post '/login/attempt' do
  session[:identity] = params['username']
  @username = params[:username]
  @userpassword = params[:userpassword]
  if @username == "admin" && @userpassword == "secret"
    erb :admin_room
  else 
      where_user_came_from = session[:previous_url] || '/'
      redirect to where_user_came_from
  end  
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
