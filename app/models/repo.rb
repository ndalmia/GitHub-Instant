class Repo < ActiveRecord::Base
  before_create :set_first_status

  def set_first_status
    self.status = "NEW"
  end
end
