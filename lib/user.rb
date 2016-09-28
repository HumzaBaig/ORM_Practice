require_relative 'questions_db'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :fname, :lname
  TABLE_NAME = 'users'

  def self.find_by_name(fname, lname)
    user = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    user_stats = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT COUNT( DISTINCT q.id ) AS num_questions,
             CAST(COUNT( ql.id ) AS FLOAT) AS num_likes
      FROM
        questions AS q
        LEFT OUTER JOIN question_likes AS ql
          ON q.id = ql.question_id
      WHERE
        q.user_id = ?
    SQL

    user_stats.first['num_likes'] / user_stats.first['num_questions']
  end
end
