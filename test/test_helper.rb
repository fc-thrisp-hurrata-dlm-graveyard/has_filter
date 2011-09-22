require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'mocha'

# Configure Rails
ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'action_controller'
require 'action_dispatch/middleware/flash'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'has_filter'

HasFilter::Routes = ActionDispatch::Routing::RouteSet.new
HasFilter::Routes.draw do
  match '/:controller(/:action(/:id))'
end

class ApplicationController < ActionController::Base
  include HasFilter::Routes.url_helpers
end

class ActiveSupport::TestCase
  setup do
    @routes = HasFilter::Routes
  end
end
