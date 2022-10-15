module Risk
  class Player
    getter name : String
    getter color : SF::Color
    property units : UInt8

    EmptyColor = SF::Color.new(96, 96, 96)

    InitialUnits = 10_u8

    def initialize(name, color, units = InitialUnits)
      @name = name
      @color = color
      @units = InitialUnits
    end

    def self.empty
      @@empty_player ||= Player.new("empty", EmptyColor)
    end
  end
end
