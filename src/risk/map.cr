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
            {name: "alaska", x: 0, y: 4, width: 128, height: 128, unit_cx: 59, unit_cy: 47},
            {name: "northwest-territory", x: 5, y: 3, width: 208, height: 96, unit_cx: 79, unit_cy: 63},
            {name: "greenland", x: 18, y: 0, width: 176, height: 176, unit_cx: 96, unit_cy: 67},
            {name: "alberta", x: 6, y: 8, width: 112, height: 96, unit_cx: 55, unit_cy: 45},
            {name: "ontario", x: 12, y: 8, width: 112, height: 144, unit_cx: 35, unit_cy: 60},
            {name: "quebec", x: 16, y: 8, width: 128, height: 128, unit_cx: 55, unit_cy: 60},
            {name: "western-united-states", x: 6, y: 13, width: 128, height: 128, unit_cx: 60, unit_cy: 50},
            {name: "eastern-united-states", x: 10, y: 13, width: 176, height: 144, unit_cx: 79, unit_cy: 79},
            {name: "mexico", x: 7, y: 19, width: 112, height: 144, unit_cx: 41, unit_cy: 33},
          ]
        },
        {
          name: "south america",
          x: 12,
          y: 25,
          data: [
            {name: "venezula", x: 0, y: 0, width: 160, height: 80, unit_cx: 64, unit_cy: 32},
            {name: "brazil", x: 2, y: 2, width: 208, height: 192, unit_cx: 117, unit_cy: 73},
            {name: "peru", x: 0, y: 3, width: 144, height: 160, unit_cx: 75, unit_cy: 85},
            {name: "argentina", x: 0, y: 9, width: 144, height: 224, unit_cx: 83, unit_cy: 85}
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
            unit_cy: t_data[:unit_cy]
          )
        end
      end
    end

    def draw(window)
      @territories.each(&.draw(window))
    end
  end
end
