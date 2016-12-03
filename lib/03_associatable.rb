require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore.singularize}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    opts = BelongsToOptions.new(name, options)
    define_method(name) do
      f_key = opts.send(:foreign_key)
      c_name = opts.model_class
      p_key = opts.send(:primary_key)
      result = c_name.where(p_key => self.send(f_key))
      result.first
    end
  end

  def has_many(name, options = {})
    opts = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      f_key = opts.send(:foreign_key)
      p_key = opts.send(:primary_key)
      c_name = opts.model_class
      result = c_name.where(f_key => self.send(p_key))
      result
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable

end
