require 'test_helper'
require 'webmock/minitest'

class AldailyScraperTest < ActiveSupport::TestCase
  def setup 
    @test_obj = Scrapers::AldailyScraper.new
  end
  
  test 'can return top 3 links' do
    stub_request(:get, 'http://www.aldaily.com/').
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'aldaily-page.html')).readlines.join(''))

    payload = @test_obj.payload

    assert_not_nil payload[:links]
    assert payload[:links].respond_to? :each
    assert_equal 3, payload[:links].size
  end
  
  test 'unparseable page fails gracefully' do
    stub_request(:get, 'http://www.aldaily.com/').
      to_return(body: open(File.join(Rails.root, 'test', 'fixtures', 'files', 'aldaily-page-error-1.html')).readlines.join(''))
    payload = @test_obj.payload

    assert_match /failure.*fail.*at\s/i, payload[:status]
  end
end

