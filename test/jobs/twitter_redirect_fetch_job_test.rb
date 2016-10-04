require 'test_helper'

class TwitterRedirectFetchJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    set_net_stubs
  end
  
  test 'exceptions raised cause flag to be set' do
    assert_equal nil, web_articles(:web_article_1).fetch_failed
    ReadabilityParserWrapper.any_instance.stubs(:parse).raises Errno::ECONNREFUSED

    assert_enqueued_with(job: TwitterRedirectFetchJob) do
      TwitterRedirectFetchJob.perform_now [web_articles(:web_article_1), web_articles(:web_article_2)]
    end
    
    assert web_articles(:web_article_1).fetch_failed
  end

  test 't.co redirects work' do
    TwitterRedirectFetchJob.perform_now [web_articles(:t_co_1)]
  end
  
  test 'using a string works' do
    assert_equal nil, web_articles(:reanalysis_1).body
    TwitterRedirectFetchJob.perform_now [web_articles(:reanalysis_1).original_url]
    refute_equal nil, web_articles(:reanalysis_1).reload.body
  end

  test 'readability failure is handled' do
    ReadabilityParserWrapper.any_instance.stubs(:parse).returns(ReadabilityParserWrapper::ReadabilityBody.new(content: {failure_message: 'failed'}, url: 'url'))

    TwitterRedirectFetchJob.perform_now [web_articles(:wa_uncrawled)]
    assert_equal 'failed', web_articles(:wa_uncrawled).body
  end
end
