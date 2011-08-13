require 'test_helper'
require 'java_dependencies'
require 'java_property_setter'
require 'ostruct'

class JavaPropertySetterTest < MiniTest::Unit::TestCase

  def test_set_properties_from_array
    client_info = Ws::ClientInformation.new

    expected = Ws::ClientInformation.new
    expected.client_id = "magic web service"
    expected.user_ip_address = "127.0.0.1"

    property_setter = JavaPropertySetter.new(client_info)
    property_setter.set_properties_from_array([expected.client_id, expected.user_ip_address])

    assert_equal expected.client_id, client_info.client_id
    assert_equal expected.user_ip_address, client_info.user_ip_address
  end

  def test_set_properties_from_object
    client_info = Ws::ClientInformation.new

    expected = Ws::ClientInformation.new
    expected.client_id = "magic web service"
    expected.user_ip_address = "127.0.0.1"

    object = OpenStruct.new
    object.client_id = "magic web service"
    object.user_ip_address = "127.0.0.1"

    property_setter = JavaPropertySetter.new(client_info)
    property_setter.set_properties_from_object(object)

    assert_equal expected.client_id, client_info.client_id
    assert_equal expected.user_ip_address, client_info.user_ip_address
  end

  def test_set_properties_array_containing_object
    object = OpenStruct.new
    object.client_id = "magic web service"
    object.user_ip_address = "127.0.0.1"
    args = ["guest","pass", object]

    login = Ws::Login.new
    property_setter = JavaPropertySetter.new(login)
    property_setter.set_properties_from_array(args)

    assert_equal "guest", login.username
    assert_equal "pass", login.password
    assert_equal "magic web service", login.client_info.client_id
    assert_equal "127.0.0.1", login.client_info.user_ip_address
  end

end