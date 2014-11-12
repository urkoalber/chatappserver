require 'sinatra'
require 'json'

before do
  content_type :json, :charset => 'utf-8'
end

def db(type, id = nil)
  fake_db = {
    :users => {
      1 => {:username => 'Héctor', :state => 'ola k ase', :phone => '666666666'}, 
      2 => {:username => 'Urko', :state => 'que pasa loko!', :phone => '654321789'},
      3 => {:username => 'Diego', :state => ':)', :phone => '678901234'},
      4 => {:username => 'Isabel', :state => 'juasjuas', :phone => '655555555'}
    },
    :chats => {
      1 => {:name => 'FI UPM', :users => [1,2,3]},
      2 => {:name => 'Sábado', :users => [1,3,4]},
      3 => {:name => 'Colegio', :users => [1,4]},
      4 => {:name => '', :users => [1,4]}
    },
    :messages => {
      1 => {:type => 'text', :sender => 1, :chat => 3, :content => 'Hola, guapa!'},
      2 => {:type => 'text', :sender => 1, :chat => 4, :content => 'te quiero :$'},
      3 => {:type => 'text', :sender => 4, :chat => 3, :content => 'Se sabe algo de los del colegio?'},
      4 => {:type => 'text', :sender => 4, :chat => 4, :content => 'Nos hemos quedado solos!!'},
      5 => {:type => 'text', :sender => 1, :chat => 1, :content => 'Soy Héctor!'},
      6 => {:type => 'text', :sender => 2, :chat => 1, :content => 'Soy Urko!'},
      7 => {:type => 'text', :sender => 3, :chat => 1, :content => 'Soy Diego!'},
      8 => {:type => 'text', :sender => 1, :chat => 2, :content => 'A qué hora este sábado?'},
      9 => {:type => 'text', :sender => 3, :chat => 2, :content => 'Sobre las 10?'},
      10 => {:type => 'text', :sender => 4, :chat => 2, :content => 'Mejor a las 11 :)'}
    }
  }
  if id 
    fake_db[type][id.to_i]
  else
    fake_db[type]
  end
end

def get_user(id)
  db(:users, id.to_i)
end

def get_messages(user_id)
  user_messages = []
  all_messages = db(:messages)  
  all_messages.keys.each do |k|
    user_messages << all_messages[k] if all_messages[k][:sender] == user_id.to_i      
  end
  user_messages
end

def get_chats(user_id)
  user_chats = []
  all_chats = db(:chats)
  all_chats.keys.each do |k|
    user_chats << all_chats[k] if all_chats[k][:users].include? user_id.to_i 
  end
  user_chats  
end

get '/api/users/:id' do  
  if user = get_user(params[:id])
    user.to_json
  else
    halt 404  
  end
end

get '/api/users/:id/messages' do
  if messages = get_messages(params[:id])
    messages.to_json
  else
    halt 404  
  end    
end

get '/api/users/:id/chats' do
  if chats = get_chats(params[:id])
    chats.to_json
  else
    halt 404  
  end    
end

post '/' do 
  params_json = JSON.parse(request.body.read)  
end

