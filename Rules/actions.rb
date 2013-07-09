module Actions
  @@random = Random.new

  def attack(enemies)
    target = pick_target enemies

		if @@random.rand(1..10) + @accuracy / 4 >= target.ac
			broadcast "#{@name} hits #{target.name}."
			target.take_damage(@paper_doll.weapon.hit)
		else
			broadcast "#{@name} misses #{target.name}."
		end
  end

  def block
    broadcast "#{@name} blocks."
    # add an :ac effect of +2 for 1 round
    @effects[:ac].push([2, 1])
  end

	def cast
		# present possible spells from spell-list (could be filtered)		
				
		# allow user to make selection
		
		# execute spell code (which will probably ask for a target)				
	end
  
  # empty action, does not do anything, not even block
  def pass
  end

	def run

  end
  
private
  def pick_target(enemies)
    available_targets = enemies.select {|m| m.hp > 0}
    broadcast "Which: "
    target_range = 1..6

    begin
      key_pressed = gets.chomp.to_i
    end while not target_range.any? {|x| x == key_pressed && x <= available_targets.length}

    available_targets[key_pressed - 1]
  end
end
