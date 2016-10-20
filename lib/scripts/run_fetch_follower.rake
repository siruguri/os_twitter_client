namespace :general do
  namespace :fetch_follower_job do
    u = User.first; t = u.latest_token_hash; c = TwitterClientWrapper.new({token: t}); asp = TwitterProfile.find 117
    cursor = TwitterRequestRecord.where(handle: 'aspirationtech', request_type: 'follower_ids').
             order(created_at: :desc).first.cursor
                                                                                                        
    c.rate_limited { fetch_followers!(asp, pagination: false, cursor: cursor) }
  end
end
