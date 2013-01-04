require_relative '../map'
require_relative 'city_factory'

class LargeCityFactory < CityFactory
  def initialize
    @width = 32
    @height = 32
    @tiles = Array.new
  end

  def build
    initialize_starting_tiles
    place_entrance
    readjust_walls

    city = Map.new(@width, @height, @tiles)
    city.name = give_name

    place_buildings(city)
    place_dead_ends(city)

    city
  end
end