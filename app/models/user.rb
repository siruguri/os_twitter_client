class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :channel_secrets, dependent: :destroy
  has_many :token_hash_records, class_name: 'OauthTokenHash'
  has_one :twitter_profile
  
  def latest_token_hash(src='twitter')
    token_hash_records.where(source: src).order(created_at: :desc).first
  end
end
