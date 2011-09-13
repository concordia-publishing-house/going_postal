require "test_helper"

class ParsingTest < ActiveSupport::TestCase
  include GoingPostal
  
  def self.test(string, hash)
    super(string) do
      expected_address = Address.new(hash)
      assert_equal expected_address, Address.parse(string)
    end
  end
  
  
  test "3558 S Jefferson Ave\nSt Louis, MO 63118",
      {:street => "3558 S Jefferson Ave", :city => "St Louis", :state => "MO", :zip => "63118"}
  
  # test "Lewes-Georgetown Hwy, Georgetown, DE 19947",
  #      {:street => "Lewes-Georgetown Hwy", :city => "Georgetown", :state => "DE", :zip => "19947"}
  # 
  # test "P.O. Box 778 Dover, DE 19903",
  #      {:street => "P.O. Box 778", :city => "Dover", :state => "DE", :zip => "19903"}
  
  
  
end