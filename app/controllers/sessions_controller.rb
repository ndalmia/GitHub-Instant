class SessionsController < ApplicationController
  def github_callback   
   auth = request.env["omniauth.auth"]     
   user = User.find_by_github_id(auth["uid"]) || User.create_with_omniauth(auth)     
   session[:user_id] = user.id     
   redirect_to root_url, :notice => "Signed in!"
  end
 
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
