module PraxengHelper
  
  def is_new_user?
    user = get_current_user
    if  user.nil?
      return true
    else
      return false
    end
  end
    
  def get_user_percentile(score)
    users = get_users_by_experiment_name(PRAXENG_EXPERIMENT)
    count = users.count
    lesser_users = 0
    users.each do |user|
      if(user.num_correct < score)
        count+=1
      end
    end
    return (lesser_users*100)/count
  end
  
  def create_new_user
    session_id = get_session_id or not_found
    ip = request.remote_ip or not_found
    exp = get_experiment_by_name(PRAXENG_EXPERIMENT)
    if session_id.nil? || ip.nil?
      not_found
    end
    user = User.new(:name => session_id, :experiment=>exp, :num_question => 0, :num_correct => 0.0, :ip_address => ip)
    user.save
    return user
  end
  
  def update_user_score(score)
    user = get_current_user
    prev_score = user.num_correct
    prev_score += score
    user.update_attributes(:num_correct => prev_score)
  end
  
  def get_session_id
    session["init"] = true
    session = request.session_options[:id] or not_found
    return session
  end
  
  def get_ip_address
     ip = request.remote_ip or not_found
     return ip
  end
  
  def get_current_user
    #user = User.by_name.key(get_session_id).first
    user = User.by_ip_address.key(get_ip_address).first
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
    question = get_object(params[:question_id])
    user = get_current_user or not_found
    
    if !option.nil? && !question.nil?     
      if option != "skip"
         annotation = nil
         exp = get_experiment_by_name(PRAXENG_EXPERIMENT)
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
        score, message = evaluate_user_response(question, annotation)
        update_user_score(score)
        annotation.save
        return annotation.id
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
    distribution["None of these"] = 0
    
    annotations.each do |anno|
      if anno.response.length == 0
        distribution["None of these"] += 1
      else
        anno.response.each do |resp|
          distribution[resp] += 1
        end
      end
    end
    return distribution
  end
  
  def get_answer_distribution_and_exclude(question, annotation)
    annotations = Annotation.by_question_id.key(question.id).all
    num_annotations = annotations.count
    distribution = {}
    question.answers.each do |opt|
      distribution[opt] = 0
    end
    distribution["None of these"] = 0
    count = 0
    annotations.each do |anno|
      if anno.id == annotation.id
        next
      end
      count += 1
      if anno.response.length == 0
        distribution["None of these"] += 1
      else
        anno.response.each do |resp|
          distribution[resp] += 1
        end
      end
    end
    
    distribution.each do |key, value|
      distribution[key] = (distribution[key]*100)/count
    end
    
    return distribution
  end
  
  def get_first_question_for_user
    question_num = increment_experiment_question_num(PRAXENG_EXPERIMENT)
    question = get_question_by_num(question_num)
    return question
  end
    
  def get_next_question_for_user
    question_num = increment_experiment_question_num(PRAXENG_EXPERIMENT)
    question_num += get_num_question
    question = get_question_by_num(question_num)
    return question
  end
  
  def get_question_for_user
    question_num = increment_experiment_question_num(PRAXENG_EXPERIMENT)
    user = get_current_user
    while user_has_attempted_question?(user, question_num)
      question_num += 1
    end
    question = get_question_by_num(question_num)
    return question
  end
  
  def get_user_by_id(user_id)
    user = User.get(user_id)
    return user
  end
  
  def save_user_challenge
    user_id = params[:user_id]
    question_id = params[:question_id]
    user_reason = params[:challenge_reason]
    user = get_user_by_id(user_id) or not_found
    question = get_object(question_id) or not_found
    
    challenge = Challenge.new(:user => user, :question => question, :reason => user_reason)
    challenge.save
  end
  
  def get_annotation_by_id(annotation_id)
    annotation = Annotation.get(annotation_id)
    return annotation
  end
    
  def compute_gold_full_by_majority_and_exclude(question, annotation)
    distribution = get_answer_distribution_and_exclude(question, annotation)
    gold = []
    distribution.each do |key, value|
      if (value) >= 50
        gold.push(key)
      end
    end
    return gold
  end
  
  def evaluate_user_response(question, annotation)
    # annotation = get_annotation_by_id(annotation_id)
    perfect_score_messages = ["Great! You are correct!", "You are correct! Keep practicing!"]
    new_answer_message = "Thanks! We do not know the answer to this question yet."
    
    if !annotation.nil?
      gold = compute_gold_full_by_majority_and_exclude(question, annotation)

      # If I don't know the answer
      if gold == []
        return 1, new_answer_message
      end
      
      #If I know the answer
      user_response = annotation.response
      response = []
      user_response.each do |resp|
        response.push(resp)
      end
      if user_response == []
        response.push("None of these")
      end
          
      user_unattempted = []
      user_incorrect = []

      score = 0.0
      if gold.include?("None of these") && response.include?("None of these")
        score = 1.0
        return score, perfect_score_messages.sample
      elsif gold.include?("None of these") && !response.include?("None of these")
        return score, "Oops! We think None of these is the correct answer"
      end

      question.answers.each do |ans|
        if gold.include?(ans) && response.include?(ans)
          score += 0.25
        elsif !gold.include?(ans) && !response.include?(ans)
          score += 0.25
        elsif gold.include?(ans) && !response.include?(ans)
          user_unattempted.push(ans["relation_display_name"])
        else
          user_incorrect.push(ans["relation_display_name"])
        end
      end
      
      message = "Thanks, but we think "
      if  user_unattempted.size != 0
        if user_unattempted.size == 1
          message += user_unattempted[0].to_s+ " is also correct"
        else
          for i in 0..(user_unattempted.size-1)
            if (i == (user_unattempted.size-1))
              message += user_unattempted[i].to_s + " are also correct"
            else
              message += user_unattempted[i].to_s + ", "
            end
          end
        end 
        return score, message
      end
      
      message = "Oops, we think "
      if  user_incorrect.size != 0
        if user_incorrect.size == 1
          message += user_incorrect[0].to_s+ " is wrong"
        else
          for i in 0..(user_incorrect.size-1)
            if i == (user_incorrect.size-1)
              message += user_incorrect[i].to_s + " are wrong"
            else
              message += user_incorrect[i].to_s + ", "
            end
          end
        end
         return score, message
      end
      
      return score, perfect_score_messages.sample
    end
  end  
end
