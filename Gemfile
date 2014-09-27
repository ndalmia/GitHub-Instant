source 'https://rubygems.org'

group :production do
  gem 'rails_12factor'
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'pg'
gem 'rails', '4.0.5'
gem 'httparty'
gem 'rack-ssl-enforcer'

#My custom gems. 
gem 'activerecord-postgis-adapter'
gem "redis"
gem "activerecord-import", '>=0.4.0'
gem "elasticsearch"
gem "resque", "~> 1.25.1", :require=>"resque/server"
gem 'resque-loner'
gem 'resque-scheduler', '2.5.5'
gem 'resque-queue-priority', '~> 0.6.2'
gem 'figaro', '0.7.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem "rails-erd"
  gem 'ruby-prof'
  gem 'pry', '~> 0.9.12.6'
  gem 'thin'
  gem 'pry-rails'
  gem "better_errors"
  gem 'hirb'
  gem 'byebug'
  gem 'awesome_print'#, :require => 'ap'
end

gem 'faye'
gem 'jquery-rails'
gem 'turbolinks'

group :assets do
  gem 'uglifier'
end
