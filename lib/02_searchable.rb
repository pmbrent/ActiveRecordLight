require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line(params)}
    SQL

    results.map { |row| self.new(row) }
  end

  def where_line(params)
    conditions = params.keys.map do |key|
      "#{key} = ?"
    end

    conditions.join(" AND ")
  end
end

class SQLObject
  extend Searchable
end
