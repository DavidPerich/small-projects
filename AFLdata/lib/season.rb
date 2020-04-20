# frozen_string_literal: true

require_relative 'database_persistance'

# currently does nothing except store the year
# There were many more methods that summarised the season
# but they've been removed with new implementation and db
# to add - initialize fixtures here?
class Season
  attr_accessor :year

  def initialize(year)
    # @fixtures = all_fixtures_for_season(year)
    @year = year
  end
end
