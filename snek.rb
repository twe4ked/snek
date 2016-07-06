$LOAD_PATH << '.'

require 'io/console'
require 'frame'

class Snek < Array
  attr_accessor :length

  def initialize(*args)
    @length = 4
    super
  end

  def <<(*args)
    shift if count > length

    super
  end
end

class Game
  DIRECTIONS = %w[n s e w]

  def initialize
    @direction = random_direction
    @food = random_position
  end

  def start
    Frame.setup
    @snek = Snek.new([random_position])

    loop do
      render
      sleep 0.1
    end
  end

  private

  attr_reader :frame

  def rows
    $stdin.winsize[0]
    25
  end

  def columns
    $stdin.winsize[1]
    80
  end

  def render
    @frame = Frame.new columns, rows

    move_snake

    draw_border
    draw_snake
    draw_food

    if @snek.include?(@food)
      @snek.length += 1
      @food = random_position
    end

    input

    frame.render
  end

  def random_position
    # TODO: non-conflicting
    # TODO: not a border

    x = (0..columns).to_a.sample
    y = (0..rows).to_a.sample

    [x,y]
  end

  def random_direction
    DIRECTIONS.sample
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

  def draw_food
    frame.draw *@food, '$'
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
