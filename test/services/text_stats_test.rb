require 'test_helper'

class TextStatsTest < ActiveSupport::TestCase
  def setup
    @doc = 'http://t.co/alakjl1lk @ogabaga1 is a good one isnt good it isnt now good'

    @model_1 = TextStats::DocumentModel.new 'cat dog cat cat cat dog buffalo'
    @model_2 = TextStats::DocumentModel.new 'cat dog cat cat cat dog buffalo'
    @model_3 = TextStats::DocumentModel.new 'cat dog cat cat cat'
    @leading_space_model_3 = TextStats::DocumentModel.new ' cat dog cat cat cat'
  end

  def test_counting_works
    assert_equal({"cat" => 4, "dog" => 2, "buffalo" => 1}, @model_1.counts)
    assert_equal({"cat dog" => 2, "dog cat" => 1, "cat cat"=>2, "dog buffalo" => 1}, @model_1.counts(2))
    assert_equal @model_3.counts, @leading_space_model_3.counts
  end
  def test_sorted_counting_works
    assert_equal([["cat", 4], ["dog", 2], ["buffalo", 1]], @model_1.sorted_counts)
  end
  def test_sorted_counting_works_with_boosting
    refute_equal @model_1.sorted_counts(2, unigram_boost: 1), @model_1.sorted_counts(2)

    assert_equal [["cat cat", 3.843624111345611], ["cat dog", 1.9218120556728056], ["dog cat", 0.9609060278364028], ["dog buffalo", 0.0]],
                 @model_1.sorted_counts(2, unigram_boost: 1)
  end
  def test_cosine_sim
    assert_equal "1", sprintf("%.25g", @model_1.cosine_sim(@model_2).score)
    assert_equal "cat:0.761904761904762\ndog:0.1904761904761905\nbuffalo:0.04761904761904762\nIntersection size: 3",
                 @model_1.cosine_sim(@model_2).explanation
  end

  describe "Using Universe" do
    before do
      @d = TextStats::DocumentUniverse.new
    @model_1 = TextStats::DocumentModel.new 'cat dog cat cat cat dog buffalo'
    @model_2 = TextStats::DocumentModel.new 'cat dog cat cat cat dog buffalo'
    @model_3 = TextStats::DocumentModel.new 'cat dog cat cat cat'
      @d.add @model_1
      @d.add @model_2
      @d.add @model_3
    end
    
    it "returns df counts" do
      assert_equal 3, @d.universe_count('cat')
      assert_equal 2, @d.universe_count('buffalo')
    end

    it "works in cosine sim" do
      assert_equal 34126, (100000 * TextStats::DotProduct.new(@model_1, @model_2, {universe: @d}).score).to_i
    end
  end

  test 'basic doc parsing' do
    assert_equal [["good", 3], ["isnt", 2], ['alakjl1lk', 1], ["ogabaga1", 1]],
                 TextStats::DocumentModel.new(@doc).sorted_counts
    assert_equal [["good", 3], ["isnt", 2], ["@ogabaga1", 1]], TextStats::DocumentModel.new(@doc, twitter: true).sorted_counts
  end
end
