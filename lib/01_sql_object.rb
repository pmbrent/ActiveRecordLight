require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    col_strs_arr = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{table_name}
    SQL

    col_strs_arr.map { |el| el.to_sym }
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
      define_method(column) do
        attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    self.table_name = self.to_s.tableize if !@table_name
    @table_name
  end

  def self.all
    records = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    self.parse_all(records)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    row.empty? ? nil : self.new(row[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
        self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      self.send(col.to_s)
    end
  end

  def insert
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks(self.class.columns.length)}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def col_names
    "( #{self.class.columns.join(", ")} )"
  end

  def col_eqs
    self.class.columns.map {|attr_name| "#{attr_name} = ?"}.join(",")
  end

  def question_marks(n)
    "( #{Array.new(n) {"?"}.join(", ")} )"
  end

  def update
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_eqs}
      WHERE
        id = ?
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def save
    id.nil? ? insert : update
  end
end
