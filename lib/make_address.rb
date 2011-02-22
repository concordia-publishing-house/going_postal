require 'address'

module MakeAddress
  
  def make_address(*parts)
    for part_id in parts
      composed_of part_id,
                  :class_name => "Address",
                  :allow_nil => true,
                  :mapping => [part_id, "to_yaml"], # changed because 'saver' is not a method of NilClass and this is an accurate name
                  :constructor => :loader,
                  :converter => :converter
    end
  end
  
end