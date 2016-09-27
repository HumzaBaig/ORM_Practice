require_relative 'question_db.rb'

class Reply
  attr_accessor :body, :parent_id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @parent_id = options['parent_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end
