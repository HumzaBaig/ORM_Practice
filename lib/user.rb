require_relative 'question_db.rb'

class User
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

end
