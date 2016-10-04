require 'test_helper'

class TwitterProfileTest < ActiveSupport::TestCase
  test 'tweets_count default is 0' do
    t = TwitterProfile.new(handle: 'handle_x', twitter_id: 12345)

    assert_difference('ProfileStat.count', 1) do
      t.save
    end
    assert_equal 0, t.tweets_count
  end

  test '#friends' do
    follower = twitter_profiles(:twitter_profile_1)
    assert_equal GraphConnection.where('follower_id = ?', follower.id).count,
                 follower.friends.count
  end
end
