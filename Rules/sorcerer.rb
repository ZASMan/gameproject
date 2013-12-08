require_relative 'character'

# A character class that specialize in arcane magic and wears next to no armor.
class Sorcerer < Character
  def initialize(name, stats)
    super(name, stats)
    @current_hp = @max_hp = 4
    @sp = 6

    @hp_per_level = 3
    @sp_per_level = 4

    @paper_doll.armor_categories = [:very_light]
    @paper_doll.weapon_categories = [:simple]

    @abilities['c'] = method(:cast)
    @spells = { 1 => [], 2 => [], 3 => [], 4 => [], 5 => [] }
  end

  def level
    super
    @sp += @sp_per_level + @intellect / 4
  end
end
