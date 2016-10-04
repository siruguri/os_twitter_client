require 'test_helper'
class RetweetRecordTest < ActiveSupport::TestCase
  test 'initialize' do
    r = RetweetRecord.new user_id: -1, tweet_id: -2
    r.save
  end
end
