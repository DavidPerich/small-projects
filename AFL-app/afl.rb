# frozen_string_literal: true

require 'csv'
require 'sinatra'
require 'sinatra/content_for'
require 'pg'
require 'date'
require 'tilt'

require_relative 'lib/database_persistance'
require_relative 'lib/team'
require_relative 'lib/season'
require_relative 'lib/venue'
require_relative 'lib/fixture'
require_relative 'lib/score'

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistance.rb'
end

Tilt.register Tilt::ERBTemplate, 'html.erb'

before do
  STORAGE = DatabasePersistence.new(logger, session)
end

after do
  STORAGE.disconnect
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistance.rb'
  enable :sessions
  set :session_secret, 'secret'
  set :erb, escape_html: true
end

helpers do
  def team_names_list
    STORAGE.teams.map(&:name).sort
  end

  def years_list
    STORAGE.seasons.map(&:year).sort
  end

  def venues_list
    STORAGE.venues.map(&:name).sort
  end

  def display_fixture(fixture)
    fixture.home_team.name + ' vs ' + fixture.away_team.name
  end

  def search_query
    query = {}
    query[:margin] = valid_margin? ? params['margin'] : '0'
    query[:teams] = join_strings(params['teams'], 'teams')
    query[:years] = join_strings(params['years'], 'years')
    query[:venues] = join_strings(params['venues'], 'venues')
    query
  end

  def valid_margin?
    params['margin'].to_i.positive?
  end
end

get '/' do
  erb :index
end

get '/big_margins' do
  erb :big_margins, layout: :layout
end

get '/big_margins_results' do
  @results = STORAGE.search(params).select do |fixture|
    params["teams"].include?(fixture.who_won?.name)
  end

  if @results.empty?
    STORAGE.session_error('No results for that search. Please try again')
    erb :big_margins, layout: :layout
  else
    STORAGE.session_success("There were #{@results.count} matching fixtures")
    erb :big_margins_results, layout: :results_layout
  end
end

get '/my_team' do
  erb :my_team, layout: :layout
end

get '/my_team_results' do
  @results = STORAGE.search(params)
  if @results.empty?
    STORAGE.session_error("#{params['teams'].first} didn't exist in the AFL then. Please try again")
    erb :my_team, layout: :layout
  else
    STORAGE.session_success('Here are your results')
    erb :my_team_results, layout: :results_layout
  end
end

def join_strings(array, term)
  if array.nil? then "All #{term}"
  elsif array.size == 1 then array.first
  elsif array.size == 2 then array.join ' and '
  else
    array.join(', ')
  end
end

def win_loss_summary(results, team)
  hash = count_wins_draws_losses(results, team)
  "Wins: #{hash[:wins]}, Draws: #{hash[:draws]}, Losses: #{hash[:losses]}"
end

def opposition_team(fixture, team)
  if fixture.home_team.name == team
    fixture.away_team.name
  else
    fixture.home_team.name
  end
end

def grand_final_summary(fixture, team)
  opposition = opposition_team(fixture, team)

  if fixture.who_won?.name == team
    "#{team} beat #{opposition} by #{fixture.margin} points in the grand final!"
  else
    "#{team} lost to #{opposition} by  #{fixture.margin} points in grand final."
  end
end

def finals_summary(results, team)
  return '' if results.first.year == 2019

  results.reverse_each do |fixture|
    case fixture.competition
    when /GF/
      return grand_final_summary(fixture, team)
    when /[A-Z]F/
      opposition = opposition_team(fixture, team)
      return "#{team} lost to #{opposition} by #{fixture.margin}
             in the #{fixture.expand_finals(fixture.competition)}."
    else
      return "#{team} didn't make the finals."
    end
  end
end

def count_wins_draws_losses(results, team)
  counts = Hash.new(0)
  results.each do |fixture|
    if fixture.competition == 'HA'
      if fixture.who_won?.name == team
        counts[:wins] += 1
      elsif fixture.who_won?.nil?
        counts[:draws] += 1
      else
        counts[:losses] += 1
      end
    end
  end
  counts
end
