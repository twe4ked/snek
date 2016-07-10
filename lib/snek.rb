class Snek < Array
  DIRECTIONS = %w[n s e w]

  attr_accessor :length, :direction

  def initialize(*args)
    @length = 4
    @direction = random_direction
    super
  end

  def <<(*args)
    shift if count > length

    super
  end

  private

  def random_direction
    DIRECTIONS.sample
  end
end
