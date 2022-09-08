class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.serialized_attr_accessor(field, *args)
    args.each do |method_name|
      eval "
        def #{method_name}
          (self.#{field} || {})['#{method_name}']
        end

        def #{method_name}=(value)
          puts \"self.#{field}\"
          puts \"HERE\"
          self.#{field} ||= {}
          self.#{field}['#{method_name}'] = value
        end
      "
    end
  end
end
