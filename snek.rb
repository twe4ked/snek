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
