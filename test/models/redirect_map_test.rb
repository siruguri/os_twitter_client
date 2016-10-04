require 'test_helper'

class RedirectMapTest < ActiveSupport::TestCase
  test 'Class correctly produces increment' do
    assert_equal 'baa', RedirectMap.increment_source

    RedirectMap.create(src: 'baa', dest: 'whatever')
    assert_equal 'bab', RedirectMap.increment_source    
  end

  test 'Class correctly produces first source' do    
    RedirectMap.all.map &:delete
    assert_equal 'a', RedirectMap.increment_source
  end
end
