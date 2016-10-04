class WebArticle < ActiveRecord::Base
  # Store web articles scraped from the web
  include TextStatisticsAnalyzer

  has_many :article_taggings
  has_many :tags, through: :article_taggings, class_name: 'ArticleTag', source: :article_tag
  belongs_to :twitter_profile
  
  validate :original_url, :valid_uri?

  def self.valid_uri?(u)
    u =~ /\A#{URI::regexp(['http', 'https'])}\z/
  end
  
  def valid_uri?
    if WebArticle.valid_uri?(self.original_url)
      return true
    else
      errors.add(:base, 'Invalid URI supplied for source')
    end
  end
end
