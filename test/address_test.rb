require "test_helper"

class AddressTest < ActiveSupport::TestCase
  
  def test_address_to_yaml
    a = Address.new(HashWithIndifferentAccess.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'}))
    b = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'})
    assert_equal a.to_yaml, b.to_yaml
    
    a = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'})
    b = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'})
    assert_equal a.to_yaml, b.to_yaml
  end
  
  def test_address_symbolize_keys
    hash = {"test" => "1"}
    answer = {:test => "1"}
    a = Address.new
    assert_equal answer, a.symbolize_keys(hash)
  end
  
  def test_address_comparison
    a = Address.new({:street => "555 main", :city => "Average", :state => "MO", :zip => "55555"})
    b = Address.new({:street => "555 main", :city => "Average", :state => "MO", :zip => "55555"})
    assert_equal a, b
    
    a = Address.new({:street => "556 main", :city => "Average", :state => "MO", :zip => "55555"})
    b = Address.new({:street => "555 main", :city => "Average", :state => "MO", :zip => "55555"})
    assert_not_equal a, b
    
    # comparing with a string should not work
    a = Address.new({:street => "556 main", :city => "Average", :state => "MO", :zip => "55555"})
    b = "556 main\nAverage, MO  55555"
    assert_not_equal a, b
  end
  
  def test_address_to_s
    address = Address.new(:street => '555 Example', :city => "Example", :state => "MO", :zip => "55555")
    assert_equal "555 Example\nExample, MO  55555", address.to_s
  end
  
end