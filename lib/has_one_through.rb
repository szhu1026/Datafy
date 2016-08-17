require_relative 'associatable'
module Associatable


  def has_one_through(name, through, source)
    define_method(name) do
      through_options = self.class.assoc_options[through]
      source_options =
        through_options.model_class.assoc_options[source]

      t_table = through_options.table_name
      t_PK = through_options.primary_key
      t_FK = through_options.foreign_key

      s_table = source_options.table_name
      s_PK = source_options.primary_key
      s_FK = source_options.foreign_key

      key_val = self.send(t_FK)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{s_table}.*
        FROM
          #{t_table}
        JOIN
          #{s_table}
        ON
          #{t_table}.#{s_FK} = #{s_table}.#{s_PK}
        WHERE
          #{t_table}.#{t_PK} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
