require_relative 'db_connection'
require 'active_support/inflector'


class SQLObject

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.underscore.pluralize
  end

  def self.columns
    @data ||= DBConnection.execute2(<<-SQL)
       SELECT
         *
       FROM
         #{self.table_name}
       LIMIT 1;
     SQL

     @data[0].map {|key| key.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def initialize(params = {})
    params.each do |key, val|
      if !self.class.columns.include?(key.to_sym || key.to_s )
        raise "unknown attribute '#{key}'"
      else
      self.send(key.to_s + "=", val)
      end
    end
  end


  def self.all
    data = DBConnection.instance.execute(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
    SQL

    parse_all(data)
  end

  def attribute_values

   self.class.columns.map do |column|
     self.send(column)
   end

 end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(results).first
  end




  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map{|column| column.to_s}.join(", ")
    questionmarks = (["?"] * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name}
        (#{col_names})
      VALUES
        (#{questionmarks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns
      .map { |column| "#{column} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
