class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username
      t.string :state
      t.string :phone
      t.timestamps
    end
    User.create(username: "Héctor", state: "ola k ase", phone: "678123456")
  end
 
  def down
    drop_table :users
  end
end