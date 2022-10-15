module Risk
  class Player
    getter name : String
    getter color : SF::Color
    property units : UInt8
    property? drafting
    property? drafted

    EmptyColor = SF::Color.new(96, 96, 96)
    MaxInitialUnits = 40_u8
    InitialUnitDecreasePerPlayer = 5_u8


    def initialize(name, color)
      @name = name
      @color = color
      @units = 0_u8

      @drafting = false
      @drafted = false
    end

    def self.empty
      @@empty_player ||= Player.new("empty", EmptyColor)
    end

    def human?
      # TODO: override for CPUPlayer subclass
      true
    end

    def initial_units(players : UInt8)
      if players < 10_u8
        @units = MaxInitialUnits - ((players - 2) * InitialUnitDecreasePerPlayer)
      else
        @units =  0_u8
      end
    end

    def choose_territory(mouse, empty_territories : Array(Territory))
      return nil unless mouse.just_pressed?(Mouse::Left)

      empty_territories.find(&.hover?)
    end

    def draft
      @drafting = true
    end
  end
end
