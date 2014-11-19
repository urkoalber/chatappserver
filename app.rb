# app.rb
require "sinatra"
require "json"
require "sinatra/activerecord"
 
set :database, "sqlite3:app.db"

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