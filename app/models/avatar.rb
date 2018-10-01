
class Avatar

  def initialize(externals, id, name)
    # Does *not* validate.
    @externals = externals
    @id = id
    @name = name
  end

  attr_reader :name

  def kata
    Kata.new(@externals, @id)
  end

  def active?
    kata.active?
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the group.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
