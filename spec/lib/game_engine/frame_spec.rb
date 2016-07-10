require_relative '../../../lib/game_engine/frame'

RSpec.describe GameEngine::Frame do
  describe '#draw' do
    it 'draws in the range' do
      frame = GameEngine::Frame.new 5, 1
      frame.draw 1, 0, 'foo'

      expect(frame.rows).to eq [' foo ']
    end

    it 'draws off the right hand side' do
      frame = GameEngine::Frame.new 5, 1
      frame.draw 10, 0, 'foo'

      expect(frame.rows).to eq ['     ']
    end

    it 'draws at the right edge' do
      frame = GameEngine::Frame.new 5, 1
      frame.draw 5, 0, 'f'

      expect(frame.rows).to eq ['     ']
    end

    it 'draws off the bottom' do
      frame = GameEngine::Frame.new 1, 1
      frame.draw 0, 1, 'f'

      expect(frame.rows).to eq [' ']
    end

    it 'draws off the top' do
      frame = GameEngine::Frame.new 1, 1
      frame.draw 0, -2, 'f'

      expect(frame.rows).to eq [' ']
    end
  end
end
