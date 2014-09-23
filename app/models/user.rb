class User < CouchRest::Model::Base
  belongs_to :experiment
  
  property :src, String #to enable A/B testing
  property :name, String #session id for now
  property :email, String
  property :password, String 
  property :num_question, Integer
  property :num_correct, Float
  property :ip_address, String
  property :confirm_codes, []
  
  timestamps!
  
  design do
    view :by_name
    view :by_src
    view :by_ip_address
  end 
end
