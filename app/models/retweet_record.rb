class RetweetRecord
  include Mongoid::Document
  include Mongoid::Extensions::Time
  include Mongoid::Indexable

  field :tweet_id, type: Integer
  field :user_id, type: Integer
  
  index({user_id: 1})
  index({tweet_id: 1})
end
