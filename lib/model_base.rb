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

  def save
    @id ? update : create
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, *get_instance_vars)
      INSERT INTO
        #{self.class::TABLE_NAME} (#{get_instance_var_names.join(', ')})
      VALUES
        (#{get_escapes})
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionDBConnection.instance.execute(<<-SQL, *get_instance_vars)
      UPDATE
        #{self.class::TABLE_NAME}
      SET
        #{get_instance_var_names.join(' = ?, ')}
      WHERE
        id = ?
    SQL
  end

  def get_instance_vars
    vars = []
    self.instance_variables.drop(1).each do |var|
      vars << self.send(var.to_s[1..-1])
    end
    vars
  end

  def get_instance_var_names
    self.instance_variables.map { |var| var.to_s[1..-1] }.drop(1)
  end

  def get_escapes
    escapes = []
    self.instance_variables.drop(1).length.times { escapes << "?"}
    escapes = escapes.join(', ')
  end

end
