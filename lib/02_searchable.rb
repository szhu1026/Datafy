require_relative 'db_connection'
require_relative '01_sql_object'


module Searchable
  def where(params)
    where_line = params.keys.map { |column| "#{column} = ?" }.join(" AND ")
    where_vals = params.values
    results = DBConnection.execute(<<-SQL, *where_vals)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
