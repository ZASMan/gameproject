require_relative '../RandomNameGeneration/random_name_generator'

module Nameable
  def give_name
    random_name_generator = RandomNameGenerator.new("media/places_sample")
    random_name_generator.generate
  end
end