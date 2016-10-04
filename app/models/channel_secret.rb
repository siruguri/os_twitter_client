class ChannelSecret < ActiveRecord::Base
  belongs_to :user
  serialize :secrets_hash, Hash
end
