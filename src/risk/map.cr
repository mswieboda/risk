require "./territory"

module Risk
  class Map
    getter x : Int32
    getter y : Int32
    getter territories : Array(Territory)

    CellSize = 16

    def initialize(x = 0, y = 0)
      @x = x
      @y = y

      @territories = [] of Territory

      territory_data = [
        {
          name: "north-america",
          x: 0,
          y: 0,
          territories: [
            {name: "alaska", x: 0, y: 4, width: 128, height: 128, unit_cx: 59, unit_cy: 47, connections: %w(northwest-territory alberta kamchatka)},
            {name: "northwest-territory", x: 5, y: 3, width: 208, height: 96, unit_cx: 79, unit_cy: 63, connections: %w(greenland ontario alberta alaska)},
            {name: "greenland", x: 18, y: 0, width: 176, height: 176, unit_cx: 96, unit_cy: 67, connections: %w(quebec ontario northwest-territory iceland)},
            {name: "alberta", x: 6, y: 8, width: 112, height: 96, unit_cx: 55, unit_cy: 45, connections: %w(western-united-states ontario northwest-territory alaska)},
            {name: "ontario", x: 12, y: 8, width: 112, height: 144, unit_cx: 35, unit_cy: 60, connections: %w(eastern-united-states western-united-states alberta northwest-territory greenland quebec)},
            {name: "quebec", x: 16, y: 8, width: 128, height: 128, unit_cx: 55, unit_cy: 60, connections: %w(eastern-united-states ontario greenland)},
            {name: "western-united-states", x: 6, y: 13, width: 128, height: 128, unit_cx: 60, unit_cy: 50, connections: %w(central-america eastern-united-states ontario alberta)},
            {name: "eastern-united-states", x: 10, y: 13, width: 176, height: 144, unit_cx: 79, unit_cy: 79, connections: %w(central-america western-united-states quebec ontario)},
            {name: "central-america", x: 7, y: 19, width: 112, height: 144, unit_cx: 41, unit_cy: 33, connections: %w(venezula eastern-united-states western-united-states)},
          ]
        },
        {
          name: "south-america",
          x: 12,
          y: 25,
          territories: [
            {name: "venezula", x: 0, y: 0, width: 160, height: 80, unit_cx: 64, unit_cy: 32, connections: %w(peru brazil central-america)},
            {name: "brazil", x: 2, y: 2, width: 208, height: 192, unit_cx: 117, unit_cy: 73, connections: %w(argentina peru venezula north-africa)},
            {name: "peru", x: 0, y: 3, width: 144, height: 160, unit_cx: 75, unit_cy: 85, connections: %w(argentina brazil venezula)},
            {name: "argentina", x: 3, y: 9, width: 96, height: 224, unit_cx: 39, unit_cy: 83, connections: %w(peru brazil)}
          ]
        },
        {
          name: "africa",
          x: 28,
          y: 24,
          territories: [
            {name: "north-africa", x: 0, y: 0, width: 176, height: 192, unit_cx: 69, unit_cy: 99, connections: %w(brazil western-europe southern-europe egypt east-africa congo)},
            {name: "egypt", x: 6, y: 1, width: 144, height: 96, unit_cx: 69, unit_cy: 45, connections: %w(north-africa southern-europe middle-east east-africa)},
            {name: "east-africa", x: 10, y: 5, width: 144, height: 208, unit_cx: 55, unit_cy: 60, connections: %w(egypt middle-east madagascar south-africa congo north-africa)},
            {name: "congo", x: 6, y: 8, width: 144, height: 144, unit_cx: 69, unit_cy: 69, connections: %w(north-africa east-africa south-africa)},
            {name: "south-africa", x: 7, y: 13, width: 144, height: 176, unit_cx: 63, unit_cy: 85, connections: %w(congo east-africa madagascar)},
            {name: "madagascar", x: 15, y: 15, width: 80, height: 112, unit_cx: 37, unit_cy: 67, connections: %w(east-africa south-africa)}
          ]
        }
      ]

      territory_data.each do |continent|
        continent[:territories].each do |territory|
          @territories << Territory.new(
            name: territory[:name],
            continent: continent[:name],
            x: x + (continent[:x] + territory[:x]) * CellSize,
            y: y + (continent[:y] + territory[:y]) * CellSize,
            width: territory[:width],
            height: territory[:height],
            unit_cx: territory[:unit_cx],
            unit_cy: territory[:unit_cy],
            connections: territory[:connections]
          )
        end
      end
    end

    def draw(window)
      @territories.each(&.draw(window))
    end
  end
end
