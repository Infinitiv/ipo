  class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  skip_before_action :require_login, only: [:show, :index]
  
  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.paginate(:page => params[:page], :per_page => 30)
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
    @subjects = Subject.order("name").all
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    data = question_params[:file].read.force_encoding("UTF-8")
    data = convert_array(data)
    subject_id = question_params[:subject_id]
    insert_in_db(data, subject_id)
    respond_to do |format|
        format.html { redirect_to subjects_url, notice: 'Questions will successfully created :-)' }
        format.json { render action: 'index', status: :created, location: @questions }
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:subject_id, :text, :file)
    end
    
    def convert_array(data)
      a = Array.new
      data = data.split(/\n/)
      data.each do |s|
	a << s.split(/\t/)
      end
      return a
    end

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
    
end
