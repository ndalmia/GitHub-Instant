class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :github_id
      t.string :access_token
      t.string :email
      t.string :image

      t.timestamps
    end
  end
end
