module HasFilter

  TRUE_VALUES =

  ALLOWED_TYPES =

  def self.included(base)
  end
  
  module ClassMethods
    # Detects params from url and applies filter as method to your model.
    #
    # == Options
    #  tbd
    # == Block usage
    #  tbd
    def has_filter
    end

  end

protected

  # Receives an object where filters will be applied to.
  #
  # In model:
  #
  #   def self.filter_today
  #   end
  #
  #   def self.filter_by_tag
  #   end
  # 
  # In controller:
  #
  # class TicketsController < ApplicationController
  #   has_filter :today
  #   has_filter :by_tag
  #
  #   def index
  #     @tickets = apply_filters(Ticket).all
  #   end
  # end
  #

  def apply_filters
  end

  def current_filters
  end

end
