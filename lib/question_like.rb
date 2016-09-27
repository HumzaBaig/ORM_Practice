require_relative 'questions_db'
require_relative 'user'
require_relative 'question'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.likers_for_question_id(question_id)
    likers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT u.*
      FROM users AS u
      JOIN question_likes AS ql ON (ql.user_id = u.id)
      WHERE ql.question_id = ?
    SQL

    likers.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT COUNT(u.id) AS num_likes
      FROM users AS u
      JOIN question_likes AS ql ON (ql.user_id = u.id)
      WHERE ql.question_id = ?
      GROUP BY ql.question_id
    SQL

    count.first['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT q.*
      FROM questions AS q
      JOIN question_likes AS ql ON (ql.question_id = q.id)
      WHERE ql.user_id = ?
    SQL

    liked_questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT q.*
      FROM questions AS q
        JOIN question_likes AS ql
          ON q.id = ql.question_id
      GROUP BY q.id
      ORDER BY COUNT(q.id) DESC
      LIMIT ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
