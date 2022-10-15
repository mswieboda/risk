module Risk
  class Manager
    getter players : Array(Player)
    getter map : Map
    getter phase : Symbol
    getter phase_index : UInt8
    getter turn_index : UInt8
    getter player : Player

    Phases = [:order, :allocation, :play]

    def initialize(players, map)
      @players = players
      @map = map

      @phase_index = 0_u8
      @phase = Phases[@phase_index]

      @turn_index = 0_u8
      @player = @players[@turn_index]
    end

    def update(frame_time)
      case phase
      when :order
        determine_order
      when :allocation
        allocate_territories
      when :play
      end
    end

    def determine_order
      @players.shuffle!
      @player = players[turn_index]

      next_phase
    end

    def next_phase
      @phase_index += 1_u8
      @phase = Phases[phase_index]
    end

    def next_turn
      @turn_index += 1_u8

      if turn_index > players.size - 1
        @turn_index = 0
      end

      @player = players[turn_index]
    end

    def allocate_territories
      empty_territories = map.territories.select(&.empty?)
      territory = empty_territories.sample if empty_territories.any?

      unless territory
        player_territories = map.territories.select(&.player?(player))
        territory = player_territories.sample if player_territories.any?
      end

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
