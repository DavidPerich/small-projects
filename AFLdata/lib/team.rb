# frozen_string_literal: true

require_relative 'database_persistance'
# provides team name and logopath. Could include URLs etc in future
class Team
  attr_accessor :name, :logo_path, :id
  def initialize(id, name)
    @id = id
    @name = name
    @logo_path = "/images/logos/#{name}.png"
  end
end
