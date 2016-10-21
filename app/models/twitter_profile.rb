class TwitterProfile < ActiveRecord::Base
  has_many :tweets, foreign_key: :twitter_id, primary_key: :twitter_id, dependent: :destroy
  has_one :profile_stat, dependent: :destroy

  has_many :twitter_request_records, foreign_key: :handle, primary_key: :handle
  has_many :graph_connections_head, class_name: 'GraphConnection',
           dependent: :destroy, foreign_key: :leader_id, inverse_of: :leader
  has_many :graph_connections_tail, class_name: 'GraphConnection',
           dependent: :destroy, foreign_key: :follower_id, inverse_of: :follower
  has_many :friends, through: :graph_connections_tail, source: :leader, class_name: 'TwitterProfile'
  has_many :followers, through: :graph_connections_head, source: :follower, class_name: 'TwitterProfile'
  
  serialize :word_cloud, Hash
  belongs_to :user

  after_create :create_stat

  def webdocs_string
    str = '' 
    crawled_web_documents.find_each do |article|
      str += article.body + ' '
    end
    
    str
  end

  def crawled_web_documents
    @docs ||=  WebArticle.where('web_articles.body is not null and twitter_profile_id = ?', self.id)
  end

  def process_followers(cmd, token)
    # Return number of new jobs; nil if args are erroneous
    return nil if !([:bios].include? cmd)

    ctr = 0
    case cmd
    when :bios
      self.followers.where('twitter_profiles.updated_at < ? or handle is null', Date.today - 4.months).find_each do |foll|
        TwitterFetcherJob.perform_later foll, 'bio', token: token
        ctr += 1
      end
    end

    ctr
  end
  
  private
  def create_stat
    # blank profile stat for later batch processing
    p = ProfileStat.new twitter_profile_id: self.id
    p.save
  end
end
