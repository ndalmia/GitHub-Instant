class UserRepoSearch < ActiveRecord::Base
  belongs_to :user
  belongs_to :repo

  validates_uniqueness_of :user_id, :scope => :repo_id
end
