class AddProtectedToTwitterProfile < ActiveRecord::Migration
  def change
    add_column :twitter_profiles, :protected, :boolean
  end
end
