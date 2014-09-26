class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :status
      t.string :url
      t.timestamps
    end
  end
end
