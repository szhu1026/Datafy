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

  def assoc_options
    @assoc_options ||= {}
  end

end

class SQLObject
  extend Associatable
end
