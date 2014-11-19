class CreateChatsUsers < ActiveRecord::Migration
  def up
    create_table :chats_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :chat
    end
  end
  def down
    drop_table :chats_users
  end  
end
