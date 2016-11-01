tp_1 = TwitterProfile.where handle: h1
tp_2 = TwitterProfile.where handle: h2
target_foll_ids = GraphConnection.where(leader_id: tp_1.first.id).pluck :follower_id
my_foll_ids = GraphConnection.where(leader_id: tp_2.first.id).pluck :follower_id

common_to_target = my_foll_ids.select { |id| target_foll_ids.include?(id) }
names = TwitterProfile.where('id in (?)', common_to_target).pluck :handle, :display_name

f = File.open('tmp/cs_names.tsv', 'w')
names.each { |p| f.puts "#{p[0]}\t#{p[1]}" }
f.close
