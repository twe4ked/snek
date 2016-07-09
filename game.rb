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

    if @tick % 2 == 0 || %w[e w].include?(@direction)
      new_position = move_snek

      border = draw_border
      draw_snek
      draw_food

      if border.include?(new_position)
        puts
        puts 'you crashed into a wall'
        exit
      end

      if @snek.include?(@food)
        @snek.length += 1
        @food = random_position
      end

      input do |key|
        if key
          return if @tick == @input_in_tick
          @input_in_tick = @tick
        end

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

      frame.render
    end
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

    border = []
    border << (0..columns-1).map { |x| [x, 0] }
    border << (0..rows-1).map { |y| [0, y] }
    border << (0..rows-1).map { |y| [columns-1, y] }
    border << (0..columns-1).map { |x| [x, rows] }
    border.flatten(1)
  end

  def draw_snek
    @snek.each_with_index do |segment, index|
      frame.draw *segment, index == @snek.count-1 ? '@' : '*'
    end
  end

  def draw_food
    frame.draw *@food, '$'
  end

  def move_snek
    x, y = @snek.last

    new_position = case @direction
    when 'n'
      [x, y - 1]
    when 's'
      [x, y + 1]
    when 'e'
      [x + 1, y]
    when 'w'
      [x - 1, y]
    end

    if @snek.include?(new_position)
      puts
      puts 'you crashed into yourself'
      exit
    end

    @snek << new_position
    new_position
  end

  def input
    begin
      loop do
        key = $stdin.read_nonblock(1).ord
        yield key
      end
    rescue Errno::EAGAIN
    end
  end

  def debug
    puts "\r"
    Frame.enable_cursor
    $stdin.cooked!
    system 'stty sane'
    require 'pry'; binding.pry
  end
end

Game.new.start
