module Spare5Helper

  def get_question_spare5_job_id(question)
    id = question.spare5_job_id or not_found
    return id
  end
  
  # def save_user_response
  #   option = params[:option]
  #   user_response = params[:response]
  #   question = get_object(params[:question_id])
  #   user = get_current_user or not_found
  #
  #   if !option.nil? && !question.nil?
  #     if option != "skip"
  #        annotation = nil
  #        exp = get_experiment_by_name(SPARE5_EXPERIMENT)
  #       if option == "none" || user_response.nil?
  #         annotation = Annotation.new(:question => question, :user => user, :response => [], :experiment => exp)
  #       else
  #         response = []
  #         user_response.each do |key, value|
  #           obj = question.answers[value.to_i]
  #           response.push(obj)
  #         end
  #         annotation = Annotation.new(:question => question, :user => user, :response => response, :experiment => exp)
  #       end
  #       score, message = evaluate_user_response(question, annotation)
  #       update_user_score(score)
  #       annotation.save
  #       return annotation.id
  #     end
  #   end
  # end
  
end
