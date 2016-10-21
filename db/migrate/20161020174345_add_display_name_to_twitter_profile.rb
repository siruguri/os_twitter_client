class AddDisplayNameToTwitterProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_profiles, :display_name, :string
  end
end
