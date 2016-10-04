class ChannelPost < ActiveRecord::Base
  validates :url, presence: true
  validates :message, presence: true
  
  serialize :post_strategy, PostStrategy
  serialize :tweet_tags, Array

  has_many :channel_post_redirect_maps
  has_many :redirect_maps, through: :channel_post_redirect_maps
  has_many :media_records
  
  before_save :set_total_count, :check_for_url

  private
  def set_total_count
    if new_record?
      self.total_post_count = 0
    end
  end

  def check_for_url
    if (string_list = url_string(self.message))
      string_list.each do |target|
        if (prev_map = RedirectMap.find_by_dest(target))
          self.redirect_maps << prev_map
        else
          last_target = RedirectMap.increment_source
          self.redirect_maps.build(src: last_target, dest: target)
        end
      end
    end
  end

  def url_string(body)
    l = [self.url]
    
    # TODO: Add URLs that are embedded in the message
    l
  end
end
