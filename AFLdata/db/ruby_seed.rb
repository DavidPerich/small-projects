# frozen_string_literal: true

require 'csv'
require 'sinatra'
require 'pg'
require 'date'

@db = PG.connect(dbname: 'afl')

def query(statement, *params)
  @db.exec_params(statement, params)
end

def fixtures
  all_fixtures = []
  CSV.foreach('AFL Fixtures 1993 - 2018.csv', headers: true) do |row|
    hash = row.to_h
    hash.each do |item|
      hash[item[0]] = item[1].delete('"')
    end
    all_fixtures << hash
  end
  all_fixtures
end

def add_year_to_database(fixtures)
  years = fixtures.map { |hash| hash['year'].to_i }.uniq
  years.each do |current_year|
    sql = 'INSERT INTO seasons (year) VALUES ($1);'
    query(sql, current_year)
  end
end

def add_teams_to_database(fixtures)
  all_teams = fixtures.map { |hash| hash['hteam'] }.uniq
  all_teams.each do |team|
    sql = 'INSERT INTO teams (name) VALUES ($1);'
    query(sql, team)
  end
end

def add_venues_to_database(fixtures)
  all_venues = fixtures.map { |hash| hash['venue'] }.uniq
  all_venues.each do |venue|
    sql = 'INSERT INTO venues (name) VALUES ($1);'
    query(sql, venue)
  end
end

def check_margin(hscore, ascore)
  case hscore <=> ascore
  when -1 then ascore - hscore
  when 0 then 0
  when 1 then hscore - ascore
  end
end

def add_fixtures_to_database(fixtures)
  fixtures.each do |hash|
    year = hash['year'].to_i
    competition = hash['competition']
    round = hash['round']
    datetime = Date.parse(hash['datetime'])
    day = hash['day']
    hteam_id = team_id(hash['hteam'])
    ateam_id = team_id(hash['ateam'])
    venue_id = venue_id(hash['venue'])
    hsupergoals = hash['hsupergoals'].to_i
    hgoals = hash['hgoals'].to_i
    hbehinds = hash['hbehinds'].to_i
    hscore = hash['hscore'].to_i
    asupergoals = hash['asupergoals'].to_i
    agoals = hash['agoals'].to_i
    abehinds = hash['abehinds'].to_i
    ascore = hash['ascore'].to_i
    margin = check_margin(hscore, ascore)

    sql = <<~SQL
      INSERT INTO fixtures (year, competition, round, datetime, day, hteam_id, ateam_id, venue_id, hsupergoals, hgoals, hbehinds, hscore, asupergoals, agoals, abehinds, ascore, margin )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17);
    SQL

    query(sql, year, competition, round, datetime, day, hteam_id, ateam_id,
          venue_id, hsupergoals, hgoals, hbehinds, hscore, asupergoals, agoals, abehinds, ascore, margin)
  end
end

def team_id(team_name)
  teams = query('select * from teams')
  team_id = nil
  teams.each do |team|
    team_id = team['id'].to_i if team_name == team['name']
  end
  team_id
end

def venue_id(venue_name)
  venues = query('select * from venues')
  venue_id = nil
  venues.each do |venue|
    venue_id = venue['id'].to_i if venue_name == venue['name']
  end
  venue_id
end

# add_year_to_database(fixtures)
# add_teams_to_database(fixtures)
# add_venues_to_database(fixtures)
add_fixtures_to_database(fixtures)
