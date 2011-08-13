require 'test_helper'
require 'services'

class ServicesTest < MiniTest::Unit::TestCase
  class MyTestClass
    include Services
  end

  def test_authentication_service_should_exist
    service = MyTestClass.new.authentication_service
    assert service
    assert_equal MagicWebService, service.class
  end
end