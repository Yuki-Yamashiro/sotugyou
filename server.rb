require 'sinatra'
require 'sinatra/reloader' 

get "/hello" do
  return "<h1>こんにちは！</h1>"
end