class CreateTables < ActiveRecord::Migration
  def up
    create_table :chats do |t|
      t.string :name
      t.timestamps
    end    

    create_table :users_chats, id: false do |t|
      t.belongs_to :user
      t.belongs_to :chat
    end
  
    create_table :messages do |t|
      t.string :type
      t.text :content
      t.belongs_to :user
      t.belongs_to :chat
      t.timestamps
    end
  end
    
  def down
    drop_table :users_chats
    drop_table :messages
    drop_table :chats
  end        
end


