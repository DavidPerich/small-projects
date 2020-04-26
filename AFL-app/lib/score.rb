# frozen_string_literal: true

# Object for each fixture for score info & methods for score results
class Score
  attr_reader :hscore, :ascore

  def initialize(hsupergoals, hgoals, hbehinds, hscore,
                 asupergoals, agoals, abehinds, ascore)

    @hsupergoals = hsupergoals
    @hgoals = hgoals
    @hbehinds = hbehinds
    @hscore = hscore
    @asupergoals = asupergoals
    @agoals = agoals
    @abehinds = abehinds
    @ascore = ascore
  end

  def home_to_s
    "#{@hgoals}.#{@hbehinds}.#{@hscore}"
  end

  def away_to_s
    "#{@agoals}.#{@abehinds}.#{@ascore}"
  end

  def winner
    @hscore <=> @ascore
  end
end
