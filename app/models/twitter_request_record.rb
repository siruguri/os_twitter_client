class TwitterRequestRecord < ActiveRecord::Base
  belongs_to :user, foreign_key: 'handle', primary_key: 'handle'
end
