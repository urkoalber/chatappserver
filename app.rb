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

class User < ActiveRecord::Base
  before_save :default_values
  has_and_belongs_to_many :chats
  has_many :messages
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

  def default_values
    self.type ||= 'text'
    self.content ||= ''    
  end  
end

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

before do
  content_type :json, :charset => 'utf-8'
end

get '/api/users' do
  if users = get_all_users
    users.to_json
  else
    halt 500
  end 
end

get '/api/users/:id' do
  if user = get_user(params[:id])
    user.to_json
  else
    halt 404  
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