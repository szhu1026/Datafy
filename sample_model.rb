require_relative "./lib/sql_object"

class Plant < SQLObject
  belongs_to :humans, foreign_key: :owner_id

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :plants, foreign_key: :owner_id

  finalize!
end
