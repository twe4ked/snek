class Snek < Array
  DIRECTIONS = %w[n s e w]

  attr_accessor :snek_length, :direction

  def initialize(*args)
    @snek_length = 5
    @direction = random_direction
    super
  end

  def <<(*args)
    shift if count >= snek_length

    super
  end

  alias_method :orig_inspect, :inspect
  def inspect
    "#<Snek @snek_length=#{@snek_length.inspect} self=#{orig_inspect.inspect}>"
  end

  private

  def random_direction
    DIRECTIONS.sample
  end
end
