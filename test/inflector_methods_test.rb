require 'test_helper'
require 'inflector_methods'

class InflectorMethodsTest < MiniTest::Unit::TestCase

  def test_underscore
    assert_equal "", "".underscore
    assert_equal "f", "f".underscore
    assert_equal "f", "F".underscore
    assert_equal "foo", "foo".underscore
    assert_equal "foo", "Foo".underscore

    assert_equal "foo_bar", "FooBar".underscore
    assert_equal "foo_bar", "fooBar".underscore
    assert_equal "foo_bar", "fooBar".underscore
    assert_equal "foo_ba", "fooBa".underscore
    assert_equal "foo_b", "fooB".underscore
    assert_equal "f_b", "FB".underscore
    assert_equal "fb", "fb".underscore
    assert_equal "f_b", "f_b".underscore
  end

  def test_camelize
    assert_equal "", "".camelize
    assert_equal "F", "f".camelize
    assert_equal "Foo", "foo".camelize
    assert_equal "FooBar", "foo_bar".camelize
  end

  
end