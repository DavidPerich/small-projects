# frozen_string_literal: true

# Doesn't do much of anything atm.
class Venue
  attr_reader :name, :id
  def initialize(id, name)
    @id = id
    @name = name
  end
end
