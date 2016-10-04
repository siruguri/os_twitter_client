require 'test_helper'

class ChannelPostTest < ActiveSupport::TestCase
  def setup
    @c = ChannelPost.new(url: 'http://notatarget.google.com', message: 'mesg')
    @c.save
  end

  test 'New records have 0 post count' do
    assert_equal 0, @c.total_post_count
  end

  test 'New record creates a redirect map' do
    last_map = RedirectMap.order(created_at: :asc).last

    assert_equal @c.url, last_map.dest
  end
end
