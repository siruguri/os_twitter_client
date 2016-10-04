class AddProcessedIndexOnTweet < ActiveRecord::Migration
  def change
    add_index :tweets, :processed
  end
end
