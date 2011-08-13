module JaxbAnnotation
  include_package "javax.xml.bind.annotation"
end

class JavaPropertySetter

  def initialize(java_obj)
    @java_object = java_obj
    initialize_property_names_to_types
  end

  def set_properties_from_array(properties)
    @property_names_to_types.keys.zip(properties).each do |name, value|
      set_value(name, value)
    end
  end

  def set_properties_from_object(object)
    @property_names_to_types.keys.each do |name|
      set_value(name, object.send(name))
    end
  end

  private

  def set_value(property_name, value)
    property_type = @property_names_to_types[property_name]
    value = convert_value_to_type(value, property_type)
    @java_object.send("#{property_name}=",value)
  end

  def convert_value_to_type(value, property_type)
    return if value.nil?

    case property_type
    when "java.lang.String"
      value
    else
      if property_type.start_with? "authentication."
        # This type starts our package for generated jaxb types
        # It's a complex object.
        property_type_class = Ws.const_get(property_type.split(".").last)
        new_obj = property_type_class.new
        JavaPropertySetter.new(new_obj).set_properties_from_object(value)
        new_obj
      else
        raise "Unhandled property type #{property_type}.  TODO add support for this."
      end
    end
  end

  def initialize_property_names_to_types
    @property_names_to_types = {}
    java_obj_class = @java_object.class.java_class
    # Get the annotation on the java class that indicates the order of the properties
    annotation = java_obj_class.annotation(JaxbAnnotation::XmlType.java_class)
    property_names = annotation.prop_order.map(&:to_s)

    property_names.each do |name|
      type = java_obj_class.java_method("get#{name.camelize}").return_type.to_s
      @property_names_to_types[name.underscore] = type
    end
  end

end