module Risk
  class Continent
    getter name : String
    getter bonus : UInt8
    getter territories : Array(String)

    def initialize(name, bonus, territories)
      @name = name
      @bonus = bonus
      @territories = territories
    end
  end
end
