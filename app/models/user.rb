class User < CouchRest::Model::Base
  belongs_to :experiment #to enable A/B testing,
  
  # property :src, String #stores referer information
  property :name, String #session id for now
  property :email, String
  property :password, String 
  property :num_question, Integer
  property :num_correct, Float

  property :ip_address, String
  property :confirm_codes, []

  ###MDP
  property :calib_question_num, Integer
  property :coll_question_num, Integer
  property :u_now_question, Float
  property :c, Integer
  
  timestamps!
  
  design do
    view :by_name
    view :by_experiment_id
    # view :by_src
    view :by_ip_address
  end 
end
