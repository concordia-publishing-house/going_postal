# todo: use ActiveModel in Rails 3.0 instead

class Composite::Base 
  attr_reader :errors
  
  
  # these next two methods are copied from ActiveRecord::Base
  # can't wait for ActiveModel :)
  def self.human_name(options = {})
    defaults = self_and_descendants_from_active_record.map do |klass|
      "#{klass.name.underscore}""#{klass.name.underscore}"
    end 
    defaults << self.name.humanize
    I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
  end
  
  def self.human_attribute_name(attribute_key_name, options = {})
    defaults = self_and_descendants_from_active_record.map do |klass|
      "#{klass.name.underscore}.#{attribute_key_name}""#{klass.name.underscore}.#{attribute_key_name}"
    end
    defaults << options[:default] if options[:default]
    defaults.flatten!
    defaults << attribute_key_name.to_s.humanize
    options[:count] ||= 1
    I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
  end  

  def initialize
  	# http://www.stephenchu.com/2008/05/rails-composedof-validation.html
  	@errors = ActiveRecord::Errors.new self
  end

  def valid?
  	validate
  	return (errors.length == 0)
  end
  
  def self.self_and_descendants_from_active_record
    klass = self
    classes = [klass]
    while klass != klass.base_class  
      classes << klass = klass.superclass
    end
    classes
  rescue
    # OPTIMIZE this rescue is to fix this test: ./test/cases/reflection_test.rb:56:in `test_human_name_for_column'
    # Appearantly the method base_class causes some trouble.
    # It now works for sure.
    [self]
  end

protected

  def validate
  end
  
end