class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show, :edit, :update, :destroy]

  # GET /quizzes
  # GET /quizzes.json
  def index
    @quizzes = Quiz.all.group_by {|quiz| quiz.created_at.to_date}
  end

  # GET /quizzes/1
  # GET /quizzes/1.json
  def show
    send_data @quiz.data, :filename => @quiz.name, :type => 'application/pdf', :disposition => "inline"
  end

  # GET /quizzes/new
  def new
    @quiz = Quiz.new
    @subjects = Subject.order("name").all
  end

  # GET /quizzes/1/edit
  def edit
  end

  # POST /quizzes
  # POST /quizzes.json
  def create
    @subjects = Subject.all
    @counts = Hash.new
    @subjects.each do |subject|
      @counts[subject.id] = params[subject.id.to_s].to_i if params[subject.id.to_s].to_i > 0
    end
    vars = params[:vars].to_i
    vars.times {|i| gen_var(i, @counts)}
    respond_to do |format|
        format.html { redirect_to quizzes_path, notice: 'Quiz was successfully created.' }
    end
  end

  # PATCH/PUT /quizzes/1
  # PATCH/PUT /quizzes/1.json
  def update
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to @quiz, notice: 'Quiz was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1
  # DELETE /quizzes/1.json
  def destroy
    @quiz.destroy
    respond_to do |format|
      format.html { redirect_to quizzes_url }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quiz
      @quiz = Quiz.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quiz_params
      params.require(:quiz).permit(:name, :data)
    end
    
    def gen_var(i, counts)
      @quiz = Quiz.new(name: quiz_params[:name] + " " + t(:var, :scope => :quiz) + " " + "%02d" % (i + 1))
      @questions = Array.new
      @answers = Hash.new
      counts.each do |key, value|
	@questions << Subject.find(key).questions.shuffle.first(value)
      end
      pdf = Prawn::Document.new(page_size: "A4", :info => {
	:Title => @quiz.name + " " + t(:var, :scope => :quiz) + " " + "%02d" % (i + 1),
	:Author => "Vladimir Markovnin",
	:Subject => "IPO ISMA",
	:Creator => "ISMA",
	:Producer => "Prawn",
	:CreationDate => Time.now }
	)
      pdf.font_families.update("Ubuntu" => {
	:normal => "#{Rails.root}/vendor/fonts/Ubuntu-R.ttf",
	:italic => "#{Rails.root}/vendor/fonts/Ubuntu-RI.ttf",
	:bold => "#{Rails.root}/vendor/fonts/Ubuntu-B.ttf"
					  })
      pdf.font "Ubuntu"
      pdf.text @quiz.name, :style => :bold, :size => 18
      pdf.move_down 10
      n = 0
      @questions.each do |question|
	pdf.text question[0].subject.name, :style => :bold, :size => 16
	pdf.move_down 10
	question.each do |q|
	  n += 1
	  pdf.text "%03d" % n + ". " + q.text, :style => :italic
	  pdf.move_down 10
	  m = 0
	  q.answers.shuffle.each do |answer|
	    m += 1
	    @answers[n] = m if answer.right?
	    pdf.text m.to_s + ". " + answer.text, :indent_paragraphs => 15
	    pdf.move_down 10
	  end
	end
      end
      string = t(:page, :scope => :quiz) + " <page> " + t(:of, :scope => :quiz) + " <total>"
      options = {:at => [pdf.bounds.right - 150, 0], :width => 150, :align => :center, :start_count_at => 1}
      pdf.number_pages string, options

      pdf.start_new_page
      pdf.text t(:answers, :scope => :quiz), :style => :bold, :size => 18
      pdf.column_box([0, pdf.cursor], :columns => 2, :width => pdf.bounds.width) do
	@answers.each do |key, value|
	    pdf.text t(:question, :scope => :quiz)+ ": " + "%03d" % key + ' - ' + value.to_s
	end
      end
      @quiz.data = pdf.render
      @quiz.save
    end
end
