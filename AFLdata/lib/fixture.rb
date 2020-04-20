# frozen_string_literal: true

require_relative 'database_persistance'

# individual fixture between two teams
# contains score object and instance variables for fixture details.
class Fixture
  attr_reader :competition, :year, :datetime

  def initialize(year, competition, round, datetime,
                 day, hteam_id, ateam_id, venue_id, score)
    @year = year
    @competition = competition
    @round = round
    @datetime = datetime
    @day = day
    @hteam_id = hteam_id
    @ateam_id = ateam_id
    @venue_id = venue_id
    @score = score
  end

  def home_team
    STORAGE.teams.find { |team| team.id == @hteam_id }
  end

  def away_team
    STORAGE.teams.find { |team| team.id == @ateam_id }
  end

  def venue
    STORAGE.venues.find { |venue| venue.id == @venue_id }.name
  end

  def home_full_score
    @score.home_to_s
  end

  def away_full_score
    @score.away_to_s
  end

  def margin
    case @score.hscore <=> @score.ascore
    when 1 then @score.hscore - @score.ascore
    when 0 then 0
    when -1 then @score.ascore - @score.hscore
    end
  end

  def day_and_date
    date_string = @datetime.strftime('%d-%m-%Y')
    "#{@day} #{date_string}"
  end

  def round
    if @competition.match(/P\d/) then 'Pre-season'
    elsif @competition.match(/HA/) then "Round #{@round}"
    else
      expand_finals(@competition)
    end
  end

  def who_won?
    case @score.winner
    when 1 then home_team
    when 0 then nil
    when -1 then away_team
    end
  end

  def display_result
    winner = who_won?.name
    winner.nil? ? 'It was a draw' : "#{winner} won by #{margin}"
  end

  def home_team_logo
    home_team.logo_path
  end

  def away_team_logo
    away_team.logo_path
  end

  def expand_finals(abbreviation)
    case abbreviation
    when  /EF/ then 'Elimination Final'
    when  /QF/ then 'Qualifying Final'
    when  /SF/ then 'Semi Final'
    when  /PF/ then 'Preliminary Final'
    when  /GF/ then 'Grand Final'
    end
  end
end
