# Defines underscore and pluralize methods
# unless they've already been defined by another script.

unless String.new.methods.include? :underscore
  class String
    def underscore
      self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end

unless String.new.methods.include? :pluralize
  class String
    def pluralize
      if self.match /y$/
        self.gsub /y$/, 'ies'
      elsif self.match /us$/
        self.gsub /us$/, 'i'
      else
        self + 's'
      end
    end
  end
end

