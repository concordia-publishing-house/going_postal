require 'test_helper'

class ActiveModelTest < ActiveSupport::TestCase
  
  
  test "errors are stored in an array" do
    test = TestClass.new
    test.errors.add(:key, "Message")
    assert test.errors.instance_variable_get("@hash")[:key].is_a?(Array)
    
    # but when there's only one error, it is returned as a string
    assert test.errors[:key].is_a?(String)
  end
  
  test "when there's only one error stored in an array; don't crash" do
    test = TestClass.new
    test.errors.add(:key, "Message")
    assert test.errors[:key].is_a?(String)
    assert_nothing_raised do
      test.errors.each {|key, value|} # This only fails on Ruby 1.9!
    end
  end
  
  
end
