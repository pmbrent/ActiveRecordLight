require_relative '01_sql_object'
require_relative '02_searchable'
require_relative '03_associatable'
require_relative '04_associatable2'

class Relation

  include Searchable
  # store info from WHERE queries; perform them only
  # when e.g. an enumerable is called
  # allow for chaining of WHERE's by adding to the stored query

  attr_reader :params, :model_class

  def initialize(model_class, params = {})
    @model_class, @params = model_class, params
  end

  def table_name
    model_class.table_name
  end

  def parse_all(results)
    model_class.parse_all(results)
  end

  def each
    where(params).each { yield }
  end

  def method_missing(symbol, *args)
    where(params).send(symbol, *args)
  end

end

module Searchable
    def lazy_where(new_params)
      if self.is_a? Relation
        Relation.new(model_class, params.merge(new_params))
      else
        Relation.new(self, new_params)
      end
    end
end

# For testing
# class Human < SQLObject
#   self.table_name = 'humans'
#   self.finalize!
# end
