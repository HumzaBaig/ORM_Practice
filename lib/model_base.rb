require_relative 'questions_db'

class ModelBase

  def self.find_by_id(id)
    item = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT *
      FROM #{self::TABLE_NAME}
      WHERE id = ?
    SQL

    self.new(item.first)
  end

  def self.all
    items = QuestionDBConnection.instance.execute(<<-SQL)
      SELECT *
      FROM #{self::TABLE_NAME}
    SQL

    items.map { |item| self.new(item) }
  end

  def initialize(options)
  end

end
