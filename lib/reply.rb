require_relative 'questions_db'
require_relative 'user'
require_relative 'question'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :body, :parent_id, :question_id, :user_id
  TABLE_NAME = 'replies'


  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?;
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?;
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def save
    @id ? update : create
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, @parent_id, @question_id, @user_id, @body)
      INSERT INTO
        users (parent_id, question_id, user_id, body)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    PlayDBConnection.instance.execute(<<-SQL, @parent_id, @question_id, @user_id, @body, @id)
      UPDATE
        replies
      SET
        parent_id = ?, question_id = ?, user_id = ?, body = ?
      WHERE
        id = ?
    SQL
  end

  def author
    author = QuestionDBConnection.instance.execute(<<-SQL, @user_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    User.new(author.first)
  end

  def question
    question = QuestionDBConnection.instance.execute(<<-SQL, @question_id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL
    Question.new(question.first)
  end

  def parent_reply
    parent = QuestionDBConnection.instance.execute(<<-SQL, @parent_id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    return nil unless parent.count > 0
    Reply.new(parent.first)
  end

  def child_replies
    children = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT *
      FROM replies
      WHERE parent_id = ?
    SQL

    children.map { |reply| Reply.new(reply) }
  end

end
