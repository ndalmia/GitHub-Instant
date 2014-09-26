GhInstant::Application.routes.draw do
require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'
require 'resque/server'
require 'resque-queue-priority-server'
  # namespace :api do
  #   namespace :v0 do
  #     get "polygon/show/:id" => 'polygon#show'
  #     get "polygon/suggest"
  #   end
  # end
  mount Resque::Server.new, :at => "/resque"

  
  get "functions/" => 'search#get_functions'
  get "show/" => 'search#show'
  get "search/" => 'search#search'
  get "/:google_id" => 'search#index'

  get "*path"   => redirect("404.html")
  post "*path"  => redirect("404.html")
end


