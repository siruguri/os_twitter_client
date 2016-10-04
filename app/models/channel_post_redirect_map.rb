class ChannelPostRedirectMap < ActiveRecord::Base
  belongs_to :channel_post
  belongs_to :redirect_map
end
