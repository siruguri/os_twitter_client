module TextStats
  class DotProduct
    # Currently, only running dot-product for 1-grams

    attr_reader :score, :products, :dot_product
    def initialize(d1, d2, opts = {})
      @source_names=[d1.source_name, d2.source_name]
      @products = {}
      common_keys = d1.terms & d2.terms

      @intersection_size = common_keys.size
      @dot_product = common_keys.inject(0) do |memo, k|
        @products[k] = d1.counts[k] * d2.counts[k].to_f

        if opts[:universe] and opts[:universe].is_a? DocumentUniverse
          @universe = opts[:universe]
          @products[k] /= opts[:universe].universe_count(k)
        end
        
        memo += @products[k]
      end

      @score = @dot_product / ((@_d1m=d1.magnitude) * (@_d2m=d2.magnitude))
    end

    def explanation(opts = {})
      expl = @products.sort_by do |k, v|
        if opts[:universe]
          v /= opts[:universe].universe_count(k)
        end
        -1 * v
      end.map do |k, v|
        if opts[:universe]
          v /= opts[:universe].universe_count(k)
          k += " (#{opts[:universe].universe_count(k)})"
        end
        
        score = v.to_f/@_d2m/@_d1m
        "#{k}:#{score}"
      end.join("\n")

      expl += "\nIntersection size: #{@intersection_size}"
    end
  end
end
