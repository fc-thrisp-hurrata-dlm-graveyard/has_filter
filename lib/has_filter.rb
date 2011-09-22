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

      filters.each do |filter|
        self.filters_configuration[filter] ||= { :as => filter, :type => :default, :block => block }
        self.filters_configuration[filter] = self.filters_configuration[filter].merge(options)
      end
   
    end

  end

protected

  def apply_filters(target, hash=params)
    return target unless filters_configuration

    self.filters_configuration.each do |filter, options|
      next unless apply_filter_to_action?(options)
      key = options[:as]

      if hash.key?(key)
        value, call_filter = hash[key], true
      elsif options.key?(:default)
        value, call_filter = options[:default], true
        value = value.call(self) if value.is_a?(Proc)
      end

      value = parse_value(options[:type], key, value)

      if call_filter && (value.present? || options[:allow_blank])
        current_filters[key] = value
        target = call_filter_by_type(options[:type], filter, target, value, options)
      end
    end
  
    target
  end

  # Set the real value for the current scope if type check.
  def parse_value
    if type == :boolean
      TRUE_VALUES.include?(value)
    elsif value && ALLOWED_TYPES[type].none?{ |klass| value.is_a?(klass) }
      raise "Expected type :#{type} in params[:#{key}], got #{value.class}"
    else
      value
    end
  end

  def call_filter_by_type(type, filter, target, value, options)
    block = options[:block]
    if type == :boolean
      block ? block.call(self, target) : target.send(scope)
    elsif value && options.key?(:using)
      value = value.values_at(*options[:using])
      block ? block.call(self, target, value) : target.send(scope, *value)
    else
    block ? block.call(self, target, value) : target.send(fiter, value)#basic case 
    end
  end

  def apply_filter_to_action?(options) #:nodoc:
    return false unless applicable?(options[:if], true) && applicable?(options[:unless], false)

    if options[:only].empty?
      options[:except].empty? || !options[:except].include?(action_name.to_sym)
    else
      options[:only].include?(action_name.to_sym)
    end
  end

  def applicable?(string_proc_or_symbol, expected) #:nodoc:
    case string_proc_or_symbol
      when String
        eval(string_proc_or_symbol) == expected
      when Proc
        string_proc_or_symbol.call(self) == expected
      when Symbol
        send(string_proc_or_symbol) == expected
      else
        true
    end
  end

  def current_filters
    @current_filters ||= {}
  end

end

ActionController::Base.send :include, HasFilter
