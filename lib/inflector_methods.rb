# Adds methods needed that ActiveSupport Inflector would normally add.
# This avoids dependencies on other gems

String.class_eval do 

  # Converts strings in snake case to camel case
  def camelize
    split("_").map do |word|
      m = /(.)(.*)/.match(word)
      m[1].upcase + m[2]
    end.join
  end

  # Converts strings in camel case to snake case
  def underscore
    started = false
    split(/([A-Z])/).inject([]) do |parts, word|
      if word.size == 1 && word =~ /[A-Z]/
        parts << "_" if started
      end

      if word.size > 0
        parts << word.downcase
        started = true
      end
      parts
    end.join
  end
end