module PraxengHelper
   
  def is_new_user?
    user = get_current_user
    if  user.nil?
      return true
    else
      return false
    end
  end
  
  def create_new_user
    session_id = get_session_id
    ip = request.remote_ip
    if session_id.nil? || ip.nil?
      not_found
    end
    user = User.new(:name => session_id, :src => 'praxeng', :num_question => 0, :num_correct => 0, :ipaddress => ip)
    user.save
    return user
  end
  
  def get_session_id
    session["init"] = true
    session = request.session_options[:id] or not_found
    return session
  end
  
  def get_current_user
    user = User.by_name.key(get_session_id).first
    return user
  end
  
  def get_num_question
    user = get_current_user
    return get_num_annotations_by_user(user)
  end
  
  def get_num_correct
    user = get_current_user
    return user['num_correct']
  end
  
  def save_user_response
    option = params[:option]
    user_response = params[:response]
    question = get_question_by_id(params[:question_id])
    user = get_current_user or not_found
    
    if !option.nil? && !question.nil?     
      if option != "skip"
         annotation = nil
         exp = Experiment.by_name.key(PRAXENG_EXPERIMENT).first or not_found
        if option == "none" || user_response.nil?
          annotation = Annotation.new(:question => question, :user => user, :response => [], :experiment => exp)
        else
          response = []
          user_response.each do |key, value|
            obj = question.answers[value.to_i]
            response.push(obj)
          end
          annotation = Annotation.new(:question => question, :user => user, :response => response, :experiment => exp)
        end
        annotation.save
        
      end
    end
  end
  
  def get_answer_distribution(question)
    annotations = Annotation.by_question_id.key(question.id).all
    num_annotations = annotations.count
    distribution = {}
    question.answers.each do |opt|
      distribution[opt] = 0
    end
    distribution["none"] = 0
    
    annotations.each do |anno|
      if anno.response.length == 0
        distribution["none"] += 1
      else
        anno.response.each do |resp|
          distribution[resp] += 1
        end
      end
    end
    return distribution
  end
  
  def get_first_question_for_user
    question_num = increment_exp_question_index(PRAXENG_EXPERIMENT)
    question = get_question_by_num(question_num)
    return question
  end
    
  def get_next_question_for_user
    question_num = increment_exp_question_index(PRAXENG_EXPERIMENT)
    question_num += get_num_question
    question = get_question_by_num(question_num)
    return question
  end
  
  def get_question_for_user
    question_num = increment_exp_question_index(PRAXENG_EXPERIMENT)
    user = get_current_user
    while has_attempted_question(question_num, user)
      question_num += 1
    end
    question = get_question_by_num(question_num)
    return question
  end
  
end
