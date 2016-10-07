require 'ruby-prof'
Socket.do_not_reverse_lookup=true

class Tester
  include TwitterAnalysis
end

opt = 2
bio = User.second.twitter_profile
tweets_reln = bio.tweets
tweet_id_list = tweets_reln.pluck(:tweet_id)
tweets = TweetText.where("tweet_id" => {"$in" => tweet_id_list})
univ = DocumentUniverse.last.universe

t=Tester.new

RubyProf.start
word_cloud =
  (case opt
   when 1
     t.word_cloud(tweets: tweets_reln, document_universe: univ, bio: bio)
   when 2
     t.word_cloud(tweets: tweets, document_universe: univ, bio: bio, use_mongo: true)
   end)
result = RubyProf.stop

# print a flat profile to text
printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("tmp/graph#{opt}.html", 'w'), min_percent: 2)
