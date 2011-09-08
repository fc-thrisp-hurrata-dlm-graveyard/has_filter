module HasFilter

  TRUE_VALUES = ["true", true, "1", 1]

  ALLOWED_TYPES = {
    :array => [ Array ],
    :hash => [ Hash ],
    :boolean => [ Object ],
    :default => [ String, Numeric ]
  }

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      helper_method :current_filters
      class_attribute :filters_configuration, :instance_writer => false
    end
  end
  
  module ClassMethods
    # Detects params from url and applies filter as method to your model.
    #
    # == Options
    #  tbd
    # == Block usage
    #  tbd
    def has_filter(*filters, &block)
      options = filters.extract_options!
      options.symbolize_keys!
      options.assert_valid_keys(:type, :only, :except, :if, :unless, :default, :as, :using, :allow_blank)
    
      if options.key?(:using)
        if options.key?(:type) && options[:type] != :hash
          raise "You cannot use :using with another :type different than :hash"
        else
          options[:type] = :hash
        end

        options[:using]  = Array(options[:using])
      end

      options[:only]   = Array(options[:only])
      options[:except] = Array(options[:except])
 
      self.filters_configuration = (self.filters_configuration || {}).dup

      #filters.each do |filter|
      #  self.filters_configuration[filter] ||= { :as => filter, :type => :default, :block => block }
      #  self.filters_configuration[filter] = self.filters_configuration[filter].merge(options)
      #end
   
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

  def apply_filters(target, hash=params)
    return target unless filters_configuration

    self.scopes_configuration.each do |scope, options|
      next unless apply_scope_to_action?(options)
      key = options[:as]

      if hash.key?(key)
        value, call_scope = hash[key], true
      elsif options.key?(:default)
        value, call_scope = options[:default], true
        value = value.call(self) if value.is_a?(Proc)
      end

      value = parse_value(options[:type], key, value)

      if call_scope && (value.present? || options[:allow_blank])
        current_scopes[key] = value
        target = call_scope_by_type(options[:type], scope, target, value, options)
      end
    end
  
    target
  end

  # Set the real value for the current scope if type check.
  def parse_value
  end

  def current_filters
  end

end
