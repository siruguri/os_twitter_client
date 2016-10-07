Tweet.find_each do |t|
  if t.processed.nil?
    t.processed = false
    t.save
  end
end
