class AddRequestTokenToOauthTokenHash < ActiveRecord::Migration
  def change
    add_column :oauth_token_hashes, :request_token, :string
  end
end
