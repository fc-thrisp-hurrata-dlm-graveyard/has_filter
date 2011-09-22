require 'test_helper'

class Cat
end

class CatsController < ApplicationController
   has_filter :color
   has_filter :only_lol, :type=>:boolean
   has_filter :fur_pattern, :as=>:fur
   has_filter :age, :default => 2
   has_filter :calculate_weight, :default => proc { |c| c.session[:height] || 5 }
  

  def index
    @cats = apply_filters(Cat).all
  end

  def show
   @cats = apply_filters(Cat).get(params[:id])
  end

  protected

    def show_all_colors?
      false
    end

end

class HasScopeTest < ActionController::TestCase
  tests CatsController

  def test_filter_is_called
  end

  def test_scope_with_default_value_as_proc
  end

  protected
  
  def current_filters
    @controller.send :current_scopes
  end

end


