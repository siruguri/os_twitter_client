module TextStats
  class DocumentUniverse
    def initialize
      @_counts = {}
      @_univ_size = 0
    end

    def add(doc_model)
      @_univ_size += 1
      doc_model.terms.each do |k|
        @_counts[k] ||= 0
        @_counts[k] += 1
      end

      self
    end

    def universe_count(term)
      if @_counts[term]
        @_counts[term]
      else
        1.042
      end
    end

    alias :df :universe_count
  end
end
