class ChangeTweetsCountDefaultInProfile < ActiveRecord::Migration
  def up
    change_column :twitter_profiles, :tweets_count, :integer, default: 0
  end

  def down
    change_column :twitter_profiles, :tweets_count, :integer, default: nil
  end
end
