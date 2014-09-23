class Document < CouchRest::Model::Base
  belongs_to :user
  belongs_to :question
  
  property :reason, String
  
  design do
    view :by_user_id
    view :by_question_id
  end

end
