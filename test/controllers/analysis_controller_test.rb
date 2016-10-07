require 'test_helper'

class AnalysisControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper
  
  test 'routing works' do
    assert_routing({method: :post, path: "/document_analyses/execute_task"},
                   {controller: 'analysis', action: 'execute_task'})
    assert_routing "/document_analyses/task_page", {controller: 'analysis', action: 'task_page'}
  end

  test 'document universe creation' do
    assert_difference('DocumentUniverse.count', 1) do
      post :execute_task, params: {commit: 'Compute Document Universe'}
    end
  end

  test 'update profile stats' do
    # avoiding learning the SQL - fixtures shd set this to below #
    # - added leader and some other leader on 9/14/16
    # added just_followers_1 on 9/23
    no_stat_has_tweets_profile_count = 4
    old_stats_agg = profile_stats(:ps_1).stats_hash_v2[:retweet_aggregate]
    assert_difference('ProfileStat.count', no_stat_has_tweets_profile_count) do
      post :execute_task, params: {commit: 'Update Profile Stats'}
    end

    assert_equal old_stats_agg, profile_stats(:ps_1).reload.stats_hash_v2[:retweet_aggregate]
  end

  test 'reprocess all profiles' do
    assert_enqueued_with(job: TwitterFetcherJob) do
      post :execute_task, params: {commit: "Re-bio All Handles"}
    end

    assert_equal TwitterProfile.count, enqueued_jobs.size
    assert_match /: processed/i, flash[:notice]
  end
end
