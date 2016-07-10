require_relative '../../lib/snek'

RSpec.describe Snek do
  describe '#<<' do
    it 'does not grow longer than the snek_length' do
      snek = Snek.new([[0, 0]])

      (1..9).each do |i|
        snek << [0, i]
      end

      expect(snek).to eq [[0, 5], [0, 6], [0, 7], [0, 8], [0, 9]]
    end
  end

  describe '#inspect' do
    it 'outputs useful information' do
      snek = Snek.new([[0, 0]])
      snek << [1,2]
      expect(snek.inspect).to eq '#<Snek @snek_length=5 self="[[0, 0], [1, 2]]">'
    end
  end
end
