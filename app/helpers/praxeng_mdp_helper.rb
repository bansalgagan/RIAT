module PraxengMdpHelper

  def create_new_user
    session_id = get_session_id or not_found
    ip = request.remote_ip or not_found
    exp = get_experiment_by_name(PRAXENG_EXPERIMENT)
    if session_id.nil? || ip.nil?
      not_found
    end
    user = User.new(:name => session_id, :experiment=>exp, :num_question => 0, :num_correct => 0.0, :c => 0, :u_now_question => -0.6, :ip_address => ip, :calib_question_num => 1, :coll_question_num => 1)
    user.save
    return user
  end
  
  def get_u_now_question_for_user(user)
    val = user.u_now_question or not_found
    return val
  end
  
  def get_num_coll_question
    user = get_current_user
    val = user.c or not_found
    return val
  end
  
  def get_calib_question_num
    user = get_current_user
    val = user.calib_question_num or not_found
    return val
  end
  
  def get_coll_question_num
    user = get_current_user
    val = user.coll_question_num or not_found
    return val
  end

  def get_next_question_for_user
    puts "HHJHJSDSHGDHGSDHDSGSDH"
    totalQuestions = get_num_question
    a = get_num_correct
    
    c = get_num_coll_question
    b = totalQuestions - a - c
    
    
    u_past_question = get_u_now_question_for_user(get_current_user)
    puts totalQuestions,a+1, b+1, c, u_past_question, 5
    u_total, u_now_question, action = compute_utility(a+1, b+1, c, u_past_question, 5)
    puts u_total, u_now_question, action
    user = get_current_user
    user.update_attributes(:u_now_question => u_now_question)

    if action == 'calib'
      exp_calib_question_num = increment_experiment_calib_question_num(PRAXENG_MDP_EXPERIMENT)
      user_calib_question_num = get_calib_question_num
      
      if user_calib_question_num > exp_calib_question_num
        question = get_calib_question_by_num(user_calib_question_num)
        # user.update_attributes(:calib_question_num => user_calib_question_num+1)
        return 'calib', question
      else
        question = get_calib_question_by_num(exp_calib_question_num)
        # user.update_attributes(:calib_question_num => exp_calib_question_num)
        return 'calib' ,question
      end 
    elsif action == 'coll'
      exp_coll_question_num = increment_experiment_coll_question_num(PRAXENG_MDP_EXPERIMENT)
      user_coll_question_num = get_coll_question_num
      
      if user_coll_question_num > exp_coll_question_num
        question = get_coll_question_by_num(user_coll_question_num)
        # user.update_attributes(:coll_question_num => user_coll_question_num+1)
        return 'coll', question
      else
        question = get_coll_question_by_num(exp_coll_question_num)
        user.update_attributes(:coll_question_num => exp_coll_question_num)
        return 'coll', question
      end 
      not_found
    end
  end
  
  def get_calib_question_for_user
    exp_calib_question_num = increment_experiment_calib_question_num(PRAXENG_MDP_EXPERIMENT)
    question = get_calib_question_by_num(exp_calib_question_num)
    return 'calib', question
  end
  
  
  def get_calib_question_by_num(question_num)
    if question_num < 1 || question_num > Question.by_calibration.key(1).all.count
      not_found
    else  
      #question = Question.by_calibration.key(1).all.skip(question_num - 1).first or not_found
      question = Question.by_calibration.key(1).all[question_num] or not_found
      #question = calib_questions[question_num] or not_found
      return question
    end
  end 
  
  def get_coll_question_by_num(question_num)
    if question_num < 1 || question_num > Question.by_calibration.key(0).all.count
      not_found
    else  
      question = Question.by_calibration.key(0).all[question_num] or not_found
      return question
    end
  end 
  
  def get_experiment_calib_question_num(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    question_num = exp.current_calib_question_num.to_i or not_found
    return question_num
  end
  
  def get_experiment_coll_question_num(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    question_num = exp.current_coll_question_num.to_i or not_found
    return question_num
  end
  
  def get_experiment_max_calib_annotations(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    max_annotations = exp.max_calib_annotations or not_found
    return max_annotations
  end
  
  def get_experiment_max_coll_annotations(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    max_annotations = exp.max_coll_annotations or not_found
    return max_annotations
  end
  
  def increment_experiment_calib_question_num(experiment_name)
    question_num = get_experiment_calib_question_num(experiment_name)
    annotations = get_num_annotations_by_question_num_and_experiment_name(question_num, experiment_name)
    max_annotations = get_experiment_max_calib_annotations(experiment_name)
    new_offset = question_num
    while annotations >= max_annotations
      new_offset = new_offset + 1
      annotations = get_num_annotations_by_question_num_and_experiment_name(new_offset, experiment_name)
    end
    if new_offset != question_num
      exp = get_experiment_by_name(experiment_name)
      exp.update_attributes(:current_calib_question_num => new_offset)
    end
    return new_offset
  end
  
  
  def save_user_response
    option = params[:option]
    user_response = params[:response]
    question = get_object(params[:question_id])
    user = get_current_user or not_found
    is_calib = question.calibration or not_found
    if is_calib != 1
      num_coll = get_num_coll_question
      num_coll += 1
      coll_question_num = user.coll_question_num
      coll_question_num += 1
      user.update_attributes(:c => num_coll, :coll_question_num => coll_question_num)
    else
      calib_question = user.calib_question_num
      calib_question += 1
      user.update_attributes(:calib_question_num => calib_question)      
    end
        
    
    if !option.nil? && !question.nil?     
      if option != "skip"
         annotation = nil
         exp = get_experiment_by_name(PRAXENG_MDP_EXPERIMENT)
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
        if is_calib == 1
          update_user_score(score)
        end
        annotation.save  
        return annotation.id
      end
    end
  end

  def increment_experiment_coll_question_num(experiment_name)
    question_num = get_experiment_coll_question_num(experiment_name)
    annotations = get_num_annotations_by_question_num_and_experiment_name(question_num, experiment_name)
    max_annotations = get_experiment_max_coll_annotations(experiment_name)
    new_offset = question_num
    while annotations >= max_annotations
      new_offset = new_offset + 1
      annotations = get_num_annotations_by_question_num_and_experiment_name(new_offset, experiment_name)
    end
    if new_offset != question_num
      exp = get_experiment_by_name(experiment_name)
      exp.update_attributes(:current_coll_question_num => new_offset)
    end
    return new_offset
  end


  def eig(a,b,n)
    r1 = RSRuby.instance
    text = "(log(#{n}) - (#{b}/(#{a}+#{b}))*log(#{n}-1) - digamma(#{a}+#{b}+1) + (#{a}*digamma(#{a}+1)+#{b}*digamma(#{b}+1))/(#{a}+#{b}))"
    val = r1.eval(r1.parse(:text => text))
    return val
  end
  
  def sig(a,b,n)
    puts a,b,n
    r = RSRuby.instance
    text = "integrate(function(q) {((-log(#{n}) + q*log(q) + (1-q)*log((1-q)/(#{n}-1)))^2)*((q^#{a})*((1-q)^#{b})*(1/beta(#{a},#{b})))}, lower = 0, upper = 1)$val"
    integ = r.eval(r.parse(:text => text))
    
    eig1 = eig(a,b,n)
    val = integ - (eig1)**2
    if val > 0
      return Math.sqrt(val)
    else
      return 0.0
    end
  end
  
  def digam(x)
    r = RSRuby.instance
    val = r.digamma(x)
    return val
  end
    

  def u_now_question(a,b,n)
    return eig(a,b,n)- sig(a,b,n)
  end
  
  def compute_utility(a,b,c,u_past_question,l)
    r = RSRuby.instance
    return 0,0,'none'
  end

  def compute_utility(a,b,c,u_past_question,l)
    if l < 0
      return 0, 0, 'none'
    end
    n = 4;
    gamma = 0.5
    eig1 = eig(a,b,n)
    sig1 = sig(a,b,n)

    u_now_question  = eig1 - sig1
    u_now_coll = u_now_question
    u_future_coll, temp1, temp2 = compute_utility(a,b,c+1, u_now_question, l-1)
    # u_future_coll = compute_utility(a,b,c+1, u_now_question, l-1)
    u_coll = gamma*(u_now_coll + u_future_coll)

    q = (a+1)/(a+b+n)
    u_now_corr_question = eig(a+1, b, n) - sig(a+1, b, n)
    u_now_corr_calib = c*(u_now_corr_question - u_past_question)
    u_fut_corr_calib, temp1, temp2 = compute_utility(a+1, b, c, u_now_corr_question, l-1)
    #u_fut_corr_calib = compute_utility(a+1, b, c, u_now_corr_question, l-1)

    u_now_incorr_question = eig(a, b+1, n) - sig(a, b+1, n)
    u_now_incorr_calib = c*(u_now_incorr_question - u_past_question)
    u_fut_incorr_calib, temp1, temp2 = compute_utility(a, b+1, c, u_now_incorr_question, l-1)
    #u_fut_incorr_calib = compute_utility(a, b+1, c, u_now_incorr_question, l-1)
    u_calib = gamma*(q*(u_fut_corr_calib + u_now_corr_calib) + (1-q)*(u_fut_incorr_calib + u_now_incorr_calib))

    u_total = 0
    if u_calib > u_coll
      action = 'calib'
      u_total = u_calib
    else
      action = 'coll'
      u_total = u_coll
    end
    return u_total, u_now_question, action
  end

end
