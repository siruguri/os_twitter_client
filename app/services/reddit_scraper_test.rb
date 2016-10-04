require 'test_helper'
require 'webmock/minitest'

class RedditScraperTest < ActiveSupport::TestCase
  describe 'all tests' do
    before do
      @test_obj = Scrapers::RedditScraper.new
      stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
        with(query: hash_including({count: '25'})).
        to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-2.html')).readlines.join(''))

      stub_request(:get, 'http://www.reddit.com/user/ssiruguri/').
        to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-1.html')).readlines.join(''))

      stub_request(:get, 'http://www.reddit.com/user/errorpage/').
        to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'reddit-page-1-error.html')).readlines.join(''))

      stub_request(:get, 'http://www.reddit.com/user/hellobellomello/').
        to_return(body: '', status: 404)
    end
  
    it 'valid username works' do
      payload = @test_obj.user_info(:ssiruguri)

      assert payload.respond_to? :each

      payload.each do |i|
        assert_equal Array, i.class
        assert_equal 2, i.size
      end
      
      assert (payload[:submitted_links] == 41), "Failed to find 41 submitted links, found #{payload[:submitted_links]}"

      assert_equal 5, payload[:subreddit_counts]['nonprofit.']
      assert payload.extracted?
    end
  
    it 'invalid username does not work' do
      assert_equal nil, @test_obj.user_info(:hellobellomello)
    end

    it 'unparseable page fails gracefully' do
      payload = @test_obj.user_info(:errorpage)
      assert !(payload.extracted?), "Payload does have data: #{payload.keys} but it shouldn't"

      assert_match /linklisting.*thing/, payload.failed_css
    end
  end
end

