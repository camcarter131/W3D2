require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
    attr_accessor :id , :fname, :lname

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_name(fname,lname)
        find_user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT * 
            FROM users
            WHERE fname = ? AND lname = ?
        SQL
        User.new(find_user.first)
    end

    def self.find_by_id(id)
        find_user = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?
        SQL
        Question.new(find_user.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def fname 
        @fname
    end

    def authored_questions
        Question.find_by_author_id(@id)
    end

    def authored_replies 
        Reply.find_by_user_id(@id)
    end 

    def followed_questions 
        QuestionFollow.followed_questions_for_user_id(@id) 
    end 
end

class Question
    attr_accessor :id,:title, :body, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end

    def self.find_by_author_id(author_id)
        find_author = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT * 
            FROM questions
            WHERE user_id = ?
        SQL
        answer = find_author.map { |q| Question.new(q) }
    end

    def self.find_by_id(id)
        find_question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT * 
            FROM questions
            WHERE id = ?
        SQL
        Question.new(find_question.first)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author 
        @user_id
    end 

    def replies 
        Reply.find_by_question_id(@id)
    end 

    def followers 
        QuestionFollow.followers_for_question_id(@id)
    end  
        
end

class Reply
    attr_accessor :id, :user_id, :body, :question_id, :parent_reply_id 
   def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_user_id(user_id)
        find_user_id = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT * 
            FROM replies
            WHERE user_id = ?
        SQL
        answer = find_user_id.map { |reply| Reply.new(reply) }
        
    end

    def self.find_by_question_id(question_id)
        find_question = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT * 
            FROM replies
            WHERE question_id = ?
        SQL
        answer = find_question.map { |reply| Reply.new(reply) }
    end

    def self.find_by_parent_id(parent_id)
        find_by_parent_id = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
            SELECT * 
            FROM replies
            WHERE parent_reply_id = ?
        SQL
        answer = find_by_parent_id .map { |reply| Reply.new(reply) }
    end 

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_reply_id = options['parent_reply_id']
    end

    def author 
        @user_id
    end 

    def question 
        @question_id 
    end 

    def parent_reply 
        @parent_reply_id
    end 

    def child_replies 
        Reply.find_by_parent_id(@id)
    end 
end

class QuestionFollow

    attr_accessor :user_id, :question_id
    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
        data.map { |datum| QuestionFollow.new(datum) }
    end

   def self.followed_questions_for_user_id(user_id)
        question_ids = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT qf.question_id 
            FROM users as u
            JOIN question_follows as qf
            ON u.id = qf.user_id
            WHERE u.id = ?
        SQL
        question_ids.map{|ques_id| Question.find_by_id(ques_id) }
    end

    def self.followers_for_question_id(question_id)
        user_ids = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT qf.user_id
            FROM questions as q
            JOIN question_follows as qf
            ON q.id = qf.question_id
            WHERE qf.question_id = ?
        SQL
        user_ids.map{|user_id| User.find_by_id(user_id) }
   
    end
 

    def initialize(options)  
        @user_id = options['user_id']
        @question_id = options['question_id']
    end


end