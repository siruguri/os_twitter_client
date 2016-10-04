class AddTweetsCountToTwitterProfiles < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :tweets_count, :integer
  end
end
