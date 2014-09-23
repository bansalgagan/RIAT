module ApplicationHelper
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def get_question_by_id(question_id)
    question = Question.get(question_id) or not_found
    return question
  end
  
  def get_question_by_num(question_num)
    if question_num < 1 || question_num > Question.all.count
      not_found
    else  
      question = Question.all.skip(question_num - 1).first or not_found
      return question
    end
  end
  
  def get_question_sentence(question)
    doc_name = question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = question.args[0]
    sent_num = arg["sent_idx"]
    current_sentence = doc_sentences[sent_num] or not_found
    return current_sentence
  end
  
  def highlight(sentence, question)
    str_array = sentence.split("\s");
    new_string = ""
    for i in 0..str_array.length-1
      if i>=question.args[0]["sent_tok_span"][0] && i<question.args[0]["sent_tok_span"][1]
        new_string = new_string + " <span class='arg1'>"+str_array[i]+"</span>"
      elsif i>=question.args[1]["sent_tok_span"][0] && i<question.args[1]["sent_tok_span"][1]
        new_string = new_string + " <span class='arg2'>" + str_array[i]+"</span>"
      else
        new_string = new_string + " " + str_array[i]
      end
    end
    return new_string.html_safe
  end
  
  def get_num_annotations(question_id)
    count = Annotation.by_question_id.key(question_id).count
    return count
  end
  
  def get_num_annotations_by_user(user)
    return Annotation.by_user_id.key(user.id).count
  end
    
  def has_attempted_question(question_num, user)
    question = get_question_by_num(question_num)
    annotations = Annotation.by_question_id.key(question.id).all
    if annotations.nil?
      return false
    end
    annotations.each do |anno|
      if anno.user_id == user.id
        return true
      end
    end
    return false
  end
  
  def get_num_annotations_by_src(question_num, src)
    question = get_question_by_num(question_num)
    annotations = Annotation.by_question_id(question.id).all
    count = annotations.count
    annotations.each do |anno|
      if anno.src != src
        count = count - 1
      end
    end  
    return count
  end
  
  def get_num_annotations_by_exp(question_num, experiment_name)
    question = get_question_by_num(question_num)
    exp = get_exp_by_name(experiment_name) 
    count = Annotation.by_question_id_and_experiment_id.key([question.id,exp.id]).all.count
    return count
  end
  
  def get_exp_by_name(experiment_name)
    exp = Experiment.by_name.key(experiment_name).first or not_found
    return exp
  end
  
  def get_exp_max_annotations(experiment_name)
    exp = get_exp_by_name(experiment_name)
    max_annotations = exp.max_annotations or not_found
    return max_annotations
  end
  
  def get_exp_question_num(experiment_name)
    exp = get_exp_by_name(experiment_name)
    question_num = exp.current_question_num.to_i or not_found
    return question_num
  end
  
  def increment_exp_question_index(experiment_name)
    question_num = get_exp_question_num(experiment_name)
    annotations = get_num_annotations_by_exp(question_num, experiment_name)
    max_annotations = get_exp_max_annotations(experiment_name)
    new_offset = question_num
    while annotations >= max_annotations
      new_offset = new_offset + 1
      annotations = get_num_annotations_by_exp(new_offset, experiment_name)
      puts "=============="
      puts new_offset
      puts annotations   
    end
    if new_offset != question_num
      exp = get_exp_by_name(experiment_name)
      exp.update_attributes(:current_question_num => new_offset)
    end
    return new_offset
  end
end
