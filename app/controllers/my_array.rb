class MyArray < Array
    def insert_in_db(data, subject_id)
      @data = data
      @subject_id = subject_id
	@data.each do |s|
	  if s[0][0].to_i == 1
	    @question = Question.new
	    @question.subject_id = @subject_id
	    @question.text = s[1].strip
	    @question.save
	  else
	    @answer = Answer.new
	    @answer.question_id = @question.id
	    @answer.text = s[1].strip
	    @answer.right = true if s[2].to_i == 1
	    @answer.save
	  end
	end
    end
    handle_asynchronously :insert_in_db, :run_at => Proc.new { 5.minutes.from_now }
end