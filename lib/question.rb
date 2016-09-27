require_relative 'questions_db.rb'
require_relative 'reply'
require_relative 'user'
require_relative 'question_follow'

class Question
  attr_accessor :title, :body, :user_id

  def self.find_by_author_id(author_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE user_id = ?;
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    author = QuestionDBConnection.instance.execute(<<-SQL, @user_id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    User.new(author.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

end
