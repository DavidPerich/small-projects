# frozen_string_literal: true

require 'pg'

# Class to query to connect to and query the database and return ruby objects.
class DatabasePersistence
  attr_reader :teams, :venues, :seasons
  def initialize(logger, session)
    @session = session
    @logger = logger
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'afl')
          end
    # I don't think these belong here,
    # but I can't figure out how else to stop hundreds of db queries each search
    # They end up just being used so that other classes can return info on
    # teams, venues and years without needing to hit the db. Good or bad?
    @teams = all_teams
    @venues = all_venues
    @seasons = all_seasons
  end

  def session_error(message)
    @session[:error] = message
  end

  def session_success(message)
    @session[:success] = message
  end

  def self.all_teams
    all_teams
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def disconnect
    @db.close
  end

  def search(params)
    search_terms = db_search_terms(params)
    search_sql = sql_query_terms(search_terms)
    sort_term = params['sort-by']

    sql = "SELECT * FROM fixtures WHERE #{search_sql}
           ORDER BY #{sort_by(sort_term)};"

    results = query(sql)

    results.map do |tuple|
      fixture_tuple_to_object(tuple)
    end
  end

  def sort_by(sort_term)
    case sort_term
    when nil then 'margin DESC'
    when /margin/ then 'margin DESC'
    when /newest/ then 'datetime DESC'
    when /oldest/ then 'datetime ASC'
    end
  end

  def db_search_terms(params)
    terms = {}

    params.each do |key, value|
      terms[key] = if key == 'margin'
                     value.to_i
                   elsif key == 'teams'
                     value.map { |team_name| team_id(team_name) }
                   elsif key == 'years'
                     value.map(&:to_i)
                   elsif key == 'venues'
                     value.map { |venue_name| venue_id(venue_name) }
                   end
    end
    terms
  end

  def sql_query_terms(search_terms)
    margin_query(search_terms) +
      sql_join(teams_query(search_terms)) +
      sql_join(years_query(search_terms)) +
      sql_join(venues_query(search_terms))
  end

  def margin_query(search_terms)
    if search_terms['margin'].nil?
      'margin > 0'
    else
      "margin > #{search_terms['margin']}"
    end
  end

  def teams_query(search_terms)
    if search_terms['teams'].nil?
      ''
    else
      "(hteam_id = ANY  (\'{#{search_terms['teams'].join(',')}}\'::int[])
        OR ateam_id = ANY  (\'{#{search_terms['teams'].join(',')}}\'::int[]))"
    end
  end

  def years_query(search_terms)
    if search_terms['years'].nil?
      ''
    else
      "(year = ANY  (\'{#{search_terms['years'].join(',')}}\'::int[]))"
    end
  end

  def venues_query(search_terms)
    if search_terms['venues'].nil?
      ''
    else
      "(venue_id = ANY  (\'{#{search_terms['venues'].join(',')}}\'::int[]))"
    end
  end

  def sql_join(string)
    string.empty? ? '' : ' AND ' + string
  end

  def team_id(team_name)
    all_teams.find { |team| team.name == team_name }.id
  end

  def venue_id(venue_name)
    all_venues.find { |venue| venue_name == venue.name }.id
  end

  # will return an array of team objects.
  def all_teams
    sql = 'SELECT * FROM teams'
    teams = query(sql)

    teams.map { |tuple| team_tuple_to_object(tuple) }
  end

  def all_seasons
    sql = 'SELECT * FROM seasons'
    seasons = query(sql)

    seasons.map { |tuple| season_tuple_to_object(tuple) }
  end

  def all_venues
    sql = 'SELECT * FROM venues'
    venues = query(sql)

    venues.map { |tuple| venue_tuple_to_object(tuple) }
  end

  private

  def team_tuple_to_object(tuple)
    Team.new(tuple['id'].to_i, tuple['name'])
  end

  def season_tuple_to_object(tuple)
    Season.new(tuple['year'])
  end

  def venue_tuple_to_object(tuple)
    Venue.new(tuple['id'].to_i, tuple['name'])
  end

  def fixture_tuple_to_object(tuple)
    # I don't know how I'm supposed to make these objects smaller?

    year = tuple['year'].to_i
    competition = tuple['competition']
    round = tuple['round'].to_i
    datetime = Date.parse(tuple['datetime'])
    day = tuple['day']
    hteam_id = tuple['hteam_id'].to_i
    ateam_id = tuple['ateam_id'].to_i
    venue_id = tuple['venue_id'].to_i

    Fixture.new(year, competition, round, datetime,
                day, hteam_id, ateam_id, venue_id, tuple_to_score(tuple))
  end

  def tuple_to_score(tuple)
    # I don't know how I'm supposed to make these methods smaller?
    hsupergoals = tuple['hsupergoals'].to_i
    hgoals = tuple['hgoals'].to_i
    hbehinds = tuple['hbehinds'].to_i
    hscore = tuple['hscore'].to_i
    asupergoals = tuple['asupergoals'].to_i
    agoals = tuple['agoals'].to_i
    abehinds = tuple['abehinds'].to_i
    ascore = tuple['ascore'].to_i

    Score.new(hsupergoals, hgoals, hbehinds, hscore,
              asupergoals, agoals, abehinds, ascore)
  end
end
