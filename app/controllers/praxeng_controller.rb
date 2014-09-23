class PraxengController < ApplicationController
  layout 'praxeng_basic'
  include ApplicationHelper
  include PraxengHelper
  
  def landing_page
    @question = get_first_question_for_user
    @sentence = get_question_sentence(@question)
    @next_page = "/save_response"
    if is_new_user?
      @num_question = 0
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
    @annotation_id = params[:annotation_id]
  end
  
  def practice  
    @num_correct = get_num_correct
    @num_question = get_num_question
    if @num_question%10 == 0 && params[:continue].nil?
      render "share"
    end
    if !params[:question_id].nil?
      @prev_question = get_question_by_id(params[:question_id])
      @prev_sentence = get_question_sentence(@prev_question)
      evaluation = evaluate_user_response2(@prev_question, get_annotation_by_id(params[:annotation_id]))
      if !evaluation.nil?
        score = evaluation[0]
        # update_user_score(score)
        @message = evaluation
      end
      @num_annotations = get_num_annotations(params[:question_id])
      @distribution = get_answer_distribution_and_exclude(@prev_question, get_annotation_by_id(params[:annotation_id]))
    end
    @question = get_next_question_for_user
    @sentence = get_question_sentence(@question)
    @next_page = "/save_response"
  end
  
  def save_response
    annotation_id = save_user_response
    redirect_to :controller => "praxeng", :action => "practice", :question_id => params[:question_id], :annotation_id => annotation_id
  end
  
  def save_response_consent
    user = get_current_user
    if user.nil?
        create_new_user
    end 
    annotation_id = save_user_response
    redirect_to :controller => "praxeng", :action => "consent", :question_id => params[:question_id], :annotation_id => annotation_id
  end
  
  def save_challenge
    save_user_challenge
  end
  
  def privacy
  end
  
  def about
  end
end
