class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    User.create( github_id: auth["uid"], 
                 username: auth["info"]["nickname"], 
                 email: auth["info"]["email"], 
                 image: auth["info"]["image"], 
                 access_token: auth["credentials"]["token"]
               )
  end
end
