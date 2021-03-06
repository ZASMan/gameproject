require_relative '../RandomNameGeneration/nameable'
require_relative '../RandomNameGeneration/establishment_name_generator'
require_relative '../RandomNameGeneration/place_name_generator'
require_relative '../tile'
require_relative 'building'

# A base class for a city factory. Do not use this class directly.
# You should inherit from this class to create a specific city
# factory.
class CityFactory
  include Nameable
  include Edge

  attr_reader :width, :height

  def initialize
  end

  # lazy initialization
  def establishment_name_generator
    @establishment_name_generator ||= EstablishmentNameGenerator.new
  end

  # lazy initialization
  def temple_name_generator
    @temple_name_generator ||=
        PlaceNameGenerator.new('/media/temple_types',
                               '/media/greek_myth_sample')
  end

  private

  # initialize starting tiles to either walls or open spaces
  def initialize_starting_tiles
    (0...@width).each do |x|
      (0...@height).each do |y|

        if edge_of_map?(x, y)
          type = :wall
        else
          type = :open
        end

        @tiles[x + y * width] = Tile.new(type, x, y)
      end
    end
  end

  # randomly select an entrance, must not be one of the four corners
  def place_entrance
    # select wall tiles that aren't close to any corner
    wall_tiles = @tiles.select do |tile|
      edge_of_map?(tile.x, tile.y) &&
          !(tile.x < @width / 4 && tile.y == 0) &&
          !(tile.x > 3 * @width / 4 && tile.y == 0) &&
          !(tile.x < @width / 4 && tile.y == @height - 1) &&
          !(tile.x > 3 * @width / 4 && tile.y == @height - 1) &&
          !(tile.x == 0 && tile.y < @height / 4) &&
          !(tile.x == 0 && tile.y > 3 * @height / 4) &&
          !(tile.x == @width - 1 && tile.y < @height / 4) &&
          !(tile.x == @width - 1 && tile.y > 3 * @height / 4)
    end

    wall_tiles.shuffle.first.type = :entrance
  end

  def place_buildings
    direction = [:zonal, :meridional].shuffle.first
    zonal_facing = :east

    for index_x in 0...(@width / 4 - 1)
      meridional_facing = :south

      for index_y in 0...(@height / 4 - 1)
        place_new_building(direction, index_x, index_y, meridional_facing,
                           zonal_facing)

        if meridional_facing == :south
          meridional_facing = :north
        else
          meridional_facing = :south
        end
      end

      if zonal_facing == :east
        zonal_facing = :west
      else
        zonal_facing = :east
      end
    end
  end

  def place_new_building(direction, index_x, index_y, meridional_facing,
      zonal_facing)
    building = Building.new(4, 4,
                            if direction == :zonal
                              zonal_facing
                            else
                              meridional_facing
                            end)
    building.draw_on(@city, [index_x * 4 + 1, index_y * 4 + 1])
  end

  # if there is a continuous two spaces street next to either the east or
  # south wall move the wall over one space
  def readjust_walls
    readjust_east_wall
    readjust_south_wall
  end

  def readjust_east_wall
    if @tiles.select { |tile| tile.x == @width - 2 && tile.y != 0 && tile.y != @height - 1 }.all? { |tile| tile.type == :open } &&
        @tiles.select { |tile| tile.x == @width - 3 && tile.y != 0 && tile.y != @height - 1 }.all? { |tile| tile.type == :open }
      # move wall
      @tiles.select { |tile| tile.x == @width - 1 && tile.y != 0 && tile.y != @height - 1 }
      .each { |tile| tile_at(tile.x - 1, tile.y).type = tile.type }

      @tiles.select { |tile| tile.x == @width - 1 }
      .each { |tile| tile_at(tile.x, tile.y).type = :wall }
    end
  end

  def readjust_south_wall
    if @tiles.select { |tile| tile.y == @height - 2 && tile.x != 0 && tile.x < @width - 2 }.all? { |tile| tile.type == :open } &&
        @tiles.select { |tile| tile.y == @height - 3 && tile.x != 0 && tile.x < @width - 2 }.all? { |tile| tile.type == :open }
      # move wall
      @tiles.select { |tile| tile.y == @height - 1 && tile.x != 0 && tile.x < @width - 2 }
      .each { |tile| tile_at(tile.x, tile.y - 1).type = tile.type }

      @tiles.select { |tile| tile.y == @height - 1 }
      .each { |tile| tile_at(tile.x, tile.y).type = :wall }
    end
  end

  # Place blocks that could possibly be dead-ends depending on
  # street configuration  in the very least, odd walls.
  # This is to bring a little randomness to the city.
  def place_dead_ends
    # place one dead-end wall for each 100 blocks of city
    @city.tiles.each_slice(100) do |slice|
      if slice.count < 100
        return
      end

      unsuitable = [:door, :entrance]

      slice.select do |tile|
        tile.type == :open &&
            !unsuitable.include?(@city.tile_at(tile.x - 1, tile.y).type) &&
            !unsuitable.include?(@city.tile_at(tile.x + 1, tile.y).type) &&
            !unsuitable.include?(@city.tile_at(tile.x, tile.y - 1).type) &&
            !unsuitable.include?(@city.tile_at(tile.x, tile.y + 1).type) &&
            (
            @city.tile_at(tile.x - 1, tile.y).type == :wall ||
                @city.tile_at(tile.x + 1, tile.y).type == :wall ||
                @city.tile_at(tile.x, tile.y - 1).type == :wall ||
                @city.tile_at(tile.x, tile.y + 1).type == :wall
            )
      end.shuffle.first.type = :wall
    end
  end

  def place_events(events)
    events.each do |event|
      @city.tiles.select { |tile| tile.type == :door && tile.event.nil? }
        .shuffle.first.event = event
    end
  end

  def tile_at(x, y)
    @tiles[x + y * @width]
  end
end
