class Experiment < CouchRest::Model::Base
  property :name, String
  property :description, String
  property :current_question_num, Integer
  property :max_annotations, Integer
  timestamps!
  
  design do 
    view :by_name
  end
end
