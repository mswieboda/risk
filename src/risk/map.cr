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
          name: "north america",
          x: 0,
          y: 0,
          data: [
            {name: "alaska", x: 0, y: 4, width: 128, height: 128, unit_cx: 59, unit_cy: 47, connections: %w(northwest-territory alberta)},
            {name: "northwest-territory", x: 5, y: 3, width: 208, height: 96, unit_cx: 79, unit_cy: 63, connections: %w(greenland ontario alberta alaska)},
            {name: "greenland", x: 18, y: 0, width: 176, height: 176, unit_cx: 96, unit_cy: 67, connections: %w(quebec ontario northwest-territory)},
            {name: "alberta", x: 6, y: 8, width: 112, height: 96, unit_cx: 55, unit_cy: 45, connections: %w(western-united-states ontario northwest-territory alaska)},
            {name: "ontario", x: 12, y: 8, width: 112, height: 144, unit_cx: 35, unit_cy: 60, connections: %w(eastern-united-states western-united-states alberta northwest-territory greenland quebec)},
            {name: "quebec", x: 16, y: 8, width: 128, height: 128, unit_cx: 55, unit_cy: 60, connections: %w(eastern-united-states ontario greenland)},
            {name: "western-united-states", x: 6, y: 13, width: 128, height: 128, unit_cx: 60, unit_cy: 50, connections: %w(central-america eastern-united-states ontario alberta)},
            {name: "eastern-united-states", x: 10, y: 13, width: 176, height: 144, unit_cx: 79, unit_cy: 79, connections: %w(central-america western-united-states quebec ontario)},
            {name: "central-america", x: 7, y: 19, width: 112, height: 144, unit_cx: 41, unit_cy: 33, connections: %w(venezula eastern-united-states western-united-states)},
          ]
        },
        {
          name: "south america",
          x: 12,
          y: 25,
          data: [
            {name: "venezula", x: 0, y: 0, width: 160, height: 80, unit_cx: 64, unit_cy: 32, connections: %w(peru brazil central-america)},
            {name: "brazil", x: 2, y: 2, width: 208, height: 192, unit_cx: 117, unit_cy: 73, connections: %w(argentina peru venezula)},
            {name: "peru", x: 0, y: 3, width: 144, height: 160, unit_cx: 75, unit_cy: 85, connections: %w(argentina brazil venezula)},
            {name: "argentina", x: 0, y: 9, width: 144, height: 224, unit_cx: 83, unit_cy: 85, connections: %w(peru brazil)}
          ]
        }
      ]

      territory_data.each do |c_data|
        c_data[:data].each do |t_data|
          @territories << Territory.new(
            name: t_data[:name],
            x: x + (c_data[:x] + t_data[:x]) * CellSize,
            y: y + (c_data[:y] + t_data[:y]) * CellSize,
            width: t_data[:width],
            height: t_data[:height],
            unit_cx: t_data[:unit_cx],
            unit_cy: t_data[:unit_cy],
            connections: t_data[:connections]
          )
        end
      end
    end

    def draw(window)
      @territories.each(&.draw(window))
    end
  end
end
