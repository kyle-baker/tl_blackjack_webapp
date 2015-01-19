require 'rubygems'
require 'sinatra'
require 'pry'

# Set port for compatability with Nitrous.IO 
configure :development do   
  set :bind, '0.0.0.0'   
  set :port, 3000 # Not really needed, but works well with the "Preview" menu option
end

set :sessions, true

#################################################################################### 
helpers do
  def calculate_total(cards) 
#[['D', '3'], ['S', '10'], ...]
  array = cards.map{|e| e[1]}
  total = 0
  array.each do |value|
    if value == "A"
      total += 11
    elsif value.to_i == 0 # Jack, Queen, King
      total += 10
    else
      total += value.to_i
    end
  end
  #correct for aces
  array.select{|e| e == "A"}.count.times do
    total -= 10 if total > 21
  end
  total
  end

  def card_image(card) #['H', '5']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
      end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  # create a deck and put it in session
  suits = ["S", "D", "H", "C"]
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  end

  #session[:player_total] = calculate_total(session[:player_cards])
  #session[:dealer_total] = calculate_total(session[:dealer_cards])
  erb :game
end

post "/game/player/hit" do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "Congratulations! #{session[:player_name]} hit Blackjack!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "Sorry, it looks like #{session[:player_name]} busted."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post "/game/player/stay" do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_or_stay_buttons = false
  erb :game
end