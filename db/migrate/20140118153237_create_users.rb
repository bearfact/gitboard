class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :provider, null: false
    	t.string :login, null: false
 			t.string :uid, null: false
 			t.string :name
 			t.string :oauth_token, null: false
      t.timestamps
    end
  end
end
