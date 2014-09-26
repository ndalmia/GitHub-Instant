source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.5'

#My custom gems. 
gem 'pg'
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
