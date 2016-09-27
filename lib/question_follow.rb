require_relative 'questions_db.rb'
require_relative 'user'
require_relative 'question'

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.followers_for_question_id(question_id)
    followers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT u.*
    FROM users AS u
    JOIN question_follows AS q ON (q.user_id = u.id)
    WHERE q.question_id = ?
    SQL

    followers.map { |user| User.new(user) }
  end

  def self.questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT q.*
    FROM questions AS q
    JOIN question_follows AS qf ON (qf.question_id = q.id)
    WHERE qf.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
      SELECT q.*
      FROM questions AS q
        JOIN question_follows AS qf
          ON q.id = qf.question_id
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
