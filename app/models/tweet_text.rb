class TweetText
  include Mongoid::Document
  include Mongoid::Extensions::Time
  include Mongoid::Indexable

  field :tweet_id, type: Integer
  field :full_text, type: String
  field :retweeted_status, type: Boolean
  field :retweeted_text, type: String
  
  index({tweet_id: 1}, {unique: true})
end
