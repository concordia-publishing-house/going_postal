module HashAccessors

  module ClassMethods

    def hash_accessors_for(hash_name,names)
      for name in names
        hash_reader_for(hash_name,name)
        hash_writer_for(hash_name,name)
      end
    end

    def hash_readers_for(hash_name,names)
      for name in names
        hash_reader_for(hash_name,name)
      end
    end

    def hash_writers_for(hash_name,names)
      for name in names
        hash_writer_for(hash_name,name)
      end
    end

    def hash_accessor_for(hash_name,name)
      hash_reader_for(hash_name,name)
      hash_writer_for(hash_name,name)
    end

    def hash_reader_for(hash_name,name)
      define_method "#{name}" do
        hash = instance_variable_get "@#{hash_name}"
        return hash[name]
      end
    end

    def hash_writer_for(hash_name,name)
      define_method "#{name}=" do |val|
        hash = instance_variable_get "@#{hash_name}"
        hash[name] = val
      end
    end

  end

private

  def self.included(other_module)
    other_module.extend ClassMethods
  end

end