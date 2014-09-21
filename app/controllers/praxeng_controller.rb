class PraxengController < ApplicationController
  layout 'praxeng_basic'
  include ApplicationHelper
  include PraxengHelper
  
  def landing_page
    @question = get_first_question_for_user
    @sentence = get_question_sentence(@question)
    @next_page = "/save_response"
    if is_new_user?
      @next_page = "/save_response_consent"
    else
      @question = get_question_for_user
      @sentence = get_question_sentence(@question)
      @next_page = "/save_response"
      redirect_to "/practice"
    end
  end
  
  def consent
    @question_id = params[:question_id]
  end
  
  def practice  
    @num_correct = get_num_correct
    @num_question = get_num_question
    if !params[:question_id].nil?
      @distribution = get_answer_distribution(get_question_by_id(params[:question_id]))
    end
    @question = get_next_question_for_user
    @sentence = get_question_sentence(@question)
    @next_page = "/save_response"
  end
  
  def save_response
    save_user_response
    redirect_to :controller => "praxeng", :action => "practice", :question_id => params[:question_id]
  end
  
  def save_response_consent
    user = get_current_user
    if user.nil?
        create_new_user
    end 
    save_user_response
    redirect_to :controller => "praxeng", :action => "consent", :question_id => params[:question_id]
  end
  
  def privacy
  end
  
  def about
  end
end
