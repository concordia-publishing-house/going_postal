module ActiveModel
  
  class Errors
    
    def initialize
      @hash = Hash.new
    end
    
    delegate :clear, :to => :@hash

    def [](attribute)
      if errors = @hash[attribute.to_sym]
        errors.size == 1 ? errors.first : errors
      else
        @hash[attribute.to_sym] = []
      end
    end

    def []=(attribute, error)
      self[attribute.to_sym] << error
    end

    def each
      @hash.each_key do |attribute| 
        self[attribute].each { |error| yield attribute, error }
      end
    end

    def size
      @hash.values.flatten.size
    end
    alias :count :size
    
    def empty?
      self.size.zero?
    end
    
    def any?
      !self.empty?
    end

    def to_a
      @hash.inject([]) do |errors_with_attributes, (attribute, errors)|
        if error.blank?
          errors_with_attributes
        else
          if attr == :base
            errors_with_attributes << error
          else
            errors_with_attributes << (attribute.to_s.humanize + " " + error)
          end
        end
      end
    end
    
    def on(attribute)
      ActiveSupport::Deprecation.warn "Errors#on have been deprecated, use Errors#[] instead"
      self[attribute]
    end

    def on_base
      ActiveSupport::Deprecation.warn "Errors#on_base have been deprecated, use Errors#[:base] instead"
      on(:base)
    end

    def add(attribute, msg = Errors.default_error_messages[:invalid])
      ActiveSupport::Deprecation.warn "Errors#add(attribute, msg) has been deprecated, use Errors#[attribute] << msg instead"
      self[attribute] << msg
    end

    def add_to_base(msg)
      ActiveSupport::Deprecation.warn "Errors#add_to_base(msg) has been deprecated, use Errors#[:base] << msg instead"
      self[:base] << msg
    end
  
    def invalid?(attribute)
      ActiveSupport::Deprecation.warn "Errors#invalid?(attribute) has been deprecated, use Errors#[attribute].any? instead"
      self[attribute].any?
    end

    def full_messages
      ActiveSupport::Deprecation.warn "Errors#full_messages has been deprecated, use Errors#to_a instead"
      to_a
    end

    def each_full
      ActiveSupport::Deprecation.warn "Errors#each_full has been deprecated, use Errors#to_a.each instead"
      to_a.each { |error| yield error }
    end    

    def to_xml(options={})
      options[:root]    ||= "errors"
      options[:indent]  ||= 2
      options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

      options[:builder].instruct! unless options.delete(:skip_instruct)
      options[:builder].errors do |e|
        to_a.each { |error| e.error(error) }
      end
    end
  end


  class Base
    attr_reader :errors

    def initialize
      @errors = ActiveModel::Errors.new
      super
    end

=begin
    def errors
      @errors ||= ActiveModel::Errors.new
    end

    def freeze
      # don't freeze me!
    end
=end    

    def valid?
      errors.clear
      if respond_to?(:validate)
        validate
      end
      errors.empty?
    end

  end
  
end