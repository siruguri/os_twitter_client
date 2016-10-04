class GraphConnection < ActiveRecord::Base
  belongs_to :leader, class_name: 'TwitterProfile', foreign_key: :leader_id, inverse_of: :graph_connections_head
  belongs_to :follower, class_name: 'TwitterProfile', foreign_key: :follower_id, inverse_of: :graph_connections_tail
end
