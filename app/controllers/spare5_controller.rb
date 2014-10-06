class Spare5Controller < ApplicationController
  include ApplicationHelper
  include Spare5Helper
  
  layout 'spare5'

  def spare5job
    # question_id = params[:id]
    # @question = get_object(question_id)
    @question = get_question_by_num(1)
    @sentence = get_question_sentence(@question)
    @job_id = get_question_spare5_job_id(@question)
    #@next_page = "http://sparefive-staging.herokuapp.com/partner/v1/jobs/"+@job_id+"/results"
    @next_page = "/callback"
  end
  
  def callback
    save_user_response
  end
end
