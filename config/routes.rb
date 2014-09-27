GhInstant::Application.routes.draw do
require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'
require 'resque/server'
require 'resque-queue-priority-server'
  mount Resque::Server.new, :at => "/resque"

  root 'search#index'
  get 'file'  => 'search#file'
  get 'files' => 'search#files'
  get 'functions' => 'search#functions'

  get "*path"   => redirect("404.html")
  post "*path"  => redirect("404.html")
end


