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
    TurnPhases = [:draft, :attack, :fortify]

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

    def update(frame_time)
      case phase
      when :order
        determine_order
      when :allocate
        allocate_territories
      when :play
        case turn_phase
        when :draft
        when :attack
        when :fortify
        end
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
      @phase = Phases[phase_index]

      next_turn if turn_phase_index == 0
    end

    def allocate_territories
      empty_territories = map.territories.select(&.empty?)

      if empty_territories.any?
        if auto_allocate_territories?
          auto_allocate_territory(empty_territories.sample)
        else
          # TODO: wait for user interaction, impl allocate manually
        end
      else
        if auto_allocate_armies?
          auto_allocate_army
        else
          # TODO: wait for user interaction, impl allocate manually
        end
      end
    end

    def auto_allocate_territory(territory)
      if territory
        if player.units > 0
          territory.player = player
          player.units -= 1
          territory.units += 1
        elsif turn_index == players.size - 1
          next_phase
        end

        next_turn
      end
    end

    def auto_allocate_army
      player_territories = map.territories.select(&.player?(player))
      territory = player_territories.sample if player_territories.any?

      if territory && player.units > 0
        territory.player = player
        player.units -= 1
        territory.units += 1
      elsif turn_index == players.size - 1
        next_phase
      end

      next_turn
    end
  end
end
