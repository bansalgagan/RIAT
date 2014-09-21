class Annotation < CouchRest::Model::Base
  belongs_to :question
  belongs_to :user
  belongs_to :experiment  

  property :response, []
  
  timestamps!
  
  design do
    view :by_question_id
    view :by_user_id
    view :by_user_id_and_question_id
    view :by_question_id_and_experiment_id
  end 
    
end
