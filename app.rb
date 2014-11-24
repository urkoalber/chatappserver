# app.rb
require "sinatra"
require "json"
require "sinatra/activerecord"
 
configure :development, :test do
  set :database, "sqlite3:app.db"
end

configure :production do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/chatappserver')
end

use Rack::Session::Cookie, :expire_after => 2592000, # In seconds
                           :secret => 'chatappserversuperstrongpassword'

class User < ActiveRecord::Base
  before_save :default_values
  has_and_belongs_to_many :chats
  has_many :messages
  validates :username, :presence => true
  validates :pin, :presence => true
  validates :phone, :presence => true, :uniqueness => true

  def default_values
    self.username ||= ''
    self.username.titleize
    self.state ||= ''
  end
end

class Chat < ActiveRecord::Base
  before_save :default_values
  has_many :messages
  has_and_belongs_to_many :users

  def default_values
    self.name ||= ''
  end
end

class Message < ActiveRecord::Base
  before_save :default_values
  belongs_to :user
  belongs_to :chat
  validates :user, :presence => true
  validates :chat, :presence => true

  def default_values
    self.message_type ||= 'text'
    self.content ||= ''    
  end  
end

helpers do
  def clear_sessions
    session[:user_id] = nil
    session[:user_phone] = nil
  end
end

before do
  content_type :json, :charset => 'utf-8'
  unless request.path_info.split('/').include? 'auth'
    if session[:user_id] && session[:user_phone]
      @current_user = User.find_by_id(session[:user_id])
      unless @current_user && @current_user.phone == session[:user_phone]
        clear_sessions
        halt 401
      end
    else
      halt 401
    end    
  end
end

post '/api/auth/login' do
  req = JSON.parse(request.body.read)
  user = User.find_by_phone(req['phone'])
  if user && user.pin == req['pin'].to_i
    session[:user_id] = user.id
    session[:user_phone] = user.phone
    redirect '/api/users/me'
  else
    halt 401, {:message => 'Unauthorized'}.to_json
  end
end

get '/api/auth/logout' do
  clear_sessions
  {:message => 'Correct logout'}.to_json
end

get '/api/users/me' do
  if user = @current_user
    user.to_json
  else
    halt 500, { message: "Unexpected error" }.to_json
  end  
end

get '/api/users' do
  redirect '/api/users/me'
end

put '/api/users/me' do
  req = JSON.parse(request.body.read)
  if @current_user.update(req["user"])
    session[:user_phone] = @current_user.phone
    redirect "/api/users/me"
  else
    halt 400
  end
end

post '/api/users' do
  req = JSON.parse(request.body.read)
  if user = User.new(req["user"])
    if user.valid? && user.save
      session[:user_id] = user.id
      session[:user_phone] = user.phone
      redirect "/api/users/me"
    else
      halt 409
    end
  else
    halt 400
  end  
end

get '/api/messages' do
  if messages = @current_user.messages
    messages.to_json
  else
    halt 500, { message: "Unexpected error" }.to_json
  end  
end

get '/api/chats' do
  if chats = @current_user.chats
    chats.to_json
  else
    halt 500
  end    
end

get '/api/chats/:id' do
  if chat = @current_user.chats[params[:id].to_i]
    chat.to_json
  else
    halt 500
  end    
end

get '/api/chats/:id/messages' do
  if messages = @current_user.chats[params[:id].to_i].messages
    messages.to_json
  else
    halt 500
  end      
end  

post '/api/chats/:id/messages' do
  req = JSON.parse(request.body.read)
  chat = @current_user.chats[params[:id].to_i]
  if message = Message.new(:user => @current_user, :chat => chat, :message_type => req["message"]["message_type"], :content => req["message"]["content"])
    if message.valid? && message.save
      redirect "/api/chats/#{params[:id]}/messages"
    else
      halt 500
    end    
  else
    halt 400
  end
end

# Any other case
get '/*' do
  halt 404, { message: "Page not found" }.to_json
end
post '/*' do
  halt 404, { message: "Page not found" }.to_json
end
put '/*' do
  halt 404, { message: "Page not found" }.to_json
end
delete '/*' do
  halt 404, { message: "Page not found" }.to_json
end

=begin
def get_all_users
  User.all || []
end

def get_user(id)
  User.find(id)
end

def get_user_chats(id)
  User.find(id).chats || []
end

def get_user_messages(id)
  User.find(id).messages || []
end

def get_all_chats
  Chat.all || []
end

def get_chat(id)
  Chat.find(id)
end

def get_chat_users(id)
  Chat.find(id).users || []
end

def get_chat_messages(id)
  Chat.find(id).messages || []
end

def get_user_by_phone(phone)
  User.find_by_phone(phone)
end

#-------

get '/api/users' do
  if users = get_all_users
    users.to_json
  else
    halt 500
  end 
end

post '/api/users' do
  request_body = JSON.parse(request.body.read)
  if user = User.new(request_body["user"])
    if user.save
      redirect "/api/users/#{user.id}"
    else
      halt 409
    end
  else
    halt 400
  end
end

get '/api/users/:id' do
  if user = get_user(params[:id])
    user.to_json
  else
    halt 404, json({ message: "Not found" })
  end
end

get '/api/users/:id/chats' do
  if chats = get_user_chats(params[:id])
    chats.to_json
  else
    halt 500
  end  
end

get '/api/users/:id/messages' do
  if messages = get_user_messages(params[:id])
    messages.to_json
  else
    halt 500
  end   
end

get '/api/chats' do
  if chats = get_all_chats
    chats.to_json
  else
    halt 500
  end   
end

get '/api/chats/:id' do
  if chat = get_chat(params[:id])
    chat.to_json
  else
    halt 404  
  end  
end

get '/api/chats/:id/users' do
  if users = get_chat_users(params[:id])
    users.to_json
  else
    halt 500
  end  
end

get '/api/chats/:id/messages' do
  if messages = get_chat_messages(params[:id])
    messages.to_json
  else
    halt 500
  end  
end

get '/api/phone/:phone' do  
  if user = get_user_by_phone(params[:phone])
    user.to_json
  else
    halt 404  
  end    
end
=end