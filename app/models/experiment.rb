class Experiment < CouchRest::Model::Base
  property :name, String
  property :description, String
  property :current_question_num, Integer
  property :max_annotations, Integer
  property :max_calib_annotations, Integer
  property :max_coll_annotations, Integer
  property :current_calib_question_num, Integer
  property :current_coll_question_num, Integer
  timestamps!
  
  design do 
    view :by_name
  end
end
