class Repo < ActiveRecord::Base
  before_create :set_default_status

  def set_default_status
    self.status = "INACTIVE"
  end
end
