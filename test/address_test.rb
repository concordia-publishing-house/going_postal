require "test_helper"

class AddressTest < ActiveSupport::TestCase
  include GoingPostal
  
  
  
  def test_address_to_yaml
    a = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'})
    yaml = a.to_yaml
    assert_match /:zip: '55555'/, yaml
    assert_match /:street: 555 Main/, yaml
    assert_match /:city: Average/, yaml
    assert_match /:state: MO/, yaml
    
    b = Address.new({'street' => '555 Main', 'city' => 'Average', 'state' => 'MO', 'zip' => '55555'})
    assert_equal a.to_yaml, b.to_yaml
  end
  
  
  
  def test_valid_address
    address = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555'})
    assert address.valid?
  end
  
  
  
  def test_invalid_addresses
    address = Address.new
    assert_equal true, address.blank?
    assert_equal false, address.valid?
    
    # address = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '5555'})
    # assert !address.valid?
    # assert address.errors[:zip].any?
    # 
    # address = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '55555-12'})
    # assert !address.valid?
    # assert address.errors[:zip].any?
    # 
    # address = Address.new({:street => '555 Main', :city => 'Average', :state => 'MO', :zip => '5555F'})
    # assert !address.valid?
    # assert address.errors[:zip].any?
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