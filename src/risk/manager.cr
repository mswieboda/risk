module Risk
  class Manager
    getter players : Array(Player)
    getter map : Map
    getter? auto_allocate_territories
    getter? auto_allocate_armies
    getter phase_index : UInt8
    getter phase : Symbol
    getter turn_index : UInt8
    getter player : Player
    getter turn_phase_index : UInt8
    getter turn_phase : Symbol
    getter attack_phase_index : UInt8
    getter attack_phase : Symbol
    getter attacker_max_dice : UInt8
    getter attacker_dice : UInt8
    getter defender_dice : UInt8
    getter? attacked
    getter attacker_values : Array(UInt8)
    getter defender_values : Array(UInt8)
    getter attacker_losses : UInt8
    getter defender_losses : UInt8
    getter? exit

    @territory_from : Territory?
    @territory_to : Territory?

    Phases = [:order, :allocate_territories, :allocate_armies, :turns]
    TurnPhases = [:predraft, :draft, :attack, :fortify]
    AttackPhases = [:select, :choose_dice, :attack, :move]
    MinDraftUnits = 3
    HeldTerritoriesRatio = 3

    def initialize(players, map, auto_allocate_territories = true, auto_allocate_armies = true)
      @players = players
      @map = map
      @auto_allocate_territories = auto_allocate_territories
      @auto_allocate_armies = auto_allocate_armies

      @phase_index = 0_u8
      @phase = Phases[@phase_index]

      @turn_index = 0_u8
      @player = @players[@turn_index]

      @turn_phase_index = 0_u8
      @turn_phase = TurnPhases[@turn_phase_index]

      @attack_phase_index = 0_u8
      @attack_phase = AttackPhases[@attack_phase_index]

      @territory_from = nil
      @territory_to = nil

      @attacker_max_dice = 0_u8
      @attacker_dice = 0_u8
      @defender_dice = 0_u8
      @attacked = false
      @attacker_values = [] of UInt8
      @defender_values = [] of UInt8
      @attacker_losses = 0_u8
      @defender_losses = 0_u8

      @exit = false
    end

    def update(frame_time, keys, mouse, mouse_coords)
      clear_mouse_hover

      case phase
      when :order
        determine_order
      when :allocate_territories
        allocate_territories(mouse, mouse_coords)
      when :allocate_armies
        allocate_armies(mouse, mouse_coords)
      when :turns
        case turn_phase
        when :predraft
          predraft
        when :draft
          draft(mouse, mouse_coords)
        when :attack
          case attack_phase
          when :select
            attack_select(keys, mouse, mouse_coords)
          when :choose_dice
            attack_choose_dice(keys)

            if keys.just_pressed?(Keys::Space)
              next_attack_phase
            end
          when :attack
            attack_attack(keys)
          when :move
            attack_move(keys, mouse, mouse_coords)
          end
        when :fortify
          fortify(keys, mouse, mouse_coords)
        end
      end
    end

    def clear_mouse_hover
      map.territories.each(&.clear_hover)
    end

    def checks_mouse_hover(territories, mouse_coords)
      territories.each do |territory|
        break if territory.check_hover(mouse_coords)
      end
    end

    def determine_order
      @players.shuffle!
      @player = @players[turn_index]

      next_phase
    end

    def next_phase
      if @phase_index < Phases.size - 1
        @phase_index += 1_u8
        @phase = Phases[phase_index]
      end
    end

    def next_turn
      @turn_index += 1_u8
      @turn_index = 0_u8 if turn_index > players.size - 1
      @player = players[turn_index]
    end

    def next_turn_phase
      @turn_phase_index += 1_u8
      @turn_phase_index = 0_u8 if turn_phase_index > TurnPhases.size - 1
      @turn_phase = TurnPhases[turn_phase_index]
      @attack_phase_index = 0_u8 if turn_phase == :attack

      next_turn if turn_phase_index == 0_u8
    end

    def next_attack_phase
      @attacked = false
      @attack_phase_index += 1_u8
      @attack_phase_index = 0 if attack_phase_index > AttackPhases.size - 1
      @attack_phase = AttackPhases[attack_phase_index]

      next_turn_phase if attack_phase_index == 0_u8
    end

    def allocate_territories(mouse, mouse_coords)
      empty_territories = map.territories.select(&.empty?)

      if empty_territories.any?
        if auto_allocate_territories?
          auto_allocate_territory(empty_territories.sample)
        else
          checks_mouse_hover(empty_territories, mouse_coords) if player.human?

          if territory = player.choose_territory(mouse, empty_territories)
            auto_allocate_territory(territory)
          end
        end
      else
        next_phase
      end
    end

    def allocate_armies(mouse, mouse_coords)
      player_territories = map.territories.select(&.player?(player))

      if auto_allocate_armies?
        auto_allocate_army(player_territories.sample) if player_territories.any?
      else
        if player.units <= 0
          next_turn
          return
        end

        checks_mouse_hover(player_territories, mouse_coords) if player.human?

        if territory = player.choose_territory(mouse, player_territories)
          auto_allocate_army(territory)
        end
      end
    end

    def allocate_territory(territory)
      territory.player = player
      player.units -= 1
      territory.units += 1
    end

    def auto_allocate_territory(territory)
      if territory && player.units > 0
        allocate_territory(territory)
      elsif turn_index == players.size - 1
        next_phase
      end

      next_turn
    end

    def allocate_army(territory)
      territory.player = player
      player.units -= 1
      territory.units += 1
    end

    def auto_allocate_army(territory)
      if territory && player.units > 0
        allocate_army(territory)
      elsif turn_index == players.size - 1
        next_phase
      end

      next_turn
    end

    def predraft
      player_territories = map.territories.select(&.player?(player)).size
      player.units = [MinDraftUnits, (player_territories / HeldTerritoriesRatio).to_i].max.to_u8

      # TODO: calculate continent bonuses

      next_turn_phase
    end

    def draft(mouse, mouse_coords)
      player_territories = map.territories.select(&.player?(player))

      if player.human? && player.units > 0
        checks_mouse_hover(player_territories, mouse_coords)
      end

      if player.units > 0
        if territory = player.choose_territory(mouse, player_territories)
          allocate_army(territory)
        end
      end

      next_turn_phase if player.units <= 0
    end

    def attack_select(keys, mouse, mouse_coords)
      if keys.just_pressed?(Keys::Space)
        next_turn_phase
      elsif territory_to = @territory_to
        set_dice
        next_attack_phase
      elsif territory_from = @territory_from
        territories = map.territories.reject(&.player?(player)).select(&.connected?(territory_from))

        if player.human?
          checks_mouse_hover(territories, mouse_coords)
        end

        if territory = player.choose_territory(mouse, territories)
          @territory_to = territory
        end
      else
        enemy_territories = map.territories.reject(&.player?(player))
        player_territories = map
          .territories
          .select(&.player?(player))
          .select { |t| t.units > 1 }
          .select { |t| enemy_territories.any?(&.connected?(t)) }

        if player.human?
          checks_mouse_hover(player_territories, mouse_coords)
        end

        if territory = player.choose_territory(mouse, player_territories)
          @territory_from = territory
        end
      end
    end

    def set_dice
      if territory_from = @territory_from
        if territory_to = @territory_to
          @attacker_max_dice = [territory_from.units - 1, 3].min.to_u8
          @attacker_dice = @attacker_max_dice
          @defender_dice = [territory_to.units, 2].min.to_u8
        end
      end
    end

    def attack_choose_dice(keys)
      if keys.just_pressed?(Keys::Num1)
        @attacker_dice = 1_u8
      elsif keys.just_pressed?(Keys::Num2) && @attacker_max_dice >= 2_u8
        @attacker_dice = 2_u8
      elsif keys.just_pressed?(Keys::Num3) && @attacker_max_dice >= 3_u8
        @attacker_dice = 3_u8
      elsif keys.just_pressed?([Keys::Q, Keys::Backspace, Keys::Delete])
        attack_back_to_select
      end
    end

    def attack_back_to_select
      @attacked = false
      @territory_to = nil
      @territory_from = nil
      @attack_phase_index = 0_u8
      @attack_phase = AttackPhases[@attack_phase_index]
    end

    def random_dice_roll
      rand(6_u8) + 1_u8
    end

    def attack_attack(keys)
      if attacked?
        set_dice
        attack_choose_dice(keys)

        if keys.just_pressed?(Keys::Space)
          @attacked = false
        end
      else
        @attacker_values = Array.new(attacker_dice) { random_dice_roll }.sort { |a, b| b <=> a }
        @defender_values = Array.new(defender_dice) { random_dice_roll }.sort { |a, b| b <=> a }

        @attacker_losses = 0
        @defender_losses = 0

        min_dice = [attacker_dice, defender_dice].min

        min_dice.times do |n|
          if defender_values[n] >= attacker_values[n]
            @attacker_losses += 1
          else
            @defender_losses += 1
          end
        end

        if attacker_losses > 0
          if territory_from = @territory_from
            territory_from.units -= attacker_losses

            attack_back_to_select if territory_from.units <= 1
          end
        end

        if defender_losses > 0
          if territory_to = @territory_to
            territory_to.units -= defender_losses

            if territory_to.units <= 0
              if territory_from = @territory_from
                territory_to.player = player

                units = territory_from.units - 1
                territory_from.units -= units
                territory_to.units = units

                next_attack_phase
              end
            end
          end
        end

        @attacked = true
      end
    end

    def attack_move(keys, mouse, mouse_coords)
      if territory_from = @territory_from
        if territory_to = @territory_to
          territories = [] of Territory

          territories << territory_from if territory_to.units > attacker_dice
          territories << territory_to if territory_from.units > 1

          if territories.empty?
            attack_back_to_select
            return
          end

          checks_mouse_hover(territories, mouse_coords) if player.human?

          if territory = player.choose_territory(mouse, territories)
            if territory == territory_from
              if territory_to.units > attacker_dice
                territory.units += 1
                territory_to.units -= 1
              end
            elsif territory == territory_to
              if territory_from.units > 1
                territory.units += 1
                territory_from.units -= 1
              end
            end
          end
        end
      end

      if keys.just_pressed?(Keys::Space)
        attack_back_to_select
      end
    end

    def fortify(keys, mouse, mouse_coords)
      if keys.just_pressed?(Keys::Space)
        @territory_from = nil
        @territory_to = nil

        next_turn_phase
        return
      end

      player_territories = map.territories.select(&.player?(player))

      if territory_to = @territory_to
        if territory_from = @territory_from
          territories = [] of Territory

          territories << territory_from if territory_to.units > 1
          territories << territory_to if territory_from.units > 1

          checks_mouse_hover(territories, mouse_coords) if player.human?

          # TODO: check for Q/Backspace/Delete, which will undo everything, and stay in fortify phase
          if territory = player.choose_territory(mouse, territories)
            if territory == territory_from
              if territory_to.units > 1
                territory.units += 1
                territory_to.units -= 1
              end
            elsif territory == territory_to
              if territory_from.units > 1
                territory.units += 1
                territory_from.units -= 1
              end
            end
          end
        end
      elsif territory_from = @territory_from
        territories = player_territories.select(&.connected?(territory_from))

        if player.human?
          checks_mouse_hover(territories, mouse_coords)
        end

        if territory = player.choose_territory(mouse, territories)
          @territory_to = territory
        end
      else
        territories = player_territories
          .select { |t| t.units > 1 }
          .select { |t| player_territories.any?(&.connected?(t)) }

        checks_mouse_hover(territories, mouse_coords) if player.human?

        if territory = player.choose_territory(mouse, territories)
          @territory_from = territory
        end
      end
    end
  end
end
