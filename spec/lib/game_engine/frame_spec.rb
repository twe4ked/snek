require_relative '../../../lib/game_engine/frame'

RSpec.describe GameEngine::Frame do
  describe '#draw' do
    let(:frame) { GameEngine::Frame.new 5, 3 }
    let(:blank_5_x_3_frame) do
      [
        '     ',
        '     ',
        '     ',
      ]
    end

    it 'draws in the range' do
      frame.draw 1, 1, 'foo'

      expect(frame.rows).to eq [
        '     ',
        ' foo ',
        '     ',
      ]
    end

    it 'draws off the left' do
      frame.draw -1, 1, 'foo'

      expect(frame.rows).to eq [
        '     ',
        'oo   ',
        '     ',
      ]
    end

    it 'draws off the right' do
      frame.draw 3, 1, 'foo'

      expect(frame.rows).to eq [
        '     ',
        '   fo',
        '     ',
      ]
    end

    it 'draws off the bottom' do
      frame.draw 0, 3, 'foo'

      expect(frame.rows).to eq blank_5_x_3_frame
    end

    it 'draws off the top' do
      frame.draw 0, -1, 'foo'

      expect(frame.rows).to eq blank_5_x_3_frame
    end
  end
end
