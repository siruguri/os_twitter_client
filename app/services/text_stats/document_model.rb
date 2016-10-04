module TextStats
  class DocumentModel
    attr_reader :term_list, :body, :source_name, :document_length, :explanations
    attr_accessor :universe
    
    def initialize(body, opts={})
      body = body || ''
      @body = body
      @source_name = 'anon'

      @term_list = self.word_array opts
      @document_length = @term_list.size.to_f
      @tf = {}
      @counts = {}
      @explanations = {}
    end

    def terms(term_size=1)
      counts(term_size).keys
    end
    
    def word_array(opts = {})
      if opts[:as_html]
        @body.gsub!(/<\/?[^>]+>/, ' ')
        @body.gsub!(/\&\#x[\dABCDEF]+/, ' ')
      end

      if opts[:twitter]
        b = @body.gsub(/https?\:..t\.co.[^\s]+/, '').downcase
        b.gsub(/[^@#'a-zA-Z0-9]/, ' ').strip.split(/\s+/) - StopWords.list
      else
        @body.downcase.gsub(/[^'a-zA-Z0-9]/, ' ').strip.split(/\s+/) - StopWords.list
      end
    end

    def counts(term_size = 1, opts = {})
      if term_size > 1
        @counts[1] ||= counts
      end
      @counts["#{term_size}.#{opts[:unigram_boost]}"] ||=
        ngramify(term_size).group_by { |word| word }.
        inject({}) do |memo, pair|
        multiplier = (if opts[:unigram_boost].nil?
                      1
                     else
                       terms = pair[0].split /\s+/
                       terms.inject(1) { |memo, term| memo * Math.log(@counts[1][term]) }
                      end)

        multiplier *= (@universe.nil? ? 1 : 1.0/@universe.df(pair[0]))
        
        memo[pair[0]] = pair[1].size * multiplier

        @explanations[pair[0] + ".idf"] = (@universe.nil? ? 1 : 1.0/@universe.df(pair[0]))
        @explanations[pair[0] + ".tf"] = pair[1].size
        
        memo
      end
    end

    def sorted_counts(term_size = 1, opts = {})
      # Descending sort by count
      counts(term_size, opts).sort_by { |k, v| -v}
    end
    
    def cosine_sim(vec)
      DotProduct.new(self, vec, universe: @universe)
    end

    def magnitude(term_size=1)
      sqr_mag = counts(term_size).inject(0) do |memo, h|
        prod = h[1] * h[1]
        if @universe
          prod /= (@universe.universe_count(h[0]) * @universe.universe_count(h[0]))
        end
        
        memo += prod
      end

      Math.sqrt(sqr_mag)
    end

    private
    def ngramify(term_size)
      # Convert term list into array of ordered n grams
      # 1gram means the term list itself

      if term_size == 1
        return @term_list
      end

      (0..@term_list.size - term_size).map do |index|
        (0..term_size - 1).map { |rep| @term_list[index+rep] }.join ' '
      end
    end
  end
end
