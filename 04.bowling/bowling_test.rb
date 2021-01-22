# frozen_string_literal: true

require 'minitest/autorun'
require './bowling'

class BowlingTest < Minitest::Test
  def test_bowling
    assert_equal 139, bowling('6390038273X9180X645')
    assert_equal 164, bowling('6390038273X9180XXXX')
    assert_equal 107, bowling('0X150000XXX518104')
    assert_equal 134, bowling('6390038273X9180XX00')
    assert_equal 300, bowling('XXXXXXXXXXXX')
  end
end
