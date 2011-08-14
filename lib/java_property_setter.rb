
# Makes the JAXB Java annotation classes available.
module JaxbAnnotation
  include_package "javax.xml.bind.annotation"
end

# Allows the properties to be set on a JAXB Java object from an array of properties or
# another object with the same properties
class JavaPropertySetter

  # Created with the Java object
  def initialize(java_obj)
    @java_object = java_obj
    initialize_property_names_to_types
  end

  # Sets the properties on the Java object from an array of values.  The array order
  # must match the order of the elements defined in the XML schema.
  def set_properties_from_array(properties)
    @property_names_to_types.keys.zip(properties).each do |name, value|
      set_value(name, value)
    end
  end

  # Sets the properties on the Java object using an object that has the same properties.
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
      # Ruby strings need no conversion to Java strings.
      value
    else
      if property_type.start_with? "authentication."
        # This type starts our package for generated JAXB types.
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

  # Initializes a hash mapping property names to property types.
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