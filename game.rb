$LOAD_PATH << '.'

require 'io/console'
require 'frame'
require 'snek'

class Game
  DIRECTIONS = %w[n s e w]

  def initialize
    @direction = random_direction
    @food = random_position
  end

  def start
    Frame.setup
    @snek = Snek.new([random_position])
    @tick = 0

    loop do
      render
      sleep 0.1
      @tick += 1
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

    move_snake if (@tick % 2 == 0 || %w[e w].include?(@direction))

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

    x = (1..columns-2).to_a.sample
    y = (1..rows-2).to_a.sample

    [x,y]
  end

  def random_direction
    DIRECTIONS.sample
  end

  def draw_border
    frame.draw 0, 0, "+#{'-' * (columns-2)}+"
    (1..rows-2).each do |y|
      frame.draw 0, y, '|'
      frame.draw columns-1, y, '|'
    end
    frame.draw 0, rows-1, "+#{'-' * (columns-2)}+"
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
          @direction = 'n' if @direction != 's'
        when 115 # S down
          @direction = 's' if @direction != 'n'
        when 100 # D right
          @direction = 'e' if @direction != 'w'
        when 97  # A left
          @direction = 'w' if @direction != 'e'
        end
      end
    rescue Errno::EAGAIN
    end
  end
end

Game.new.start
