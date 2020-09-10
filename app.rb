require 'sinatra'
require "sinatra/reloader"
require 'sinatra/cookies'

require 'pg'

enable :sessions

client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", "kd"), :password => '',
  :dbname => "myapp")


$users = {
  'kinjo' => 'kinojopass',
  'higa' => 'higapass'
}


get "/form_receiver" do
  @value1 = params[:value1]
  @value2 = params[:value2]
  @value3 = params[:value3]
  return erb :form_receiver
end

get "/form" do
  return erb:form
end


get "/signin" do
  return erb :signin
end

post "/signin" do
  cookies[:user] = params[:name]
  redirect '/mypage'
end

# get "/mypage" do
#   @name = cookies[:user]
#   return erb :mypage
# end


get "/signin" do
  return erb :signin
end

post "/signin" do
  if $users[params[:id]] == paramas[:password]
    session[:users] = params[:id]
    return redirect '/mypage'
  else
    return erb :signin
  end
end

get "/logout" do
  session[:user] = nil
  redirect '/signin'
end

#get "/mypage" do
#  @name = session[:user]
#  return erb :mypage
#end

#ここから課題

get '/posts/new' do
  return erb :new_posts
end



post '/posts' do
  @title = params[:title]
  @content = params[:content]

  if !params[:img].nil? # データがあれば処理を続行する
    tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
    save_to = "./public/images/#{params[:img][:filename]}" # ファイルを保存したい場所
    FileUtils.mv(tempfile, save_to)
    @img_name = params[:img][:filename]
  end 
  binding.irb
  return erb :post
end

#問2

get '/blogs/new' do
  return erb :new_blog
end

post '/blogs' do
  @title = params[:title]
  @content = params[:content]
  return erb :blog
end

get '/signup' do
  return erb :signup
end

post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]

  client.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", [name, email, password])
  
  user = client.exec_params("SELECT * from users WHERE email = $1 AND password = $2", [email, password]).to_a.first
  session[:user] = user
  return redirect '/mypage'
end

get "/mypage" do
  @name = session[:user]['name'] # 書き換える
  return erb :mypage
end


get '/signin' do
  return erb :signin
end

post '/signin' do
  email = params[:email]
  password = params[:password]
  user = client.exec_params("SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}'").to_a.first
  if user.nil?
    return erb :signin
  else
    session[:user] = user
    return redirect '/mypage'
  end
end


delete '/signout' do
  session[:user] = nil
  redirect '/signin'
end