module ApplicationHelper
  #-------------UNIVERSAL---------------------
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def get_object_id(object)
    if object.nil?
      not_found
    end
    return object.id
  end
  
  def get_object(object_id)
    # User is just used as proxy here
    obj = User.get(object_id) or not_found
    return obj
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
  
  #-------------ANNOTATION------------------------
  
  ##class getters  
  def get_annotation_question_id(annotation_id)
    anno = get_object(annotation_id)
    return anno.question_id
  end  
  
  def get_annotation_user_id(annotation_id)
    anno = get_object(annotation_id)
    return anno.user_id
  end
    
  def get_annotation_experiment_id(annotation_id)
    anno = get_object(annotation_id)
    return anno.experiment_id
  end
    
  def get_annotation_response(annotation_id)
    anno = get_object(annotation_id)
    return anno.response
  end
  
  ##class setter
  def save_annotation(user_id, question_id, experiment_id, response)
    user = get_object(user_id)
    question = get_object(question_id)
    experiment = get_object(question_id)
    anno = Annotation.new(:user=>user, :question=>question, :experiment=>experiment, :response=>response)
    anno.save
    return anno.id
  end
    
  ##class cummulative getters
  def get_annotations_by_question_id(question_id)
    annos = Annotation.by_question_id.key(question_id) or not_found
    return annos
  end

  def get_annotations_by_user_id(user_id)
    annos = Annotation.by_user_id.key(user_id) or not_found
    return annos
  end

  def get_annotations_by_user_id_and_question_id(user_id, question_id)
    annos = Annotation.by_user_id_and_question_id.key([user_id, question_id]) or not_found
    return annos
  end

  def get_annotations_by_question_id_and_experiment_id(question_id, experiment_id)
    annos = Annotation.by_question_id_and_experiment_id.key([question_id, experiment_id]) or not_found
    return annos
  end

  ##class cummulative count getters
  def get_num_annotations_by_question_id(question_id)
    annos = get_annotations_by_question_id(question_id)
    return annos.count
  end

  def get_num_annotations_by_user_id(user_id)
    annos = get_annotations_by_user_id(user_id)
    return annos.count
  end
  
  def get_num_annotations_by_user(user)
    annos = get_annotations_by_user_id(user.id)
    return annos.count
  end

  def get_num_annotations_by_user_id_and_question_id(user_id, question_id)
    annos = get_annotations_by_user_id_and_question_id(user_id, question_id)
    return annos.count
  end

  def get_num_annotations_by_question_id_and_experiment_id(question_id, experiment_id)
    annos = get_annotations_by_question_id_and_experiment_id(question_id, experiment_id)
    return annos.count
  end
  
  def get_num_annotations_by_question_num_and_experiment_name(question_num, experiment_name)
    question = get_question_by_num(question_num)
    exp = get_experiment_by_name(experiment_name) 
    count = get_num_annotations_by_question_id_and_experiment_id(question.id, exp.id)
    return count
  end
  #-------------CHALLENGE-------------------------
  
  #-------------DATASET---------------------------
  
  def get_dataset_by_name(name)
    dataset = Dataset.by_name.key(name).first or not_found
    return datset
  end

  #-------------DOCUMENT--------------------------
  
  def get_document_text(document)
    return document.text
  end
  
  def get_document_by_doc_name(doc_name)
    doc = Document.by_doc_name.key(doc_name).first or not_found
    return doc
  end
  #-------------EXPERIMENT------------------------
  
  def get_experiment_by_name(experiment_name)
    exp = Experiment.by_name.key(experiment_name).first or not_found
    return exp
  end
  
  def get_experiment_max_annotations(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    max_annotations = exp.max_annotations or not_found
    return max_annotations
  end
  
  def get_experiment_question_num(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    question_num = exp.current_question_num.to_i or not_found
    return question_num
  end
  
  def increment_experiment_question_num(experiment_name)
    question_num = get_experiment_question_num(experiment_name)
    annotations = get_num_annotations_by_question_num_and_experiment_name(question_num, experiment_name)
    max_annotations = get_experiment_max_annotations(experiment_name)
    new_offset = question_num
    while annotations >= max_annotations
      new_offset = new_offset + 1
      annotations = get_num_annotations_by_question_num_and_experiment_name(new_offset, experiment_name)
    end
    if new_offset != question_num
      exp = get_experiment_by_name(experiment_name)
      exp.update_attributes(:current_question_num => new_offset)
    end
    return new_offset
  end
   
  #-------------QUESTION--------------------------
  
  def get_question_by_num(question_num)
    if question_num < 1 || question_num > Question.all.count
      not_found
    else  
      question = Question.all.skip(question_num - 1).first or not_found
      return question
    end
  end 
  
  def get_question_doc_name(question_id)
    question = get_object(question_id)
    return question.doc_name
  end
  
  def get_question_sentence(question)
    doc_name = question.doc_name
    current_document = get_document_by_doc_name(doc_name)
    doc_text = get_document_text(current_document)
    doc_sentences = doc_text.split("\n")
    arg = question.args[0]
    sent_num = arg["sent_idx"]
    current_sentence = doc_sentences[sent_num] or not_found
    return current_sentence
  end
  
    
  #-------------USER------------------------------
  
  def get_users_by_experiment_name(experiment_name)
    exp = get_experiment_by_name(experiment_name)
    users = User.by_experiment_id.key(exp.id).all
    return users
  end
  
  def get_num_users_by_experiment_name(experiment_name)  
    users = get_users_by_experiment_name(experiment_name)
    return user_count.count
  end
   
  def user_has_attempted_question?(user, question_num)
    question = get_question_by_num(question_num)
    annotations = get_annotations_by_question_id(question.id)
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

end   