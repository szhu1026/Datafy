require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions
  def initialize(className, options={})
    defaults = {
      foreign_key: "#{className}_id".to_sym,
      primary_key: :id,
      class_name: className.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(className, foreignClassName, options={})
    defaults = {
      foreign_key: "#{foreignClassName.downcase}_id".to_sym,
      primary_key: :id,
      class_name: className.to_s.singularize.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable

  def assoc_options
    @assoc_options ||= {}
  end

  def belongs_to(association, options={})

    self.assoc_options[association] = BelongsToOptions.new(association, options)

    define_method(association) do
      options = self.class.assoc_options[association]

      key_val = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => key_val)
        .first
    end

  end


  def has_many(association, options = {})

    self.assoc_options[association] = HasManyOptions.new(association, self.name, options)

    define_method(association) do
      options = self.class.assoc_options[association]

      key_val = self.send(options.primary_key)

      options
        .model_class
        .where(options.foreign_key => key_val)
    end

  end

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

class SQLObject
  extend Associatable
end
