class PostStrategy
  STRATEGIES=[times: [:once, :repeat], to: [:all, :facebook, :twitter],
              until: [:max_count, :final_post], frequency: [:repeated, :fuzzy]
             ]

  attr_reader :options
  def initialize(opts = {times: :once, to: :all})
    if valid?(opts)
      @options = opts
    end
  end
  
  def self.default
    return self.new(times: :once, to: :all)
  end

  def times
    @options[:times]
  end

  def channel_list
    @options[:to]
  end

  def ==(other)
    @options[:times] == other.times && @options[:to] == other.channel_list
  end
  
  private
  def valid?(h)
    # Later this will check that the syntax of options is right
    true
  end
end
