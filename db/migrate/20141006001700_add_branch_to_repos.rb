class AddBranchToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :branch, :string
  end
end
