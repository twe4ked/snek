$LOAD_PATH << '.'

require 'io/console'
require 'frame'

class Snek < Array
  def initialize(*args)
    @length = 4
    super
  end

  def <<(*args)
    shift if count > @length

    super
  end
end

class Game
  def initialize
    @direction = 'e'
  end

  def start
    Frame.setup
    @snek = Snek.new([[10,10]])

    loop do
      render
      sleep 0.1
    end
  end

  private

  attr_reader :frame

  def render
    rows, columns = $stdin.winsize
    @frame = Frame.new columns, 25

    move_snake

    draw_border
    draw_snake

    input

    frame.render
  end

  def draw_border
    frame.draw 0, 0, "+#{'-' * 78}+"
    (1..23).each do |y|
      frame.draw 0, y, '|'
      frame.draw 79, y, '|'
    end
    frame.draw 0, 24, "+#{'-' * 78}+"
  end

  def draw_snake
    @snek.each do |segment|
      frame.draw *segment, '*'
    end
  end

  def move_snake
    x, y = @snek.last

    case @direction
    when 'n'
      @snek << [x, y - 1]
    when 's'
      @snek << [x, y + 1]
    when 'e'
      @snek << [x + 1, y]
    when 'w'
      @snek << [x - 1, y]
    end
  end

  def input
    begin
      loop do
        key = $stdin.read_nonblock(1).ord

        head = @snek.last

        case key
        when 'q'.ord, 27, 3 # escape, ctrl-c
          exit
        when 119 # W up
          @direction = 'n'
        when 115 # S down
          @direction = 's'
        when 100 # D right
          @direction = 'e'
        when 97  # A left
          @direction = 'w'
        end
      end
    rescue Errno::EAGAIN
    end
  end
end

Game.new.start
