require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_table = through_options.model_class.table_name
      through_primary_key = "#{through_table}.#{through_options.primary_key}"

      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.model_class.table_name
      source_primary_key = "#{source_table}.#{source_options.primary_key}"

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{source_options.foreign_key} = #{source_primary_key}
        WHERE
          #{through_primary_key} = #{self.send(through_options.foreign_key)}
      SQL

      source_options.model_class.new(results.first)
    end

  end
end
