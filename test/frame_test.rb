require 'test_helper'
require 'frame'

class FrameTest < Minitest::Test
  def test_draw_in_range
    frame = Frame.new 5, 1
    frame.draw 1, 0, 'foo'
    assert_equal [' foo '], frame.rows
  end

  def test_draw_hidden_right
    frame = Frame.new 5, 1
    frame.draw 10, 0, 'foo'
    assert_equal ['     '], frame.rows
  end

  def test_draw_right_edge
    frame = Frame.new 5, 1
    frame.draw 5, 0, 'f'
    assert_equal ['     '], frame.rows
  end

  def test_draw_off_bottom
    frame = Frame.new 1, 1
    frame.draw 0, 1, 'f'
    assert_equal [' '], frame.rows
  end

  def test_draw_off_top
    frame = Frame.new 1, 1
    frame.draw 0, -2, 'f'
    assert_equal [' '], frame.rows
  end

  def test_positions
    frame = Frame.new 5, 2
    frame.draw 0, 0, 'foo'
    frame.draw 2, 1, 'b'

    assert_equal([
      [0, 0], [1, 0], [2, 0],
      [2, 1]
    ],
      frame.positions
    )
  end
end
