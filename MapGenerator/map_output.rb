# a simple way to output the various maps
# the reason for this file is to be able to view the maps during the 
# development of the map generator

require 'gosu'
require 'texplay'
require './world_map.rb'
require './gaussian_filter'
require './height_map_configurator'
require './river_filter'

class MapOutput < Gosu::Window
  def initialize
  	@x, @y = 80, 80
  
    super @x * 10, @y * 10, false
    self.caption = "Map Output"
    
    @height_map = HeightMap.new
		@height_map.visit(HeightMapConfigurator::Medium_world)
		@height_map.generate(@x, @y)
    
    blur_filter = GaussianFilter.new
		filtered_twice = @height_map.filter(blur_filter).filter(blur_filter)

    river_filter = RiverFilter.new(@x, @y)
    river_filtered = filtered_twice.filter(river_filter)

    @map = WorldMap.new(@x, @y, river_filtered.data)
    #@map = WorldMap.new(@x, @y, filtered_twice.data)
            
    @water_tile = Gosu::Image.new(self, "media/water.png", true)   
    @grass_tile = Gosu::Image.new(self, "media/grass.png", true)
    @mountain_tile = Gosu::Image.new(self, "media/mountain.png", true)
    @sand_tile = Gosu::Image.new(self, "media/sand.png", true)
    @forest_tile = Gosu::Image.new(self, "media/forest.png", true)
    @cave_tile = Gosu::Image.new(self, "media/cave.png", true)
    @city_tile = Gosu::Image.new(self, "media/city.png", true)
    @snow_tile = Gosu::Image.new(self, "media/snow.png", true)
    @snow_forest = Gosu::Image.new(self, "media/snow-forest.png", true)
  end
  
  def update
  end
  
  def draw
  	font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  
		@map.tiles.each do |tile| 
			if tile.type == :water  
			  tile_to_draw = @water_tile
			elsif tile.type == :grass
				tile_to_draw = @grass_tile
			elsif tile.type == :sand
				tile_to_draw = @sand_tile
			elsif tile.type == :forest
				tile_to_draw = @forest_tile
			elsif tile.type == :mountain
				tile_to_draw = @mountain_tile
      elsif tile.type == :cave
        tile_to_draw = @cave_tile
      elsif tile.type == :city
        tile_to_draw = @city_tile
      elsif tile.type == :snow
        tile_to_draw = @snow_tile
      elsif tile.type == :snow_forest
        tile_to_draw = @snow_forest
			end
			
			tile_to_draw.draw(tile.x * 10, tile.y * 10, 0)
      font.draw(@map.world_name, 10, 10, 0)
		end  
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      @height_map.draw("rendered_maps/unfiltered.png")
      
      blur_filter = GaussianFilter.new
			
			filtered_once = @height_map.filter(blur_filter)
			filtered_twice = @height_map.filter(blur_filter).filter(blur_filter)

			filtered_twice.draw("rendered_maps/filtered_twice.png")			
			filtered_once.draw("rendered_maps/filtered.png")
			
			@height_map.filter(blur_filter).draw("rendered_maps/filtered.png")
			@height_map.filter(blur_filter).filter(blur_filter).draw("rendered_maps/filtered_twice.png")
			
			image = TexPlay.create_image(self, @x, @y, :color => Gosu::Color::BLACK)
			image.draw(0, 0, 0)
			
			@map.tiles.each {|tile| image.pixel tile.x, tile.y, :color => tile.color}							

			image.save "rendered_maps/rendered_map.png"	
			
      close     	
    end
  end
end

window = MapOutput.new
window.show
