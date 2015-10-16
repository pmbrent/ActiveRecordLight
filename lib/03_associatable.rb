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
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.camelcase
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    bto = BelongsToOptions.new(name, options)

    define_method(name) do
      match_val = self.send(bto.send(:foreign_key))
      owner = bto.send(:model_class)
              .where(bto.send(:primary_key) => match_val).first
    end
  end

  def has_many(name, options = {})
    hmo = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      match_val = self.send(hmo.send(:primary_key))
      owned = hmo.send(:model_class)
              .where(hmo.send(:foreign_key) => match_val)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
