class DocumentUniverse < ActiveRecord::Base
  extend TwitterAnalysis
  serialize :universe, TextStats::DocumentUniverse
  
  def self.reanalyze
    du = TextStats::DocumentUniverse.new
    ctr = 0
    Tweet.where('mesg is not null and mesg != ?', '').find_in_batches(batch_size: 1000) do |grp|
      grp.map(&:mesg).each do |mesg|
        du.add TextStats::DocumentModel.new(mesg)
      end
      ctr += 1
    end
    create universe: du
  end
end
