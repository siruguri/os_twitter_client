class RedirectMap < ActiveRecord::Base
  has_many :redirect_requests

  validates_uniqueness_of :src

  def self.increment_source
    # Auto produce a src URL
    base_string = ('abcdefghijklmnopqrstuvwxyz' + 'abcdefghijklmnopqrstuvwxyz'.upcase).split('')
    if count == 0
      return 'a'
    else
      prev_target = order(created_at: :asc).last.src
      rev_array = prev_target.reverse.split('').inject({next: [], carry: 1}) do |memo, letter|
        val = base_string.index letter
        val += memo[:carry]

        carry = 0
        if memo[:carry] == 1
          if val == base_string.size
            carry = 1
            val = 0
          end
        end
        new_memo = {next: memo[:next] + [val], carry: carry}
      end
      new_str = rev_array[:next].map { |num| base_string[num] }.join('').reverse
      new_str
    end
  end
end
