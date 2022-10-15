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

    Phases = [:order, :allocate, :play]
    TurnPhases = [:predraft, :draft, :attack, :fortify]
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
    end

    def update(frame_time, mouse, mouse_coords)
      case phase
      when :order
        determine_order
      when :allocate
        allocate_territories(mouse, mouse_coords)
      when :play
        case turn_phase
        when :predraft
          player_territories = map.territories.select(&.player?(player)).size
          player.units = [MinDraftUnits, (player_territories / HeldTerritoriesRatio).to_i].max.to_u8

          # TODO: calculate continent bonuses

          next_turn_phase
        when :draft
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
        when :attack
        when :fortify
        end
      end
    end

    def checks_mouse_hover(territories, mouse_coords)
      map.territories.each(&.clear_hover)
      territories.each do |territory|
        break if territory.check_hover(mouse_coords)
      end
    end

    def determine_order
      @players.shuffle!
      @player = players[turn_index]

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

      if turn_index > players.size - 1
        @turn_index = 0
      end

      @player = players[turn_index]
    end

    def next_turn_phase
      @turn_phase_index += 1_u8
      @turn_phase_index = 0 if turn_phase_index > TurnPhases.size - 1
      @turn_phase = TurnPhases[turn_phase_index]

      next_turn if turn_phase_index == 0
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
        player_territories = map.territories.select(&.player?(player))

        if auto_allocate_armies?
          auto_allocate_army(player_territories.sample) if player_territories.any?
        else
          checks_mouse_hover(player_territories, mouse_coords) if player.human?

          if territory = player.choose_territory(mouse, player_territories)
            auto_allocate_army(territory)
          end
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
  end
end
