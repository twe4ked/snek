$LOAD_PATH << '.'

require 'io/console'
require 'frame'
require 'snek'
require 'network'

class Game
  def initialize
    @food = @local_food_position = random_position
    @random_number = rand
    @messages = {}
  end

  def start
    network.open_socket
    Frame.setup
    reset_snake
    @other_sneks = {}
    @food_positions = {}
    @tick = 0

    loop do
      tick
    end
  end

  private

  attr_reader :frame

  def tick
    render
    sleep 0.1
    @tick += 1

    update_network
  end

  def update_network
    network.receive_updates do |data|
      key = data[:hostname]
      unless key == network.hostname
        @other_sneks[key] = unpack_snek(data[:snek])
      end
      @food_positions[data[:random_number]] = data[:food_position]
    end
    network.send_update(
      snek: pack_snek(@snek),
      random_number: @random_number,
      food_position: @local_food_position,
    )
  end

  def pack_snek(snek)
    snek.flatten.join(',')
  end

  def unpack_snek(snek)
    snek.split(',').map(&:to_i).each_slice(2).to_a
  end

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

    if @tick % 2 == 0 || %w[e w].include?(@snek.direction)
      new_position = move_snek

      border = draw_border
      draw_messages
      draw_sneks
      draw_food

      check_border_collision(border, new_position)
      check_food_collision(new_position)

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
          @snek.direction = 'n' if @snek.direction != 's'
        when 115 # S down
          @snek.direction = 's' if @snek.direction != 'n'
        when 100 # D right
          @snek.direction = 'e' if @snek.direction != 'w'
        when 97  # A left
          @snek.direction = 'w' if @snek.direction != 'e'
        end
      end

      frame.render
    end
  end

  def check_border_collision(border, new_position)
    if border.include?(new_position)
      add_message 'you crashed into a wall'
      reset_snake
      return
    end
  end

  def check_food_collision(new_position)
    if @food == new_position
      @snek.length += 1
      @local_food_position = random_position
      @random_number += 1
      @food = random_remote_position || @local_food_position
    end
  end

  def random_remote_position
    @food_positions.max_by { |k, v| k }.last
  end

  # TODO: non-conflicting
  def random_position
    x = (1..columns-2).to_a.sample
    y = (1..rows-2).to_a.sample

    [x,y]
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

  def draw_sneks
    draw_snek @snek

    @other_sneks.values.each do |snek|
      draw_snek snek, head: '&'
    end
  end

  def draw_snek(snek, head: '@')
    snek.each_with_index do |segment, index|
      char = index == snek.count-1 ? head : '*'
      frame.draw *segment, char
    end
  end

  def draw_food
    frame.draw *@food, '$'
  end

  def move_snek
    x, y = @snek.last

    new_position = case @snek.direction
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
      add_message 'you crashed into yourself'
      reset_snake
      return
    end

    @other_sneks.each do |hostname, snek|
      if snek.include?(new_position)
        add_message "you crashed into #{hostname}"
        reset_snake
        return
      end
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

  def network
    @network ||= Network.new
  end

  def reset_snake
    @snek = Snek.new([random_position])
  end

  def debug
    puts "\r"
    Frame.enable_cursor
    $stdin.cooked!
    system 'stty sane'
    require 'pry'; binding.pry
  end

  def add_message(message)
    @messages[message] = @tick + 10
  end

  def draw_messages
    @messages.each do |message, end_tick|
      if @tick < end_tick
        frame.draw_center rows/2, message
      end
    end
  end
end

Game.new.start
