require_relative 'random_name_generator'

# Generate the names of different commercial establishments found in cities.
class EstablishmentNameGenerator
  def initialize
    @existing_establishments = []
    @random_generator = Random.new
    @random_name_generator = RandomNameGenerator.new(File.dirname(__FILE__) +
                                                         '/media/male_sample')
    read_words_from_file
  end

  def get_name
    name = 'The ' + get_suitable_word(@common_adjectives) + ' ' +
        get_suitable_word(@common_nouns)
    append_branch_if_name_already_exists(name)
    name
  end

  def get_tavern_name
    if @random_generator.rand(1..100) <= 15
      name = @random_name_generator.generate + "'s " +
          @tavern_types.shuffle.first
    else
      name = 'The ' +
          get_suitable_word(@common_adjectives, @tavern_adjectives) + ' ' +
          get_suitable_word(@common_nouns, @tavern_nouns)
    end

    append_branch_if_name_already_exists(name)
    name
  end

  def get_shop_name
    if @random_generator.rand(1..100) <= 15
      name = @random_name_generator.generate + "'s " + @shop_types.shuffle.first
    else
      name = 'The ' + get_suitable_word(@common_adjectives, @shop_adjectives) +
          ' ' + get_suitable_word(@common_nouns, @shop_nouns)
    end

    append_branch_if_name_already_exists(name)
    name
  end

  private

  def get_suitable_word(*words)
    word_arrays = []
    words.each { |array| add_array_if_not_empty(word_arrays, array) }

    if word_arrays.empty?
      read_words_from_file
      return 'Wood'
    end

    # get word from a random word array and remove it
    word_arrays.shuffle.first.pop.chomp
  end

  def add_array_if_not_empty(array_of_arrays, array_to_add)
    array_of_arrays.push array_to_add unless array_to_add.empty?
  end

  def append_branch_if_name_already_exists(name)
    if @existing_establishments.include? name
      name.replace name + ', Branch'
    else
      @existing_establishments.push name
    end

    name
  end

  def read_words_from_file
    File.open(File.dirname(__FILE__) +
                '/media/common_adjectives') { |file| @common_adjectives = file.readlines }
    @common_adjectives.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/common_nouns') { |file| @common_nouns = file.readlines }
    @common_nouns.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/shop_adjectives') { |file| @shop_adjectives = file.readlines }
    @shop_adjectives.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/shop_nouns') { |file| @shop_nouns = file.readlines }
    @shop_nouns.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/tavern_adjectives') { |file| @tavern_adjectives = file.readlines }
    @tavern_adjectives.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/tavern_nouns') { |file| @tavern_nouns = file.readlines }
    @tavern_nouns.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/shop_types') { |file| @shop_types = file.readlines }
    @shop_types.shuffle!

    File.open(File.dirname(__FILE__) +
                '/media/tavern_types') { |file| @tavern_types = file.readlines }
    @tavern_types.shuffle!
  end
end
